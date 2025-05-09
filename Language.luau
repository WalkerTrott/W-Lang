--!strict
--!native

type Literal = {
	Tag: "Literal",
	Literal: number,
	Line: number,
	Column: number
}

type Identifier = {
	Tag: "Identifier",
	Identifier: string,
	Line: number,
	Column: number
}

type Keyword = {
	Tag: "Keyword",
	Keyword: (
		| "return"
		| "let"
		| "do"
		| "end"
		| "if"
		| "then"
		| "else"
		| "function"
		| "and"
		| "or"
		| "not"
	),
	Line: number,
	Column: number
}

type Symbol = {
	Tag: "Symbol",
	Symbol: (
		| "("
		| ")"
		| ","
		| ":"
		| "'"
		| ".."
		| "="
		| "*"
		| "/"
		| "%"
		| "+"
		| "-"
		| "<"
		| "<="
		| ">"
		| ">="
		| "=="
		| "!="
	),
	Line: number,
	Column: number
}

type Token = Literal | Identifier | Keyword | Symbol


type Unary = {
	Tag: "Unary",
	Operation: (
		| "Negate"
		| "Not"
	),
	Right: Expression
}

type Binary = {
	Tag: "Binary",
	Operation: (
		| "Multiplication"
		| "Division"
		| "Remainder"
		| "Addition"
		| "Subtraction"
		| "Lesser"
		| "LesserEqual"
		| "Greater"
		| "GreaterEqual"
		| "Equal"
		| "NotEqual"
		| "And"
		| "Or"
	),
	Left: Expression,
	Right: Expression
}

type Call = {
	Tag: "Call",
	Name: Identifier,
	Arguments: {Expression}
}

type Expression = Literal | Identifier | Call | Unary | Binary

type Return = {
	Tag: "Return",
	Value: Expression,
	Type: {number}?
}

type Let = {
	Tag: "Let",
	Name: Identifier,
	Value: Expression,
	Type: {number}?
}

type Do = {
	Tag: "Do",
	Block: {Statement}
}

type Function = {
	Tag: "Function",
	Name: Identifier,
	Parameters: {
		{
			Name: Identifier,
			Type: {number}
		}
	},
	Block: {Statement},
	Type: {number}?
}

type If = {
	Tag: "If",
	Condition: Expression,
	Passing: {Statement},
	Failing: {Statement}
}

type Statement = Return | Let | Do | Function | If


type State = {[string]: {number}}

type Delegates = {
	[string]: {
		Parameters: {[string]: {number}},
		Result: {number}
	}
}

type Context = {
	Line: number,
	Column: number
}


local KeywordList = {
	["return"] = true,
	["let"] = true,
	["do"] = true,
	["end"] = true,
	["function"] = true,
	["if"] = true,
	["then"] = true,
	["else"] = true,
	["and"] = true,
	["or"] = true,
	["not"] = true
}

local SymbolList = {
	["("] = true,
	[")"] = true,
	[","] = true,
	[":"] = true,
	["'"] = true,
	["."] = true,
	["="] = true,
	["*"] = true,
	["/"] = true,
	["%"] = true,
	["+"] = true,
	["-"] = true,
	["<"] = true,
	[">"] = true,
	["!"] = true
}

-- Lexer

local function Lex(Source: string): {Token}
	local Result = {} :: {Token}
	local Array = string.split(Source, "")
	
	local Line = 0
	local Column = 0
	
	local Index = 1
	local Current = Array[Index]
	
	while Current do
		if Current == " " or Current == "\t" then
			Column += 1
			
			Index += 1
			Current = Array[Index]
			
			continue
		end
		
		if Current == "\n" then
			Line += 1
			Column = 0
			
			Index += 1
			Current = Array[Index]
			
			continue
		end
		
		if string.find(Current, "%d") then
			local Literal = tonumber(Current)
			
			if Literal then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current then
					while Current do
						if string.find(Current, "%d") then
							local Digit = tonumber(Current)
							
							if Digit then
								Literal = (Literal * 10) + Digit
								
								Column += 1
								
								Index += 1
								Current = Array[Index]
								
								continue
							end
							
							error(
								string.format(
									"%d:%d:Internal: Could not Convert Digit '%s' to Literal",
									Line,
									Column,
									Current
								)
							)
						end
						
						Column -= 1
						
						Index -= 1
						Current = Array[Index]
						
						break
					end
				end
				
				if Literal < 127 then
					table.insert(
						Result,
						{
							Tag = "Literal",
							Literal = Literal,
							Line = Line,
							Column = Column
						}
					)
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				error(
					string.format(
						"%d:%d:Lexer: Literal '%d' is Out of Range",
						Line,
						Column,
						Literal
					)
				)
			end
			
			error(
				string.format(
					"%d:%d:Internal: Could not Convert Digit '%s' to Literal",
					Line,
					Column,
					Current
				)
			)
		end
		
		if string.find(Current, "%u") then
			local Identifier = Current
			
			Column += 1
			
			Index += 1
			Current = Array[Index]
			
			while Current do
				if string.find(Current, "%x") then
					Identifier ..= Current
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				Column -= 1
				
				Index -= 1
				Current = Array[Index]
				
				break
			end
			
			table.insert(
				Result,
				{
					Tag = "Identifier",
					Identifier = Identifier,
					Line = Line,
					Column = Column
				}
			)
			
			Column += 1
			
			Index += 1
			Current = Array[Index]
			
			continue
		end
		
		if string.find(Current, "%l") then
			local Keyword = Current
			
			Column += 1
			
			Index += 1
			Current = Array[Index]
			
			while Current do
				if string.find(Current, "%l") then
					Keyword ..= Current
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				break
			end
			
			if KeywordList[Keyword] then
				table.insert(
					Result,
					{
						Tag = "Keyword",
						Keyword = Keyword :: any,
						Line = Line,
						Column = Column
					}
				)
				
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Lexer: Keyword '%s' is not valid",
					Line,
					Column,
					Keyword
				)
			)
		end
		
		if SymbolList[Current] then
			local Symbol = Current
			
			if Symbol == "-" then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current then
					if string.find(Current, "%d") then
						local Literal = tonumber(Current)
						
						if Literal then
							Column += 1
							
							Index += 1
							Current = Array[Index]
							
							if Current then
								while Current do
									if string.find(Current, "%d") then
										local Digit = tonumber(Current)
										
										if Digit then
											Literal = (Literal * 10) + Digit
											
											Column += 1
											
											Index += 1
											Current = Array[Index]
											
											continue
										end
										
										error(
											string.format(
												"%d:%d:Internal: Could not Convert Digit '%s' to Literal",
												Line,
												Column,
												Current
											)
										)
									end
									
									Column -= 1
									
									Index -= 1
									Current = Array[Index]
									
									break
								end
							end
							
							if Literal < 128 then
								table.insert(
									Result,
									{
										Tag = "Literal",
										Literal = -Literal,
										Line = Line,
										Column = Column
									}
								)
								
								Column += 1
								
								Index += 1
								Current = Array[Index]
								
								continue
							end
							
							error(
								string.format(
									"%d:%d:Lexer: Literal '%d' is Out of Range",
									Line,
									Column,
									Literal
								)
							)
						end
						
						error(
							string.format(
								"%d:%d:Internal: Could not Convert Digit '%s' to Literal",
								Line,
								Column,
								Current
							)
						)
					end
				end
				
				table.insert(
					Result,
					{
						Tag = "Symbol",
						Symbol = "-",
						Line = Line,
						Column = Column
					}
				)
			end
			
			if Symbol == "." then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current == "." then
					table.insert(
						Result,
						{
							Tag = "Symbol",
							Symbol = "..",
							Line = Line,
							Column = Column
						}
					)
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				error(
					string.format(
						"%d:%d:Lexer: Symbol '.' is not valid",
						Line,
						Column
					)
				)
			end
			
			if Symbol == "=" then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current == "=" then
					table.insert(
						Result,
						{
							Tag = "Symbol",
							Symbol = "==",
							Line = Line,
							Column = Column
						}
					)
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				Column -= 1
				
				Index -= 1
				Current = Array[Index]
			end
			
			if Symbol == "<" then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current == "=" then
					table.insert(
						Result,
						{
							Tag = "Symbol",
							Symbol = "<=",
							Line = Line,
							Column = Column
						}
					)
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				Column -= 1
				
				Index -= 1
				Current = Array[Index]
			end
			
			if Symbol == ">" then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current == "=" then
					table.insert(
						Result,
						{
							Tag = "Symbol",
							Symbol = ">=",
							Line = Line,
							Column = Column
						}
					)
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				Column -= 1
				
				Index -= 1
				Current = Array[Index]
			end
			
			if Symbol == "!" then
				Column += 1
				
				Index += 1
				Current = Array[Index]
				
				if Current == "=" then
					table.insert(
						Result,
						{
							Tag = "Symbol",
							Symbol = "!=",
							Line = Line,
							Column = Column
						}
					)
					
					Column += 1
					
					Index += 1
					Current = Array[Index]
					
					continue
				end
				
				error(
					string.format(
						"%d:%d:Lexer: Symbol '!' is not valid",
						Line,
						Column
					)
				)
			end
			
			table.insert(
				Result,
				{
					Tag = "Symbol",
					Symbol = Symbol :: any,
					Line = Line,
					Column = Column
				}
			)
			
			Column += 1
			
			Index += 1
			Current = Array[Index]
			
			continue
		end
		
		error(
			string.format(
				"%d:%d:Lexer: Unexpected Character '%s' when parsing",
				Line,
				Column,
				Current
			)
		)
	end
	
	return Result
end

-- Parser

local function CreateExpressionFromTokens(Tokens: {Token}, Index: number): (Expression, number)
	local Current = Tokens[Index]
	
	if Current then
		if Current.Tag == "Symbol" then
			local Expression, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
			
			Index = Offset
			Current = Tokens[Index]
			
			if Current then
				if Current.Tag == "Symbol" then
					if Current.Symbol == ")" then
						return Expression, Index + 1
					end
					
					error(
						string.format(
							"%d:%d:Parser: Unexpected Symbol '%s' when parsing Expression",
							Current.Line,
							Current.Column,
							Current.Symbol
						)
					)
				end
				
				error(
					string.format(
						"%d:%d:Parser: Unexpected %s '%s' when parsing Expression",
						Current.Line,
						Current.Column,
						Current.Tag,
						Current[Current.Tag]
					)
				)
			end
			
			error(
				string.format(
					"%d:%d:Parser: Unexpected EOF when parsing Expression",
					0,
					0
				)
			)
		end
		
		if Current.Tag == "Identifier" then
			local Left = Current
			
			Index += 1
			Current = Tokens[Index]
			
			if Current then
				if Current.Tag == "Symbol" then
					if Current.Symbol == "(" then
						local Arguments = {}
						
						Index += 1
						Current = Tokens[Index]
						
						while Current do
							if Current.Tag == "Symbol" and Current.Symbol == ")" then
								return {
									Tag = "Call",
									Name = Left,
									Arguments = Arguments
								}, Index + 1
							end
							
							local Expression, Offset = CreateExpressionFromTokens(Tokens, Index)
							
							table.insert(
								Arguments,
								Expression
							)
							
							Index = Offset
							Current = Tokens[Index]
							
							if Current then
								if Current.Tag == "Symbol" then
									if Current.Symbol == "," then
										Index += 1
										Current = Tokens[Index]
										
										continue
									end
									
									if Current.Symbol == ")" then
										return {
											Tag = "Call",
											Name = Left,
											Arguments = Arguments
										}, Index + 1
									end
									
									error(
										string.format(
											"%d:%d:Parser: Unexpected Symbol '%s' when parsing Expression",
											Left.Line,
											Left.Column,
											Current.Symbol
										)
									)
								end
								
								error(
									string.format(
										"%d:%d:Parser: Unexpected %s '%s' when parsing Expression",
										Left.Line,
										Left.Column,
										Current.Tag,
										Current[Current.Tag]
									)
								)
							end
							
							error(
								string.format(
									"%d:%d:Parser: Unexpected EOF when parsing Expression",
									Left.Line,
									Left.Column
								)
							)
						end
						
						error(
							string.format(
								"%d:%d:Parser: Unexpected EOF when parsing Expression",
								Left.Line,
								Left.Column
							)
						)
					end
				end
			end
			
			Index -= 1
			Current = Tokens[Index]
		end
		
		if Current.Tag == "Literal" or Current.Tag == "Identifier" then
			local Left = Current
			
			Index += 1
			Current = Tokens[Index]
			
			if Current then
				if Current.Tag == "Keyword" then
					if Current.Keyword == "and" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "And",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Keyword == "or" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Or",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					return Left, Index
				end
				
				if Current.Tag == "Symbol" then
					if Current.Symbol == "," or Current.Symbol == ")" then
						return Left, Index
					end
					
					if Current.Symbol == "*" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Multiplication",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "/" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Division",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "%" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Remainder",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "+" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Addition",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "-" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Subtraction",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "<" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Lesser",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "<=" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "LesserEqual",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == ">" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Greater",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == ">=" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "GreaterEqual",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "==" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "Equal",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					if Current.Symbol == "!=" then
						local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
						
						return {
							Tag = "Binary",
							Operation = "NotEqual",
							Left = Left,
							Right = Right
						}, Offset
					end
					
					error(
						string.format(
							"%d:%d:Parser: Unexpected Symbol '%s' when parsing Expression",
							Current.Line,
							Current.Column,
							Current.Symbol
						)
					)
				end
			end
			
			return Left, Index + 1
		end
		
		if Current.Tag == "Keyword" then
			if Current.Keyword == "not" then
				if Current then
					local Right, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
					
					return {
						Tag = "Unary",
						Operation = "Not",
						Right = Right
					}, Offset
				end
				
				error(
					string.format(
						"%d:%d:Parser: Unexpected EOF when parsing Expression",
						Current.Line,
						Current.Column
					)
				)
			end
		end
		
		error(
			string.format(
				"%d:%d:Parser: Unexpected %s '%s' when parsing Expression",
				Current.Line,
				Current.Column,
				Current.Tag,
				Current[Current.Tag]
			)
		)
	end
	
	error(
		string.format(
			"%d:%d:Parser: Unexpected EOF when parsing Expression",
			0,
			0
		)
	)
end

local function CreateTypeFromTokens(Tokens: {Token}, Index: number): ({number}, number)
	local Type = {}
	local Current = Tokens[Index]
	
	if Current then
		if Current.Tag == "Literal" then
			table.insert(
				Type,
				Current.Literal
			)
			
			Index += 1
			Current = Tokens[Index]
			
			while Current do
				if Current.Tag == "Symbol" then
					if Current.Symbol == "'" then
						Index += 1
						Current = Tokens[Index]
						
						if Current then
							if Current.Tag == "Literal" then
								local Literal = Current.Literal
								
								table.insert(
									Type,
									Literal
								)
								
								Index += 1
								Current = Tokens[Index]
								
								continue
							end
							
							error(
								string.format(
									"%d:%d:Parser: Unexpected %s '%s' when parsing Type",
									Current.Line,
									Current.Column,
									Current.Tag,
									Current[Current.Tag]
								)
							)
						end
						
						error("Parser: Unexpected EOF when parsing Type")
					end
					
					if Current.Symbol == ".." then
						local Left = Type[#Type]
						
						Index += 1
						Current = Tokens[Index]
						
						if Current then
							if Current.Tag == "Literal" then
								local Right = Current.Literal
								
								if Left < Right then
									for Value = Left, Right do
										table.insert(
											Type,
											Value
										)
									end
								else
									for Value = Right, Left do
										table.insert(
											Type,
											Value
										)
									end
								end
								
								Index += 1
								Current = Tokens[Index]
								
								continue
							end
							
							error(
								string.format(
									"%d:%d:Parser: Unexpected %s '%s' when parsing Type",
									Current.Line,
									Current.Column,
									Current.Tag,
									Current[Current.Tag]
								)
							)
						end
						
						error("Parser: Unexpected EOF when parsing Type")
					end
					
					break
				end
				
				error(
					string.format(
						"%d:%d:Parser: Unexpected %s '%s' when parsing Type",
						Current.Line,
						Current.Column,
						Current.Tag,
						Current[Current.Tag]
					)
				)
			end
			
			local Result = {}
			
			for Index, Value in Type do
				if not table.find(Result, Value) then
					table.insert(
						Result,
						Value
					)
				end
			end
			
			return Result, Index
		end
		
		error(
			string.format(
				"%d:%d:Parser: Unexpected %s '%s' when parsing Type",
				Current.Line,
				Current.Column,
				Current.Tag,
				Current[Current.Tag]
			)
		)
	end
	
	error("Parser: Unexpected EOF when parsing Type")
end

local function CreateStatementFromTokens(Tokens: {Token}, Index: number): (Statement, number)
	local Current = Tokens[Index]
	
	while Current do
		if Current.Tag == "Keyword" then
			if Current.Keyword == "return" then
				local Value, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
				
				return {
					Tag = "Return",
					Value = Value
				}, Offset
			end
			
			if Current.Keyword == "let" then
				Index += 1
				Current = Tokens[Index]
				
				if Current then
					if Current.Tag == "Identifier" then
						local Name = Current
						
						Index += 1
						Current = Tokens[Index]
						
						if Current then
							if Current.Tag == "Symbol" and Current.Symbol == "=" then
								local Value, Offset = CreateExpressionFromTokens(Tokens, Index + 1)
								
								return {
									Tag = "Let",
									Name = Name,
									Value = Value
								}, Offset
							end
							
							error(
								string.format(
									"%d:%d:Parser: Unexpected %s '%s' when parsing Type",
									Current.Line,
									Current.Column,
									Current.Tag,
									Current[Current.Tag]
								)
							)
						end
						
						error("Parser: Unexpected EOF when parsing Statement")
					end
					
					error(
						string.format(
							"%d:%d:Parser: Unexpected %s '%s' when parsing Statement",
							Current.Line,
							Current.Column,
							Current.Tag,
							Current[Current.Tag]
						)
					)
				end
				
				error("Parser: Unexpected EOF when parsing Statement")
			end
			
			if Current.Keyword == "do" then
				Index += 1
				Current = Tokens[Index]
				
				local Block = {}
				
				while Current do
					if Current.Tag == "Keyword" and Current.Keyword == "end" then
						return {
							Tag = "Do",
							Block = Block
						}, Index + 1
					end
					
					local Statement, Offset = CreateStatementFromTokens(Tokens, Index)
					
					table.insert(Block, Statement)
					
					Index = Offset
					Current = Tokens[Index]
				end
				
				error("Parser: Unexpected EOF when parsing Statement")
			end
			
			if Current.Keyword == "if" then
				local Condition, Offset = CreateExpressionFromTokens(Tokens, Index)
				
				Index = Offset
				Current = Tokens[Index]
				
				if Current.Tag == "Keyword" then
					Index += 1
					Current = Tokens[Index]
					
					local Passing = {}
					
					while Current do
						if Current.Tag == "Keyword" then
							if Current.Keyword == "else" then
								Index += 1
								Current = Tokens[Index]
								
								local Failing = {}
								
								while Current do
									if Current.Tag == "Keyword" and Current.Keyword == "end" then
										return {
											Tag = "If",
											Condition = Condition,
											Passing = Passing,
											Failing = Failing
										}, Index + 1
									end
									
									local Statement, Offset = CreateStatementFromTokens(Tokens, Index)
									
									table.insert(Failing, Statement)
									
									Index = Offset
									Current = Tokens[Index]
								end
								
								error("Parser: Unexpected EOF when parsing Statement")
							end
							
							if Current.Keyword == "end" then
								return {
									Tag = "If",
									Condition = Condition,
									Passing = Passing,
									Failing = {}
								}, Index + 1
							end
						end
						
						local Statement, Offset = CreateStatementFromTokens(Tokens, Index)
						
						table.insert(Passing, Statement)
						
						Index = Offset
						Current = Tokens[Index]
					end
					
					error("Parser: Unexpected EOF when parsing Statement")
				end
			end
			
			if Current.Keyword == "function" then
				Index += 1
				Current = Tokens[Index]
				
				if Current then
					if Current.Tag == "Identifier" then
						local FunctionName = Current
						
						Index += 1
						Current = Tokens[Index]
						
						if Current then
							if Current.Tag == "Symbol" and Current.Symbol == "(" then
								Index += 1
								Current = Tokens[Index]
								
								local Parameters = {}
								
								while Current do
									if Current.Tag == "Symbol" and Current.Symbol == ")" then
										Index += 1
										Current = Tokens[Index]
										
										local Block = {}
										
										while Current do
											if Current.Tag == "Keyword" and Current.Keyword == "end" then
												return {
													Tag = "Function",
													Name = FunctionName,
													Parameters = Parameters,
													Block = Block
												}, Index + 1
											end
											
											local Statement, Offset = CreateStatementFromTokens(Tokens, Index)
											
											table.insert(Block, Statement)
											
											Index = Offset
											Current = Tokens[Index]
										end
										
										error("Parser: Unexpected EOF when parsing Statement")
									end
									
									if Current.Tag == "Identifier" then
										local ParameterName = Current
										
										Index += 1
										Current = Tokens[Index]
										
										if Current then
											if Current.Tag == "Symbol" and Current.Symbol == ":" then
												local Type, Offset = CreateTypeFromTokens(Tokens, Index + 1)
												
												table.insert(
													Parameters,
													{
														Name = ParameterName,
														Type = Type
													}
												)
												
												Index = Offset
												Current = Tokens[Index]
												
												if Current.Tag == "Symbol" then
													if Current.Symbol == "," then
														Index += 1
														Current = Tokens[Index]
														
														continue
													end
													
													if Current.Symbol == ")" then
														continue
													end
												end
												
												error(
													string.format(
														"%d:%d:Parser: Unexpected %s '%s' when parsing Statement",
														Current.Line,
														Current.Column,
														Current.Tag,
														Current[Current.Tag]
													)
												)
											end
											
											error(
												string.format(
													"%d:%d:Parser: Unexpected %s '%s' when parsing Statement",
													Current.Line,
													Current.Column,
													Current.Tag,
													Current[Current.Tag]
												)
											)
										end
										
										error("Parser: Unexpected EOF when parsing Statement")
									end
								end
								
								error("Parser: Unexpected EOF when parsing Statement")
							end
							
							error(
								string.format(
									"%d:%d:Parser: Unexpected %s '%s' when parsing Statement",
									Current.Line,
									Current.Column,
									Current.Tag,
									Current[Current.Tag]
								)
							)
						end
						
						error("Parser: Unexpected EOF when parsing Statement")
					end
					
					error(
						string.format(
							"%d:%d:Parser: Unexpected %s '%s' when parsing Statement",
							Current.Line,
							Current.Column,
							Current.Tag,
							Current[Current.Tag]
						)
					)
				end
				
				error("Parser: Unexpected EOF when parsing Statement")
			end
			
			error(
				string.format(
					"%d:%d:Parser: Unexpected Keyword '%s' when parsing Statement",
					Current.Line,
					Current.Column,
					Current.Keyword
				)
			)
		end
		
		error(
			string.format(
				"%d:%d:Parser: Unexpected %s '%s' when parsing Statement",
				Current.Line,
				Current.Column,
				Current.Tag,
				Current[Current.Tag]
			)
		)
	end
	
	error("Parser: Unexpected EOF when parsing Statement")
end

local function Parse(Tokens: {Token}): {Statement}
	local Program = {}
	local Index = 1
	
	while Tokens[Index] do
		local Statement, Offset = CreateStatementFromTokens(Tokens, Index)
		
		Index = Offset
		table.insert(Program, Statement)
	end
	
	return Program
end

-- Checker

local function IsConversionSafe(Left: number, Right: number): boolean
	return
		(Left <= 127 and Left >= -128) and (Right <= 127 and Right >= -128)
		or
		(Left >= 0 and Left <= 255) and (Right >= 0 and Right <= 255)
end

local function EvaluateNegate(Right: {number}, Context: Context): {number}
	local Result = {}
	
	for Index, Value in Right do
		if Right == -128 then
			error(
				string.format(
					"%d:%d:Checker: Cannot Negate '-128'",
					Context.Line,
					Context.Column
				)
			)
		end
		
		table.insert(
			Result,
			-Value
		)
	end
	
	return Result
end

local function EvaluateNot(Right: {number}, Context: Context): {number}
	local Result = {}
	
	for Index, Value in Right do
		table.insert(
			Result,
			Value == 0 and 1 or 0
		)
	end
	
	return Result
end

local function EvaluateMultiplication(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				local Output = LeftValue * RightValue
				
				if Output < -128 or Output > 255 then
					error(
						string.format(
							"%d:%d:Checker: Cannot Multiplication '%d' with '%d'",
							Context.Line,
							Context.Column,
							LeftValue,
							RightValue
						)
					)
				end
				
				table.insert(
					Result,
					Output
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateDivision(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				local Output = LeftValue / RightValue
				
				if Output < 0 then
					Output = math.ceil(Output)
				else
					Output = math.round(Output)
				end
				
				if Output < -128 or Output > 255 then
					error(
						string.format(
							"%d:%d:Checker: Cannot Divide '%d' with '%d'",
							Context.Line,
							Context.Column,
							LeftValue,
							RightValue
						)
					)
				end
				
				table.insert(
					Result,
					Output
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateRemainder(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				if RightValue <= 0 then
					error(
						string.format(
							"%d:%d:Checker: Cannot Remainder '%d' with '%d'",
							Context.Line,
							Context.Column,
							LeftValue,
							RightValue
						)
					)
				end
				
				local Output = LeftValue % RightValue
				
				if Result < -128 or Result > 255 then
					error(
						string.format(
							"%d:%d:Checker: Cannot Remainder '%d' with '%d'",
							Context.Line,
							Context.Column,
							LeftValue,
							RightValue
						)
					)
				end
				
				table.insert(
					Result,
					Output
				)
				
				continue
			end
			
			error(
				string.format(
					"Checker: Cannot Convert '%d' with '%d'",
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateAddition(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				local Output = LeftValue + RightValue
				
				if Output < -128 or Output > 255 then
					error(
						string.format(
							"%d:%d:Checker: Cannot Add '%d' with '%d'",
							Context.Line,
							Context.Column,
							LeftValue,
							RightValue
						)
					)
				end
				
				table.insert(
					Result,
					Output
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateSubtraction(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				local Output = LeftValue - RightValue
				
				if Output < -128 or Output > 255 then
					error(
						string.format(
							"%d:%d:Checker: Cannot Subtract '%d' with '%d'",
							Context.Line,
							Context.Column,
							LeftValue,
							RightValue
						)
					)
				end
				
				table.insert(
					Result,
					Output
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateLesser(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				table.insert(
					Result,
					LeftValue < RightValue and 1 or 0
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateLesserEqual(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				table.insert(
					Result,
					LeftValue <= RightValue and 1 or 0
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateGreater(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				table.insert(
					Result,
					LeftValue > RightValue and 1 or 0
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateGreaterEqual(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				table.insert(
					Result,
					LeftValue >= RightValue and 1 or 0
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateEqual(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				table.insert(
					Result,
					LeftValue == RightValue and 1 or 0
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateNotEqual(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			if IsConversionSafe(LeftValue, RightValue) then
				table.insert(
					Result,
					LeftValue ~= RightValue and 1 or 0
				)
				
				continue
			end
			
			error(
				string.format(
					"%d:%d:Checker: Cannot Convert '%d' with '%d'",
					Context.Line,
					Context.Column,
					LeftValue,
					RightValue
				)
			)
		end
	end
	
	return Result
end

local function EvaluateAnd(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			table.insert(
				Result,
				(Left ~= 0 and Right ~= 0) and 1 or 0
			)
		end
	end
	
	return Result
end

local function EvaluateOr(Left: {number}, Right: {number}, Context: Context): {number}
	local Result = {}
	
	for LeftIndex, LeftValue in Left do
		for RightIndex, RightValue in Right do
			table.insert(
				Result,
				(Left ~= 0 or Right ~= 0) and 1 or 0
			)
		end
	end
	
	return Result
end

local function GetIdentifiersFromExpression(Expression: Expression, Array: {string}): {string}
	if Expression.Tag == "Identifier" then
		table.insert(Array, Expression.Identifier)
	end
	
	if Expression.Tag == "Unary" then
		GetIdentifiersFromExpression(Expression.Right, Array)
	end
	
	if Expression.Tag == "Binary" then
		GetIdentifiersFromExpression(Expression.Left, Array)
		GetIdentifiersFromExpression(Expression.Right, Array)
	end
	
	return Array
end

local GetTypeFromExpression

local function Refine(Condition: Expression, State: State, Definitions: {[string]: Function}, Context: Context): (State, State)
	local InternalState = {}
	
	for Index, Name in GetIdentifiersFromExpression(Condition, {}) do
		local Type = State[Name]
		
		if not Type then
			error(
				string.format(
					"%d:%d:Checker: Identifier '%s' has not been defined",
					Context.Line,
					Context.Column,
					Name
				)
			)
		end
		
		InternalState[Name] = Type
	end
	
	local Passing = {}
	local Failing = {}
	
	--[[
	X: 0, 1
	Y: 2, 3
	Z: 4, 5
	
	{X: 0, Y: 2, Z: 4}
	{X: 0, Y: 2, Z: 5}
	{X: 0, Y: 3, Z: 4}
	{X: 0, Y: 3, Z: 5}
	{X: 1, Y: 2, Z: 4}
	{X: 1, Y: 2, Z: 5}
	{X: 1, Y: 3, Z: 4}
	{X: 1, Y: 3, Z: 5}
	]]--
	for Name in InternalState do
		Passing[Name] = {}
		Failing[Name] = {}
	end
	
	for OuterName, OuterType in InternalState do
		for OuterIndex, OuterValue in OuterType do
			for InnerName, InnerType in InternalState do
				if OuterName == InnerName then
					continue
				end
				
				for InnerIndex, InnerValue in InnerType do
					local Type = GetTypeFromExpression(
						Condition,
						{
							[OuterName] = {OuterValue},
							[InnerName] = {InnerValue}
						},
						Definitions,
						Context
					)
					
					local Result = Type[1]
					
					if not Result then
						error("Internal: Refinement result was empty")
					end
					
					if Result ~= 0 then
						table.insert(Passing[OuterName], OuterValue)
						table.insert(Passing[InnerName], InnerValue)
					else
						table.insert(Failing[OuterName], OuterValue)
						table.insert(Failing[InnerName], InnerValue)
					end
				end
			end
		end
	end
	
	for Name, Type in State do
		if not Passing[Name] then
			Passing[Name] = Type
		end
		
		if not Failing[Name] then
			Failing[Name] = Type
		end
	end
	
	return Passing, Failing
end

local EvaluateCall

local function EvaluateBlock(Block: {Statement}, State: {[string]: {number}}, Definitions: {[string]: Function}, Context: Context): {number}
	local Result = {}
	local HasReturn = false
	
	for Index, Statement in Block do
		if HasReturn then
			error(
				string.format(
					"%d:%d:Checker: Statements after Return",
					Context.Line,
					Context.Column
				)
			)
		end
		
		if Statement.Tag == "Return" then
			HasReturn = true
			
			local Type = GetTypeFromExpression(Statement.Value, State, Definitions, Context)
			
			for Index, Value in Type do
				table.insert(
					Result,
					Value
				)
			end
			
			Statement.Type = Type
			
			continue
		end
		
		if Statement.Tag == "Let" then
			if State[Statement.Name.Identifier] then
				error(
					string.format(
						"%d:%d:Checker: Variable '%s' is already defined",
						Context.Line,
						Context.Column,
						Statement.Name.Identifier
					)
				)
			end
			
			local Type = GetTypeFromExpression(Statement.Value, State, Definitions, Context)
			
			State[Statement.Name.Identifier] = Type
			Statement.Type = Type
			
			continue
		end
		
		if Statement.Tag == "If" then
			local PassingState, FailingState = Refine(Statement.Condition, State, Definitions, Context)
			
			local PassingResult = EvaluateBlock(Statement.Passing, PassingState, Definitions, Context)
			local FailingResult = EvaluateBlock(Statement.Failing, FailingState, Definitions, Context)
			
			for Index, Value in PassingResult do
				table.insert(
					Result,
					Value
				)
			end
			
			for Index, Type in FailingResult do
				table.insert(
					Result,
					Type
				)
			end
			
			continue
		end
		
		if Statement.Tag == "Function" then
			if Definitions[Statement.Name.Identifier] then
				error(
					string.format(
						"%d:%d:Checker: Function '%s' is already defined",
						Context.Line,
						Context.Column,
						Statement.Name.Identifier
					)
				)
			end
			
			local Arguments = {}
			
			for Index, Parameter in Statement.Parameters do
				table.insert(Arguments, Parameter.Type)
			end
			
			Statement.Type = EvaluateCall(Statement, Arguments, State, Definitions, Context)
			
			Definitions[Statement.Name.Identifier] = Statement
			
			continue
		end
		
		error(
			string.format(
				"%d:%d:Internal: Statement Tag '%s' is Unknown",
				Context.Line,
				Context.Column,
				Statement.Tag
			)
		)
	end
	
	return Result
end

EvaluateCall = function(Function: Function, Arguments: {{number}}, State: {[string]: {number}}, Definitions: {[string]: Function}, Context: Context): {number}
	local NewState = table.clone(State)
	local NewDefinitions = table.clone(Definitions)
	
	NewDefinitions[Function.Name.Identifier] = nil
	
	for Index, Type in Arguments do
		local Parameter = Function.Parameters[Index]
		
		if Parameter then
			for Index, Value in Type do
				if table.find(Parameter.Type, Value) then
					NewState[Parameter.Name.Identifier] = Type
					
					continue
				end
				
				error(
					string.format(
						"%d:%d:Checker: Cannot Call '%s' with Improper Type for Parameter '%s'",
						Context.Line,
						Context.Column,
						Function.Name.Identifier,
						Parameter.Name.Identifier
					)
				)
			end
			
			continue
		end
		
		error(
			string.format(
				"%d:%d:Checker: Cannot Call '%s' with Extra Argument",
				Context.Line,
				Context.Column,
				Function.Name.Identifier
			)
		)
	end
	
	return EvaluateBlock(Function.Block, NewState, NewDefinitions, Context)
end

GetTypeFromExpression = function(Expression: Expression, State: {[string]: {number}}, Definitions: {[string]: Function}, Context: Context): {number}
	if Expression.Tag == "Literal" then
		return {Expression.Literal}
	end
	
	if Expression.Tag == "Identifier" then
		local Type = State[Expression.Identifier]
		
		if Type then
			return Type
		end
		
		error(
			string.format(
				"%d:%d:Checker: Identifier '%s' is not Defined",
				Context.Line,
				Context.Column,
				Expression.Identifier
			)
		)
	end
	
	if Expression.Tag == "Unary" then
		local Right = GetTypeFromExpression(Expression.Right, State, Definitions, Context)
		
		if Expression.Operation == "Negate" then
			return EvaluateNegate(Right, Context)
		end
		
		if Expression.Operation == "Not" then
			return EvaluateNot(Right, Context)
		end
		
		error(
			string.format(
				"Internal: Expression Operation '%s' is Unknown",
				Expression.Operation
			)
		)
	end
	
	if Expression.Tag == "Binary" then
		local Left = GetTypeFromExpression(Expression.Left, State, Definitions, Context)
		local Right = GetTypeFromExpression(Expression.Right, State, Definitions, Context)
		
		if Expression.Operation == "Multiplication" then
			return EvaluateMultiplication(Left, Right, Context)
		end
		
		if Expression.Operation == "Division" then
			return EvaluateDivision(Left, Right, Context)
		end
		
		if Expression.Operation == "Remainder" then
			return EvaluateRemainder(Left, Right, Context)
		end
		
		if Expression.Operation == "Addition" then
			return EvaluateAddition(Left, Right, Context)
		end
		
		if Expression.Operation == "Subtraction" then
			return EvaluateSubtraction(Left, Right, Context)
		end
		
		if Expression.Operation == "Lesser" then
			return EvaluateLesser(Left, Right, Context)
		end
		
		if Expression.Operation == "LesserEqual" then
			return EvaluateLesserEqual(Left, Right, Context)
		end
		
		if Expression.Operation == "Greater" then
			return EvaluateGreater(Left, Right, Context)
		end
		
		if Expression.Operation == "GreaterEqual" then
			return EvaluateGreaterEqual(Left, Right, Context)
		end
		
		if Expression.Operation == "Equal" then
			return EvaluateEqual(Left, Right, Context)
		end
		
		if Expression.Operation == "NotEqual" then
			return EvaluateNotEqual(Left, Right, Context)
		end
		
		if Expression.Operation == "And" then
			return EvaluateAnd(Left, Right, Context)
		end
		
		if Expression.Operation == "Or" then
			return EvaluateOr(Left, Right, Context)
		end
		
		error(
			string.format(
				"Internal: Expression Operation '%s' is Unknown",
				Expression.Operation
			)
		)
	end
	
	if Expression.Tag == "Call" then
		local Function = Definitions[Expression.Name.Identifier]
		
		if Function then
			local Types = {}
			
			for Index, Argument in Expression.Arguments do
				table.insert(
					Types,
					GetTypeFromExpression(Argument, State, Definitions, Context)
				)
			end
			
			return EvaluateCall(Function, Types, State, Definitions, Context)
		end
		
		error(
			string.format(
				"%d:%d:Checker: Function '%s' is not defined",
				Context.Line,
				Context.Column,
				Expression.Name.Identifier
			)
		)
	end
	
	error(
		string.format(
			"%d:%d:Internal: Expression Tag '%s' is Unknown",
			Context.Line,
			Context.Column,
			Expression.Tag
		)
	)
end

local function Check(Program: {Statement}): {number}
	local Context = {
		Line = 0,
		Column = 0
	}
	
	return EvaluateBlock(Program, {}, {}, Context)
end


-- Compiler

local function GetIsSignedFromStatement(Statement: Let | Return | Function): boolean
	if Statement.Type then
		for Index, Value in Statement.Type do
			if Value < 0 then
				return true
			end
		end
	end
	
	return false
end

local function GetStringFromExpression(Expression: Expression): string
	if Expression.Tag == "Literal" then
		return string.format(
			"(%d)",
			Expression.Literal
		)
	end
	
	if Expression.Tag == "Identifier" then
		return Expression.Identifier
	end
	
	if Expression.Tag == "Unary" then
		local Right = GetStringFromExpression(Expression.Right)
		
		if Expression.Operation == "Not" then
			return string.format(
				"(!%s)",
				Right
			)
		end
		
		if Expression.Operation == "Negate" then
			return string.format(
				"(-%s)",
				Right
			)
		end
	end
	
	if Expression.Tag == "Binary" then
		local Left = GetStringFromExpression(Expression.Left)
		local Right = GetStringFromExpression(Expression.Right)
		
		if Expression.Operation == "Multiplication" then
			return string.format(
				"(%s*%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Division" then
			return string.format(
				"(%s/%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Remainder" then
			return string.format(
				"(%s%%%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Addition" then
			return string.format(
				"(%s+%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Subtraction" then
			return string.format(
				"(%s-%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Lesser" then
			return string.format(
				"(%s<%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "LesserEqual" then
			return string.format(
				"(%s<=%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Greater" then
			return string.format(
				"(%s>%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "GreaterEqual" then
			return string.format(
				"(%s>=%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Equal" then
			return string.format(
				"(%s==%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "NotEqual" then
			return string.format(
				"(%s!=%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "And" then
			return string.format(
				"(%s&&%s)",
				Left,
				Right
			)
		end
		
		if Expression.Operation == "Or" then
			return string.format(
				"(%s||%s)",
				Left,
				Right
			)
		end
	end
	
	if Expression.Tag == "Call" then
		local Result = Expression.Name.Identifier .. "("
		
		for Index, Argument in Expression.Arguments do
			if Index > 1 then
				Result ..= ","
			end
			
			Result ..= GetStringFromExpression(Argument)
		end
		
		return Result .. ")"
	end
	
	error(
		string.format(
			"Internal: Operation Tag '%s' is Unknown",
			Expression.Tag
		)
	)
end

local function GetStringFromStatement(Statement: Statement): string
	if Statement.Tag == "Return" then
		return string.format(
			"return %s;",
			GetStringFromExpression(Statement.Value)
		)
	end
	
	if Statement.Tag == "Let" then
		local IsSigned = GetIsSignedFromStatement(Statement)
		
		if IsSigned then
			return string.format(
				"const char %s=%s;",
				Statement.Name.Identifier,
				GetStringFromExpression(Statement.Value)
			)
		else
			return string.format(
				"const unsigned char %s=%s;",
				Statement.Name.Identifier,
				GetStringFromExpression(Statement.Value)
			)
		end
	end
	
	if Statement.Tag == "If" then
		local Result = string.format(
			"if(%s){",
			GetStringFromExpression(Statement.Condition)
		)
		
		for Index, Instruction in Statement.Passing do
			Result ..= GetStringFromStatement(Instruction)
		end
		
		if #Statement.Failing > 0 then
			Result ..= "}else{"
			
			for Index, Instruction in Statement.Failing do
				Result ..= GetStringFromStatement(Instruction)
			end
		else
			Result ..= "}"
		end
	end
	
	error(
		string.format(
			"Internal: Statement Tag '%s' is Unknown",
			Statement.Tag
		)
	)
end

local function Compile(Program: {Statement}): string
	local Header = "#include<stdio.h>\n"
	local Result = "int main(void){"
	
	for Index, Statement in Program do
		if Statement.Tag == "Return" then
			local IsSigned = GetIsSignedFromStatement(Statement)
			local String = GetStringFromExpression(Statement.Value)
			
			if IsSigned then
				Result ..= string.format(
					"printf(\"%%d\",%s);",
					String
				)
			else
				Result ..= string.format(
					"printf(\"%%u\",%s);",
					String
				)
			end
			
			continue
		end
		
		if Statement.Tag == "Let" then
			local IsSigned = GetIsSignedFromStatement(Statement)
			local String = GetStringFromExpression(Statement.Value)
			
			if IsSigned then
				Header ..= string.format(
					"static const char %s=%s;",
					Statement.Name.Identifier,
					String
				)
			else
				Header ..= string.format(
					"static const unsigned char %s=%s;",
					Statement.Name.Identifier,
					String
				)
			end
			
			continue
		end
		
		if Statement.Tag == "If" then
			Result ..= string.format(
				"if(%s){",
				GetStringFromExpression(Statement.Condition)
			)
			
			for Index, Instruction in Statement.Passing do
				Result ..= GetStringFromStatement(Instruction)
			end
			
			if #Statement.Failing > 0 then
				Result ..= "}else{"
				
				for Index, Instruction in Statement.Failing do
					Result ..= GetStringFromStatement(Instruction)
				end
			else
				Result ..= "}"
			end
			
			continue
		end
		
		if Statement.Tag == "Function" then
			local IsSigned = GetIsSignedFromStatement(Statement)
			
			if IsSigned then
				Header ..= string.format(
					"static char %s(",
					Statement.Name.Identifier
				)
			else
				Header ..= string.format(
					"static unsigned char %s(",
					Statement.Name.Identifier
				)
			end
			
			if #Statement.Parameters == 0 then
				Header ..= "void){"
			else
				for Index, Parameter in Statement.Parameters do
					local IsSigned = false
					
					for Index, Value in Parameter.Type do
						if Value < 0 then
							IsSigned = true
							break
						end
					end
					
					if Index > 1 then
						Header ..= ","
					end
					
					if IsSigned then
						Header ..= string.format(
							"const char %s",
							Parameter.Name.Identifier
						)
					else
						Header ..= string.format(
							"const unsigned char %s",
							Parameter.Name.Identifier
						)
					end
				end
				
				Header ..= "){"
			end
			
			for Index, Instruction in Statement.Block do
				Header ..= GetStringFromStatement(Instruction)
			end
			
			Header ..= "}"
			
			continue
		end
		
		error(
			string.format(
				"Internal: Statement Tag '%s' is Unknown",
				Statement.Tag
			)
		)
	end
	
	return string.format(
		"%s%sreturn 0;}",
		Header,
		Result
	)
end


-- Run

local function Run(Source: string): string
	return Compile(Parse(Lex(Source)))
end

print(
	Run(
	[[
		return 0
	]]
	)
)

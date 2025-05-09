# The W Programming Language
W is a programming language which implements a theoretical value-based typesystem that compiles to portable C90 source.

```txt
function Add(Value: 0..10)
	return Value + 1
end

return Add(2)
```

## Design
There are a few primary components that make up a source-file in W:

* **Identifiers**: Strings of characters starting with an uppercase alphabetical character followed by alphanumeric and terminated by a whitespace character or separator.
`ThisIsAnIdentifier`, `Abc123`

* **Keywords**: Reserved all-lowercase identifiers which are used to create certain language concepts.
`function`, `let`, `and`

* **Literals**: Strings of numerical characters which may start with a dash (negative) and are terminated by a whitespace character or separator. A negative zero is not allowed.
`0`, `3541`, `-92`

* **Symbols**: Non-alphanumeric characters which are used to form operations or separate groups of concepts. They are whitespace-independent.
`+`, `*`, `==`

***

Source code is written with the traditional concept of lexical scoping, with the first implicit scope allowing only special statements called items:

* **Functions**: These define a construct that takes an input of specific parameters and outputs a return. Parameters require an annotation to describe what kinds of values they allow, but do not require a return annotation because it can be inferred.
`function Identifier(Identifier: Type, Identifier: Type) end`

* **Returns**: There is only one main return allowed, which determines the output of the program. The return value can be any valid expression, which is usually an initial function call.
`return Expression`

***

Function bodies are blocks, which are groups of statements that describe what the function should do in a linear fashion:

* **Variables**: Define constant variables that link an identifier to an expression’s result.
`let Identifier = Expression`

* **Do-Blocks**: Create more blocks to encapsulate statements.
`do end`

* **Conditionals**: Define conditional blocks that, if the conditional expression evaluates a non-zero value, will run. If an optional else-clause is added, it will run instead if the conditional fails.
`if Expression then end`
`if Expression then else end`

Returns are also statements allowed inside function bodies, as long as there is at least one unconditional return. No other statement may proceed a return statement.

***

Expressions are combinations of operations between other expressions called terms. There are two unary (single-term) expressions:

* **Negation**: Flips the sign of the operand. The operand cannot be above `2^63 - 1`.
`-Term`

* **Not**: Evaluates to 1 if the operand is 0, and 0 otherwise.
`not Term`

There are also seven binary (double-term) expressions:

* **And**: Evaluates to 1 if both the operands are not 0, or 0 if otherwise.
`Term and Term`

* **Or**: Evaluates to 1 if at least one operand is not 0, or 0 if otherwise.
`Term or Term`

* **Addition**: Evaluates the sum of the operands. The result cannot be above `2^64 - 1` or below `-2^63`.
`Term + Term`

* **Subtraction**: Evaluates the difference of the operands. The result cannot be above `2^64 - 1` or below `-2^63`.
`Term - Term`

* **Multiplication**: Evaluates the product of the operands. The result cannot be above `2^64 - 1` or below `-2^63`.
`Term * Term`

* **Division**: Evaluates the quotient of the operands. The second operand cannot be 0, and the result cannot be above `2^64 - 1` or below `-2^63`.
`Term / Term`

* **Remainder**: Evaluates the remainder (or modulus) of a division between the operands. The first operand must be 0 or above, while the second operand must be 1 or above, and the result cannot be above `2^64 - 1` or below `-2^63`.
`Term % Term`

***

Every identifier, literal and expression in W has a type associated with it, representing every value it could hold. Parameters are the only place where types must be annotated.

This allows for the compiler to prevent potentially dangerous operations such as Divide-By-Zero or Integer Overflowing from occurring.

```txt
function Divide(Value: 0..10)
	-- Value could be 0; not compiled
	return 50 / Value
end
```

> [Further Typesystem Information](https://github.com/WalkerTrott/W-Lang/blob/main/Typesystem.md)

****

The W compiler implementation is split into four parts:

* **Lexing**: Breaks up a source-file into tokens for the parser to process, warning about any illegal characters, keywords or literals that may appear.

* **Parsing**: Parses the created tokens into a syntax tree, warning about illegal or missing program structures.

* **Checking**: Validates the integrity of the program by evaluating every expression's type and warning about any potential errors.

* **Compiling**: Converts the validated tree into a compatible C90 source-file that respects other C and C++ standards, to maximize portability.

# W Programming Language
W is an experimental imperative programming language which implements a theoretical value-based type-system that compiles to portable C90 source.
Its philosophy and goals in respect of importance include program correctness, speed (runtime over compiling), consistency and simplicity.

```txt
function Add(Value: 0..10)
{
	return Value + 1;
}

return Add(2);
```

## Design
### File Structure
The components that make up a source-file are **Identifiers**, **Keywords**, **Literals**, **Operators**, **Separators** and **Parentheses**.

> Identifiers are groups of characters starting with an alphabetical character followed by alphanumeric or underscore characters and terminated by a whitespace or separator.
> The preferred style for identifiers is `PascalCase`, which is enforced by the checker.
> 
> `ThisIsAnIdentifier`, `Abc123`

> Keywords are reserved all-lowercase identifiers which are used to create construct certain language concepts.
> 
> `function`, `let`, `and`

> Literals (currently only numerical integers) are strings of numerical numbers which may start with a dash (negative) and are terminated by a whitespace or separator.
> Note that the negative sign is not a unary negate operator, but a part of the literal when paired with a numeric constant.
> 
> `0`, `3541`, `-92`

> Operators are non-alphanumeric characters which are used to form unary or binary operations.
> 
> `+`, `*`, `==`

> Separators are punctuation characters which separate concepts.
> 
> `,`, `.`, `:`, `;`

> Parentheses define scopes, order of operations and function calls.
> 
> `{}`, `()`


Unlike other languages, each token for the language has specific whitespace rules that are required to parse correctly.
Expressions also need to be grouped in parentheses when combined, both to prevent order-of-operation issues as well as simplifying parsing.

> For example, a function formatted like this would not parse.
> ```txt
> 	function  Identifier (Identifier :Type,Identifer : Type)   {
> }
> ```

> Instead, the function would always have to be formatted as such.
> ```txt
> function Identifier(Identifier: Type, Identifier: Type)
> {
> }

Source code is written with the traditional concept of lexical scoping, with the first scope allowing only **Item** definitions.
There are three items, **Definitions**, **Functions** and **Program Returns**

> Definitions create static and constant variables with an identifier and expression.
> 
> `define Identifier = Expression`

> Functions start with the function keyword followed by an identifier for their name.
> An arbitrary number of arguments one to eight can be defined in identifier-colon-type-comma format.
> A type annotation after the header is not needed because the return type can be deduced based on the body.
> 
> ```txt
> function Identifier(Identifier: Type)
> {
> }
> 
> function Identifier(Identifier: Type, Identifier: Type)
> {
> }
> ```

> There is always one program return allowed, which determines the output of the program.
> The return can be any valid expression, usually an initial function call.
> 
> `return Expression;`

### Blocks, Statements and Expressions
Inside items are **Blocks**, **Statements** and **Expressions**.

> Blocks are collections of statements separated with semicolons.
> These are grouped between braces.
> 
> ```txt
> {
> 	Statement;
> 	Statement;
> }
> ```

> Statements are single instructions that define or construct a concept.
> They usually start with keywords and end with a semicolon, unless they are composed with blocks.
> 
> `define Name = 1;`, `if Value {} else {}`

> Expressions are combinations of operations between literals and/or variables.
> Expressions evaluate to one value and can be combined together.
> There are unary (single operand) and binary (double operand) expressions.
> 
> `-Value`, `Function(Argument)`
> `400 + 2`, `Value * (-32 / (Value - 1))`

### Statements
There are four types of statements, **Define**, **Let**, **If-Else** and **Return**.

> Let statements define a constant, non-static value to a unique identifier.
> The value must be of a complex type, meaning it cannot be simple.
> 
> `let Identifier = Expression;`

> If-else statements take an expression as a conditional and executes the following block if the expression yields to not 0 at runtime.
> If an else-clause is added, its block will execute instead if the expression yields 0.
> The conditional must be a complex type.
> 
> `if Expression {}`, `if Expression {} else {}`

> Return statements exit a function with an expression.
> Different return statements can be nested within if-statement blocks, but the combined type must be complex and equal the function's return type.
> 
> `return Expression;`

### Typesystem
There are two forms of types, **Simple Types** and **Complex Types**.

> Simple types are single values which represent a single literal.
> 
> `1`, `-3629`

> Complex types are unions of simple types which represent multiple possible values.
> Ranges are unions of every simple type between a start and end value.
> 
> `1|3|5`, `0..5`

Parameters are the only place where types must be annotated, and there they must be complex.
All other variables and return types can be deduced based on the possible values based of each parameter.

This allows for the checker to properly analyze logic such as if-else statements and prevent any unnecessary or bug-prone calculations.
This also prevents potentially illegal operations such as divide-by-zero or integer overflowing from occurring.

> ```txt
> function Divide(Value: 0..10)
> {
> 	# Value could be 0; not compiled
> 	return 50 / Value
> }
> ```

### Internals
There are three parts to the language, the **Lexer**, **Parser**, **Checker** and **Compiler**.

> The Lexer breaks up a source-file string into tokens, such as identifiers, keywords, literals, operators, separators and parentheses.
> All literals can be in a range of `-9223372036854775808` to `9223372036854775807`, or `0` to `18446744073709551615`, or any representable interval in between.
> These literals are stored as a union, but they are compiled to use the smallest integer type they need.
> If an illegal literal, keyword or character is found, the Lexer immediately aborts compilation and sends the error through the pipeline.

> The Parser transforms the lexed tokens into an Abstract Syntax Tree, which describes how the program structure works.
> If the order of some tokens are illegal, the Parser buffers every error and then aborts compilation while sending the error through the pipeline.

> The Checker goes over the Abstract Syntax Tree and checks the types, values and statements to determine if they are allowed.
> If a value passed for an operation has a conflicting type with the allowed type, then it is flagged and propagates through the error pipeline.

> The Compiler converts the validated Abstract Syntax Tree into a single valid C90 source-file, which then can be compiled by any supported C or C++ compiler.
> The source is not meant to be read, and instead is minified so second compilation doesn't take too much time.

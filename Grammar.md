# Grammar
## Syntax
W's syntax is not particularly interesting due its largest focus on its typesystem, however there are some design ideas incorporated into it to experiment with simplicity, readability and future-compatibility features, including:

**Annotations are after an Identifier with a Colon**: Annotations should only be added when required, and should be properly separated from their identifiers.

**Keywords are Full Words**: Terse and abbreviated keywords are harder to read and memorize, and only save a few characters of writing at best. Code is also meant to be read, not just written.

**Identifiers are Pascal-Case**: Writing identifiers in pascal-case helps differentiate them from keywords and literals, both for humans and for the compiler. Since lowercase identifiers are not permitted, additional keywords can be added freely without needing any special contextual semantics to preserve backwards-compatibility.

**No Commas after the last Element**: Allowing commas after the last element in any grouping such as in parameters or arrays can lead to all sorts of subtle grammatical mistakes and serves no readability purpose.

**Blocks always have Braces**: Braces provide good visual grouping and languages that allow omitting them pay the price by requiring parenthesis around expressions and allowing easy logical mistakes.

## Specification
An informal EBNF of the language's grammar can be seen as below. Note that whitespace is implied between certain elements.

```ebnf
Character = Letter | Digit ;
  Letter = UppercaseLetter | LowercaseLetter ;
    UppercaseLetter = "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" | "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" | "U" | "V" | "W" | "X" | "Y" | "Z" ;
    LowercaseLetter = "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" | "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" | "u" | "v" | "w" | "x" | "y" | "z" ;
  Digit = "0" | CountingDigit ;
    CountingDigit = "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;

Term = Identifier | Literal ;
  Identifier = UppercaseLetter , { Character } ;
  Literal = "0" | ["-"] , CountingDigit , { Digit } ;

Annotation = Literal | UnionAnnotation | RangeAnnotation ;
  UnionAnnotation = Literal , "|" , Literal , { "|" , Literal } ;
  RangeAnnotation = Literal , ".." , Literal ;

Item = Define | Function | Return;

  Define = "define" , Identifier , "=" , Expression , ";" ;
  Function = "function" , Identifier , "(" , Parameter , { "," , Parameter } , ")" , Block ;

    Parameter = Identifier , ":" , Annotation ;
    Block = "{" , Statement , { Statement } , "}" ;

      Statement = Define | Function | Let | If | Return ;
        Let = "let" , Identifier , "=" , Expression , ";" ;
        If = "if" , Expression , Block , [ "else" , Block ] ;
        Return = "return" , Expression , ";" ;

      Expression = Term | BinaryExpression | UnaryExpression ;
        BinaryExpression = "(" , Expression , "+" | "-" | "*" | "/" | "%" | "and" | "or" , Expression , ")" ;
        UnaryExpression = "(" , "not" | "-" , Expression , ")" ;
```

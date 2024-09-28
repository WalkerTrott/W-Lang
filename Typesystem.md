# Value-Based Typesystem 
## Overview
W's typesystem is based around the idea that types are sets of possible values an expression may produce or an identifier may carry, as opposed to a genre describing how the value should be stored. This allows for the compiler to follow the program's structure and provide better validation, analyzation and optimization.

## Advantages
This form of a typesystem provides many more advantages compared to a classical genre-based counterparts, namely:

**Integer Size Inference**: Because the maximum and minimum values an expression or identifier may hold is already known statically, the compiler can infer exactly how many bits and what signing an integer must require without further annotation by the programmer.

**Static Validation without *Any* Runtime Overhead**: Since all possible values an expression may produce is already known, the compiler can catch unsafe operations such as Divide-By-Zero, Different-Sign-Comparison and Integer Overflowing, completely statically and without any runtime overhead.

**Optimization Analysis**: The compiler can also check if certain expressions will always evaluate to the same value, allowing for extensive linting and optimizations. For example, expressions and conditionals that always return the same results can be constant-folded and evaluated at compile-time.

## Disadvantages
A value-based typesystem does come with some intrinsic disadvantages in comparison to a genre-based one, including but not limited to:

**Increased Compile-Time Complexity**: Because the compiler has to do much more intensive type tracing, a value-based typesystem implementation is bound to be inherently slower. There is always potential for better optimizations and utilization of parallelism in the compiler, however.

**Stricter Constraints and Less Freedom**: While there is less of a need for type annotations due to reliable inferencing, prototyping in a language with a value-based typesystem is harder compared to one with a more dynamic typesystem.  For example, changing a single annotation may require large refactorings of code for the program to compile.

## Concepts
All types can be conceptually defined as singletons or unions, however there are more distinctions designed to provide simpler annotations and compiler optimizations. A description for each type can be seen with the following:

**Singletons**: A single literal representing a value that will always be that literal.

**Unions**: A combination of two or more singletons describing a value that could be any of those literals. A same singleton may only appear once in a union, and literals are ordered least to greatest in an annotation.

**Ranges**: A combination of two singletons, a minimum and a maximum, representing a union of all values between the minimum and maximum inclusively. The minimum must be lesser than the maximum.

## Further Development
While W's implementation of a value-based typesystem is very barebones and supports only basic integer literals, it is possible to extend upon its design and provide support for other features such as width-specific strings, variants and vector-based integers. Compatibility with variable mutation and resource management may also be looked into.

One possible extension that should be pointed out is the possibility of adding a generic data structure that can be associated by its signature. These structures may be able to simultaneously hold mixed arrays, tagged data and other fitting abstractions within a high-level space that maps nicely to the lower-level facilities.

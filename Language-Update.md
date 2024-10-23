# Syntax Changes
There have been multiple changes to the syntax design, notably the removal of curly braces for scoping with the replacement of `is`, `then` and `end` keywords.
Ranges are now defined with the `to` keyword, and semicolons have also become unneeded. Arguments are also named by their parameter.

```text
function Add(Value: 0 to 10) is
    return Value + 1
end

return Add(Value = 2)
```

```text
if Condition then
    return X
else
    return Y
end
```

# Typesystem Changes
The typesystem is now designed to provide perfect interoperability with program code.
Expressions such as operations and function calls are allowed and will yield the set of types they will return.

```text
# 1 to 3 -> 50 | 25 | 16
function F(X: 1 to 3) = 50 / X

# 25 | 16 -> 50 | 32
function G(Y: F(X = 2 | 3)) = Y * 2
```

Types are also now distinguished depending on their context.
There are passive (formal) types and active (passed) types.
When you pass a type to a function or operation, it will be checked against the set of types the passive type allows.

```text
# X is passive 1, 2 or 3
# return is passive 2, 4 or 6
function F(X: 1 to 3) is
    return X * 2
end

# X is active 2 (called 'X)
# return is active 4
return F(X = 2)
```

This provides more robust program validation, in that the result of `F(X = 2)` is known to be `4` at compile time.
This can also allow the frontend to employ better constant folding.

# Future Improvements
There is room for adding dependent types to the type system.
For example, the operation of addition for unsigned 8 bit integers could be described as the following.

```text
function Addition
(
    X: 0 to 255,
    Y: 0 to 255 - X
)
```

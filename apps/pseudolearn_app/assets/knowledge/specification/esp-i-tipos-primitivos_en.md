# Primitive types

The language has five primitive types. Every value belongs to one and only one of them, and the type
of a variable does not change while the program executes.

{{tabla:primitiveTypes}}

## String and character are two types, not one

A character is a single code point; a string is a sequence of characters of unbounded length. They are
not confused and do not implicitly convert into each other. A string is not an array of characters
either: they are two different things and the type system treats them as such.

{{ejemplo:example-esp-tipos-cadena-caracter}}

## The only implicit conversion

An integer value can be used where a real is expected, because that direction loses no information.
The reverse never happens on its own: going from real to integer requires asking for it explicitly with
a built-in function, because deciding whether to truncate or round is a decision of whoever writes the
program and not of the language.

{{ejemplo:example-esp-tipos-conversion-implicita}}

## Range of numeric values

An integer is a sixty-four-bit signed number. A real is a double-precision floating-point number.
Stepping out of those ranges does not wrap around silently: it is a named runtime error.

{{ejemplo:example-esp-tipos-rango}}

## Comparing two reals

Two reals calculated through different paths are almost never exactly equal, so comparing them with
equality is a classic source of programs that seem correct and are not. The language warns about that
comparison instead of letting it pass.

```pseudo
Algorithm CompareReals
  Define a, b As Real
  a <- 0.1 + 0.2
  b <- 0.3
  If a = b Then
    Write "Equal"
  EndIf
EndAlgorithm
```

{{diagnostico:realEqualityComparison}}

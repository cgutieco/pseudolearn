# Declaration and assignment

A declaration introduces a name and fixes a type for it. An assignment stores a value into an already
introduced name. They are two different statements and cannot be written together.

## Declaring several variables at once

A single declaration statement can introduce several names separated by commas. They all receive the
same type, written once at the end.

{{ejemplo:example-esp-declaracion-multiple}}

## Declaring gives no value

A declared and unassigned variable has no default value, and reading it before assigning it is a
failure. The language does not invent a zero or an empty string: a value nobody wrote is not a value.

```pseudo
Algorithm Uninitialized
  Define x As Integer
  Write x
EndAlgorithm
```

{{diagnostico:variableUsedUninitialized}}

## A declaration does not admit an initial value

The type is written at the end of the declaration, so an initial value would have to slip in before the
type and would be indistinguishable from an assignment. Assignment is already a first-class statement
and writing it on the next line teaches exactly the same thing.

```pseudo
Algorithm InitInDeclaration
  Define x As Integer <- 5
EndAlgorithm
```

{{diagnostico:initializationInDeclarationNotAllowed}}

## The target of an assignment

To the left of an assignment there can only be something denoting a place to store: a variable name, an
array element, or an object member. A literal, an expression in parentheses, or the result of an
operation does not denote any place, and writing them there is a named syntax error.

```pseudo
Algorithm InvalidTarget
  10 <- 5
EndAlgorithm
```

{{diagnostico:invalidAssignmentTarget}}

## Evaluation order

First the indices of the target are evaluated, in the order they appear; then the right-hand
expression; then the value is stored. It is the reading order of the text, which is the only one
predictable without knowing the engine.

{{ejemplo:example-esp-declaracion-orden-evaluacion}}

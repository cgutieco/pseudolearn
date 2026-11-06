# Declaration and assignment

A declaration introduces one or more names and fixes their type; with a single name it can also give
it its initial value. An assignment stores a new value into a variable that is already declared.

## Several names in one declaration

A declaration can introduce several names of the same type, separated by commas. The initial value after
the arrow is only allowed when the declaration has a single name.

{{ejemplo:example-esp-declaracion-multiple}}

## No value, no reading

A variable declared without an initial value exists but has no value yet: the language does not invent
a zero or an empty string, and a value nobody wrote is not a value. Reading it before every path that
reaches that point has given it one is an error detected before the program runs.

```pseudo
Algorithm Uninitialized
  Define x As Integer;
  Write x;
EndAlgorithm
```

{{diagnostico:variableUsedUninitialized}}

## Reassigning a variable

`Define` creates variables that can be reassigned as many times as needed. What cannot be reassigned is
the control variable of `For`, which belongs to the loop, and the names introduced by `For Each`, by
patterns of `Switch` over variants and by tasks.

```pseudo
Algorithm ReassignControl
  For i <- 1 To 3 Do
    i <- 5;
  EndFor
EndAlgorithm
```

{{diagnostico:controlVariableModified}}

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

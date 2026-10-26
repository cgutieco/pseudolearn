# Declaration and assignment

A declaration introduces a name, fixes a type for it and gives it its initial value. An assignment
stores a new value into a name that was declared mutable.

## One name per declaration

Each declaration introduces a single name with its type and its value. To have several variables, write
one declaration for each.

{{ejemplo:example-esp-declaracion-multiple}}

## Every declaration carries its initial value

A name declared without a value does not exist: the language does not invent a zero or an empty string,
and a value nobody wrote is not a value. That is why the declaration requires the initial value after
the arrow, and a name can never be read before it has one.

```pseudo
Algorithm Uninitialized
  Define x As Integer
  Write x
EndAlgorithm
```

{{diagnostico:missingBindingInitializer}}

## Immutable by default, mutable by choice

`Define` creates a binding that cannot be reassigned. If the program needs to change the value, it says
so in the declaration with `Mutable`. A mutable binding that is never modified is a warning, because
the word would not be doing anything.

```pseudo
Algorithm ReassignImmutable
  Define x As Integer <- 5
  x <- 6
EndAlgorithm
```

{{diagnostico:immutableBindingAssignment}}

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

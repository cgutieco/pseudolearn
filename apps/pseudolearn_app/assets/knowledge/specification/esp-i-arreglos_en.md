# Arrays

An array is a collection of slots of the same type reached by position rather than by name. It is the
first data structure of the language and the only one that is not a value.

## A single statement declares the entire array

After {{lexema:dimension}} come one or more dimensions separated by {{lexema:comma}}, and at the end
{{lexema:typeConnector}} with the element type, common to all of them. A dimensioning is a name
followed by its sizes in {{lexema:leftBracket}} and {{lexema:rightBracket}}, separated by
{{lexema:comma}} when there is more than one dimension.

The two-statement form —one to dimension and one to type— is rejected and it is worth knowing why: it
creates four classes of pairing error that do not exist with a single statement —dimensioned without
typing, typed without dimensioning, dimensioned twice, and the two statements in reverse order— in
exchange for zero benefit.

The element type can be any of the five primitives or a class name; in that case elements start
**uninstantiated**.

{{ejemplo:example-esp-arreglos-declaracion}}

## The index starts at zero

An array declared with N elements admits indices from 0 to N−1. It is a language decision and not a
profile datum: no profile changes it.

The criterion deciding it is the project's declared one —the form that best prepares for the real
language—: languages students jump to later index from zero. One-based indexing from academic notation
is therefore rejected.

{{ejemplo:example-esp-arreglos-indice-cero}}

## Size is an expression, and sometimes must be constant

Syntactically a size is always an expression. Under the strict profile it must also be a **constant
expression**, meaning a literal or an operator applied to constant expressions. It does not include
variable names, because the language has no named constants.

A size of **zero is valid**: the array admits no index, and traversing it with a counted loop simply
does not iterate. A negative size is a runtime failure, and a non-integer size is a meaning failure.

{{ejemplo:example-esp-arreglos-tamano-constante}}

## An array is not a value

It cannot be assigned whole, compared, printed to output, or returned from a function. Only its elements
are accessed.

Declaring it this way is not a capricious restriction: it is what enables a specific diagnostic —"an
array is not a value"— instead of a confusing type error, and is what decides, later, that arrays are
always passed by reference.

```pseudo
Algorithm ArrayValueNotAllowed
  Dimension a[3] As Integer
  Write a
EndAlgorithm
```

{{diagnostico:arrayCannotBeUsedAsValue}}

## Accessing an element

An element is reached by writing the name followed by its indices in {{lexema:leftBracket}} and
{{lexema:rightBracket}}, separated by {{lexema:comma}}. **A single pair of brackets for any number of
dimensions**, never chained brackets.

It is consistent with the dimensioning form and turns "the number of indices matches the declared
dimensions" into a single, checkable rule in one place. Chained syntax has its own diagnostic, because
it is exactly what whoever comes from another language writes.

Indices are evaluated from left to right, once each.

{{ejemplo:example-esp-arreglos-acceso}}

## What fails, and when it is noticed

A number of indices different from declared dimensions and a non-integer index are detected without
running. An out-of-range index, above or below, is a runtime failure and points exactly to the offending
index, because its value is not known beforehand.

In a zero-size array **any** index is out of range, and that is the edge case worth having written down
not to confuse it with a declaration error.

```pseudo
Algorithm ChainedAccessError
  Dimension m[2, 2] As Integer
  m[0][1] <- 5
EndAlgorithm
```

{{diagnostico:chainedArrayAccess}}

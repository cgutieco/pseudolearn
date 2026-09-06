:::parte pregunta

Storing five grades needs five boxes, and storing a hundred needs a hundred. Declaring them one at a
time with a different name each stops being reasonable long before reaching a hundred. This module
introduces a single box with many compartments: an entire row of values of the same type, with a
number instead of a name to choose which one.

:::parte modelo-maquina

{{figura:arreglo-indexado}}

An array is a contiguous stretch of boxes of the same type, with a single name and an index that picks
the compartment. The index **starts at zero**: the first compartment is 0, and an array of N elements
reaches N−1, never N. It is not a local convention: it is the same base the real languages that come
after this one use, and learning it here avoids relearning it later.

:::parte desarrollo

## Declaring an array is a single statement

{{ejemplo:example-b5-recorrido}}

{{lexema:dimension}} declares the name, the size and the type of the elements in a single statement:
there is no statement for the size and another for the type. Traversing an entire array, to fill it or
to read it, is the single most common pattern of all: a counted loop whose index runs from 0 to the
size minus one.

## An array is not a value

An array is not assigned whole, not compared and not written all at once: only its elements are
accessed, one at a time, with the index between brackets. Asking for the whole array as if it were a
single number is exactly the mistake this module's common-errors section shows.

## Searching for an element

{{ejemplo:example-b5-busqueda}}

Searching means traversing with a counted loop and comparing every element against the value being
sought. If the element appears, its index is stored and the traversal can keep going without that
changing the result: what matters is that the index is left in the `index` box before the loop ends.
If it never appears, `index` keeps the value it was initialised with, which is exactly why that value
is one no real index can ever take.

## Two dimensions: the same bracket, two indices

{{ejemplo:example-b5-matriz}}

A matrix is a two-dimensional array: a single pair of brackets with two indices separated by a comma,
`data[row, column]`, never two chained pairs of brackets. Traversing it whole is a counted loop inside
another: the outer one advances by row, the inner one by column, and together they visit every
compartment exactly once.

:::parte prediccion

- example-b5-busqueda#9#index With the numbers 4, 8, 15, 16, 23 and searching for 15, what value does `index` hold when the program ends?

Before checking, decide which position in the array holds 15 — remembering that the first position is
0, not 1 — and compare it against what you expected.

:::parte errores-frecuentes

## An index that is not an integer

An index picks a compartment, and compartments are counted with integers. A real index does not point
to any specific one.

```pseudo
algorithm NonIntegerIndex
    dimension numbers[5] as integer;
    define i as real;
    i <- 1.5;
    write numbers[i];
endAlgorithm
```

{{diagnostico:nonIntegerArrayIndex}}

## Fewer indices than the array has dimensions

A two-dimensional array needs two indices inside the same brackets, separated by a comma. One alone is
not enough, and two chained pairs do not exist in this language.

```pseudo
algorithm WrongIndexCount
    dimension data[3, 3] as integer;
    write data[0];
endAlgorithm
```

{{diagnostico:arrayDimensionCountMismatch}}

:::parte especificacion

- esp-i-arreglos Dimensioning, zero base and accessing an element

:::parte ejercicios

- CON-B5-E1 Sum of a vector's elements
- CON-B5-E2 Largest element of a vector
- CON-B5-E3 Reverse a vector
- CON-B5-E4 Search for a value in a vector
- CON-B5-E5 Sum of a 2x2 matrix
- CON-B5-E6 Main diagonal of a 3x3 matrix

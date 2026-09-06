:::parte pregunta

A written algorithm is not yet an algorithm that is understood. Understanding it means being able to
say, at any point, what value each name holds at that exact instant. This module introduces the
machine that holds those values, and the tool — the trace table — used to follow their trail without
actually running anything.

:::parte modelo-maquina

{{figura:cajas-memoria}}

The memory of a program is a row of named boxes. Each box holds a value, and that value changes only
when an assignment says so explicitly. Knowing what is in each box at a given moment does not require
running the program: it is enough to read the statements, in order, and note what changes in each one.
That is tracing a program, and the trace table is the ordered way to do it: one column per box, one row
per step.

:::parte desarrollo

## How a trace table is built

{{ejemplo:example-a2-acumulador}}

Before running it, the table is built by reading the program from top to bottom and noting the value of
each box after every statement that touches it. Boxes a statement does not touch keep their previous
value, and that is noted too.

| Step | Statement                | `total` | `n` |
|------|---------------------------|---------|-----|
| 1    | `total <- 0;`             | 0       | —   |
| 2    | `n <- 5;`                 | 0       | 5   |
| 3    | `total <- total + n;`     | 5       | 5   |
| 4    | `n <- 3;`                 | 5       | 3   |
| 5    | `total <- total + n;`     | 8       | 3   |

The `total` column is not "recomputed from scratch" on each row: every new value is built on top of the
value the previous row left behind. That dependency on the previous step is, again, the whole idea from
section 2 of this block: almost everything that surprises you about a program is explained by looking
at what was in each box one step earlier.

## Why the table comes before the editor

Tracing on paper forces a statement-by-statement decision about what changes and what does not. Running
it directly in the editor shows the final result without going through that decision, and the final
result teaches nothing about where the mistake was if the prediction does not match. That is why the
table is built first, by hand, and step-by-step execution is used afterwards, to check it.

:::parte prediccion

- example-a2-acumulador#7#total What value does `total` hold right after `total <- total + n;` runs for the second time?

Build the complete trace table of the **Simple accumulator** example on paper before checking your answer. If your
table does not match the real run, check row by row until you find the first one where they diverge:
that is exactly what your model of the machine still does not have clear.

:::parte errores-frecuentes

## Using a name that was never declared

Every box has to be requested before it is used. A name that appears with no declaration anywhere
earlier in the program has no box attached to it, and there is no value there to read or write.

```pseudo
algorithm GhostVariable
    counter <- 1;
    write counter;
endAlgorithm
```

{{diagnostico:undeclaredVariable}}

## Using a name before the line that declares it

Declaring a box and using it are two different steps, and the first one has to happen before the second
**in the text**, not just in the intention of whoever wrote it.

```pseudo
algorithm WrongOrder
    total <- total + 1;
    define total as integer;
    write total;
endAlgorithm
```

{{diagnostico:variableUsedBeforeDeclaration}}

:::parte especificacion

- esp-i-declaracion The exact shape of declaring a box and assigning it a value
- esp-i-tipos-primitivos The five types a box can admit

:::parte ejercicios

- CON-A2-E1 Seconds in a span of minutes
- CON-A2-E2 Total cost of a purchase
- CON-A2-E3 Complete the perimeter of a square
- CON-A2-E4 From two prices to their average
- CON-A2-E5 Area of a triangle
- CON-A2-E6 From Fahrenheit to Celsius

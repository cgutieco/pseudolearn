---
id: motor.limites
numero: "13.6"
tipo: motor
titulo: Engine limits
anclas: [ENG.LIMITS#R1, ENG.LIMITS#R2, ENG.LIMITS#R3, ENG.LIMITS#R4, ENG.LIMITS#R5, ENG.LIMITS#R6, ENG.LIMITS#R7, ENG.LIMITS#R8, ENG.LIMITS#R9, ENG.LIMITS#R10, ENG.LIMITS#R11, ENG.LIMITS#R12, ENG.LIMITS#R13]
diagnosticos: [recursionDepthExceeded, cellLimitExceeded, statementBudgetExhausted, taskLimitExceeded, channelCapacityExceeded]
terminos: [limit, budget, cell]
---

::: frase
Limits are resources set by whoever runs the program —depth, statements, memory, time— and are not part of the language: a program that does not reach them gives the same result under any configuration.
:::

## How it works {#funciona}

| Limit | Measured in | When exhausted |
|---|---|---|
| depth | active frames | failure `recursionDepthExceeded` |
| cells | live heap values | failure `cellLimitExceeded` |
| statements | statement entries | cut `statementBudgetExhausted` |
| time | the host's clock | cut without a diagnostic |
| live tasks | spawned, unfinished tasks | failure `taskLimitExceeded` |

The units are **deterministic**: they do not depend on the machine. An object takes one cell plus one per attribute; an array, one plus one per element; a text created at run time, one plus one per eight characters. Literals and what `Write` prints take no cells.

```figura id=limites-recursos
pie: Four resources with their cap. Exhausting depth or cells is a program failure; exhausting statements or time is a limit cut.
```

```programa id=profundo titulo="A recursion that exhausts depth"
```

::: limite
- Every host allows at least 1000 frames and 4194304 cells.
- The app uses 1000 frames; the terminal, 100000 and no statement budget.
- No limit exhausts the host's stack or produces an internal failure.
- Network and JSON limits do not end the program: they arrive as error values.
:::

::: resumen
- Limits are configured by the host; they are not part of the language.
- They are measured in deterministic units.
- Depth and cells fail; statements and time cut.
:::

::: vease
- [Recursion](#subprogramas.recursion)
- [Memory and the collector](#motor.memoria)
:::

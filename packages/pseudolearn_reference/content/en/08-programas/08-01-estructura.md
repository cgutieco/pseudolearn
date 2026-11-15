---
id: programas.estructura
numero: "8.1"
tipo: concepto
titulo: Structure of a program
anclas: [LANG.PROGRAM.STRUCTURE#R1, LANG.PROGRAM.CLASSIC#R1, LANG.PROGRAM.CLASSIC#R2, LANG.PROGRAM.CLASSIC#R3]
fichas: [help.module-unit]
diagnosticos: [multipleAlgorithms, unexpectedTokenOutsideProgramUnit, expectedAlgorithmStart]
terminos: [algorithm, unit]
---

::: frase
A program is a text with **a single algorithm** and, around it, the pieces that algorithm uses: subprograms, classes, records, enumerations and constants.
:::

## How it works {#funciona}

The top level of the text only accepts **units**: named blocks that open and close. No executable statement may be left loose outside them.

```figura id=estructura-archivo
pie: A file with its single algorithm and its sibling units. None goes inside another, and order does not matter.
```

| Unit | How many |
|---|---|
| `Algorithm` | exactly one |
| `Subroutine`, `Function` | as many as needed |
| `Class`, `Interface` | as many as needed |
| `Record`, `Enumeration`, `Variant` | as many as needed |
| `Constant` | as many as needed |

Units are **siblings**: none goes inside another. They can be written before or after the algorithm, in any order.

```programa id=tienda titulo="An algorithm with its neighbours"
```

An empty algorithm is valid and does nothing. The algorithm's name does not take up the variable namespace: it may match the name of a variable.

## Classic pseudocode {#clasico}

A program written in the classic style —`Algorithm`, `Define` with several names, `Read`, `Write`, `If`, `Switch`, loops, `Dimension` and `Function` with a result variable— is analysed **without any diagnostic** and runs as is, also from the terminal with `pseudo ejecutar`. The only requirements are the usual ones: semicolons, indices from zero and no variable read without a value.

::: errores
A statement outside every unit belongs nowhere:

```programa id=sentencia-suelta titulo="A loose statement"
```

And a text cannot have two algorithms:

```programa id=dos-algoritmos titulo="Two algorithms in one text"
```
:::

::: resumen
- A text has exactly one algorithm.
- Sibling units go around it, in any order.
- There are no loose statements or nested units.
- Classic pseudocode works without touch-ups.
:::

::: vease
- [Modules and projects](#programas.modulos)
- [Declaring subprograms](#subprogramas.declaracion)
- [What PseudoLearn is](#vision.que-es)
:::

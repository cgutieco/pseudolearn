---
id: tipos.niveles
numero: "3.15"
tipo: concepto
titulo: Checking levels
anclas: [LANG.TYPES.CHECKING-LEVELS#R1, DIAG.CLASSES#R1]
diagnosticos: [divisionByZero, incompatibleTypesInAssignment]
terminos: [static checking, dynamic checking]
---

::: frase
The engine checks everything it can before running; whatever depends on concrete values, such as dividing by zero, it checks when running.
:::

## How it works {#funciona}

There are two moments to discover a problem:

- **Before running** (static checking): the shape of the program, that names exist and that types fit. If something fails here, the program does not run.
- **When running** (dynamic checking): whatever depends on the real value at that moment, such as dividing by zero, going outside an array or reading a variable without a value.

```figura id=niveles
pie: What is checked at each moment. The earlier an error is found, the cheaper it is to fix.
```

This program is correct for the analysis, because dividing two integers makes sense. But when running, the divisor is zero:

```programa id=dividir-cero titulo="Correct when analysed, fails when run"
```

On the other hand, storing a text in an integer variable is found without running anything:

```programa id=tipo-mal titulo="An error seen beforehand"
```

## A failure is never silent {#controlado}

When a dynamic check fails, the program does not go on with an invented value: it stops at that statement with a diagnostic that says what happened and where. Expected failures from the outside world, such as a file that does not exist, do not stop the program: they come back as a `Result` so the program decides.

::: resumen
- Before running, shape, names and types are checked.
- When running, concrete values are checked.
- A runtime failure stops the program with a precise diagnostic.
- Expected failures from outside arrive as a `Result`.
:::

::: vease
- [Errors, warnings and failures](#vision.errores)
- [Effect order and the tape](#motor.efectos)
:::

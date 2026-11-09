---
id: control.mientras
numero: "6.3"
tipo: construccion
titulo: "The `While` loop"
anclas: [LANG.CONTROL.WHILE#R1]
fichas: [help.while]
diagnosticos: [nonBooleanCondition, unclosedWhileStatement, expectedDoKeyword]
terminos: [loop, iteration]
---

::: frase
`While` repeats a block **while** a condition is true, and checks it before every round, including the first.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=whileLoop
```

::: partes
- `While` opens the loop.
- «condition» is a `Boolean` expression.
- `Do` separates the condition from the body. It is required.
- «statements» is the body. It can be empty.
- `EndWhile` closes the loop.
:::

## How it works {#funciona}

Every **iteration** starts by checking the condition. If it is `True`, the body runs and control goes back to the top. If it is `False`, the loop ends and the program continues after `EndWhile`. If the condition is false from the start, the body runs **zero** times.

```programa id=cuenta-atras titulo="Countdown"
```

```figura id=mientras-ciclo
pie: The question comes before the body. With `n` at 0 the answer is `False` and the loop is left on the right.
paso: `n` is 3: the condition is true and the body runs.
paso: The body writes 3 and leaves `n` at 2. Back to the question.
paso: After three rounds `n` is 0: the condition is false and the loop ends.
```

Something inside the body must bring the condition closer to `False`. If nothing changes it, the loop never ends. Depending on where it runs, a host [limit](#motor.limites) on steps or time cuts it, or it keeps going until you stop it.

::: errores
```programa id=mientras-numero titulo="A numeric condition"
```
:::

::: por-dentro
A `While` is three blocks: the header with the condition, the body that jumps back to the header and the exit. Notice the backward jump at the end of the body.

```ri programa=cuenta-atras
```
:::

::: nota
The typical mistake is forgetting to update the variable in the condition. Predict what happens if `n <- n - 1;` is deleted, and check it in the app, which cuts the run when it reaches its limit.
:::

::: resumen
- `While` checks before every round.
- It can run the body zero times.
- The body must bring the condition closer to `False`.
:::

::: vease
- [Repeat](#control.repetir)
- [For](#control.para)
- [Leaving a loop](#control.salir)
:::

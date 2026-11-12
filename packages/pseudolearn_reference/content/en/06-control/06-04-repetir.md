---
id: control.repetir
numero: "6.4"
tipo: construccion
titulo: "The `Repeat` loop"
anclas: [LANG.CONTROL.REPEAT#R1]
fichas: [help.repeat]
diagnosticos: [nonBooleanCondition, unclosedRepeatStatement]
terminos: [post-test loop]
---

::: frase
`Repeat` runs the body first and asks afterwards: it repeats **until** the condition is true, and always does at least one round.
:::

## How to write it {#escribe}

```forma
```

::: partes
- `Repeat` opens the loop.
- «statements» is the body.
- `Until` closes the block: there is no `EndRepeat`.
- «condition» is a `Boolean` expression. When it is `True`, the loop **ends**.
:::

## How it works {#funciona}

It mirrors [`While`](#control.mientras): the question goes at the end and its meaning is the opposite. `While` goes on with `True`; `Repeat` **stops** with `True`.

```programa id=dado titulo="Rolling until a 6 comes up"
```

The result is always the same because the engine's randomness is [deterministic](#biblioteca.azar) with this book's seed.

```figura id=repetir-ciclo
pie: In `Repeat` the body comes before the question. Even if the condition already holds, the body runs once.
```

Since the body comes first, whatever it assigns is available to the condition and after the loop: a variable without an initial value that the body assigns ends up with a value.

```programa id=una-vez titulo="One round even if the condition already holds"
```

::: errores
```programa id=repetir-numero titulo="Until with a number"
```
:::

::: por-dentro
The body is the first block and the condition goes at the end, with a backward jump while it is still false.

```ri programa=una-vez
```
:::

::: nota
Translate `cuenta-atras` from `While` to `Repeat`. The condition has to be inverted, and with `n` at 0 from the start the `Repeat` version writes a 0 that the other one does not.
:::

::: resumen
- `Repeat` runs the body and then asks.
- It ends when the condition is `True`.
- It always does at least one round.
- `Until` closes the block.
:::

::: vease
- [While](#control.mientras)
- [Variables without a value](#declaraciones.sin-valor)
- [Randomness](#biblioteca.azar)
:::

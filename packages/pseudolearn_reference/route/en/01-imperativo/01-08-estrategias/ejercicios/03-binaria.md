---
id: imperativo.estrategias.binaria
leccion: imperativo.estrategias
tipo: resolver
nivel: brote
obligatorio: true
titulo: Searching by halves
---

::: enunciado
Read 10 numbers sorted from smallest to largest and then a searched number. Show the position of the searched number, from 0 to 9, or -1 if it is not there. Discard the half that cannot hold it at each step.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Which two positions mark what can still contain the searched number?
2. It is the guessing game of [the lesson](ruta:imperativo.estrategias), over an array.
3. Repeat while what is possible is not empty and you have not found it. What do you do with the middle if it is not the searched one?
4. With `bajo` and `alto`, look at `v[medio]`: if smaller, `bajo <- medio + 1`; if greater, `alto <- medio - 1`. Close with the variant.
:::

::: variante
Also show how many steps were needed. With 10 values, what is the maximum?
:::

::: explicacion
Hidden cases: the searched number at both ends, smaller than all and greater than all. Frequent mistake: leaving the middle inside the interval, which in some cases never ends.
:::

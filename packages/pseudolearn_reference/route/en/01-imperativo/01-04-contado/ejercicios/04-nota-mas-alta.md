---
id: imperativo.contado.nota-mas-alta
leccion: imperativo.contado
tipo: resolver
nivel: brote
obligatorio: true
titulo: The highest mark
---

::: enunciado
Read 5 marks, from 0 to 10, and show the highest. The program shows only the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Do you know how many marks there are? That decides which way of repeating suits.
2. You need a box that remembers the highest seen so far. Look at its roles in [the lesson](ruta:imperativo.contado).
3. What value does that box start with? Think of a value that is sure to work.
4. Read the first mark into the highest box; then, four passes that read and replace if the new one is greater. Close with the variant.
:::

::: variante
Also show in which position, from 1 to 5, the highest first appeared.
:::

::: explicacion
Hidden cases: the highest at the end and at the start. Frequent mistake: starting the highest at 0, which works with marks from 0 to 10 but fails with temperatures below zero.
:::

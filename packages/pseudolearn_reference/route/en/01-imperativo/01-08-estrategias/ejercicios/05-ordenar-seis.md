---
id: imperativo.estrategias.ordenar-seis
leccion: imperativo.estrategias
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Sorting six numbers
---

::: enunciado
Read 6 numbers and show them from smallest to largest, one per line.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Sort 5, 3, 8, 1, 9, 2 by hand, picking each time the smallest of those left.
2. It is the selection program of [the lesson](ruta:imperativo.estrategias), with one more number.
3. For each position from the first, find the smallest of what is left and swap it with the one in that position.
4. Two nested loops: the outer one walks the positions from 0 to 4; the inner one finds the smallest from the next one. Close with the variant.
:::

::: variante
Show them from largest to smallest by changing a single sign.
:::

::: explicacion
Hidden cases: reverse order, repeats and negatives. Frequent mistake: swapping inside the inner loop, which sorts but makes many more swaps.
:::

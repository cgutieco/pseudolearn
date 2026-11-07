---
id: imperativo.cuadriculas.cuadrado-magico
leccion: imperativo.cuadriculas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The magic square
---

::: enunciado
Read 9 numbers, row by row, of a 3 × 3 grid. It is magic if all the rows, all the columns and both diagonals add up to the same. Show «Es mágico» (it is magic) or «No es mágico».
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many sums do you have to compare? Which number do you compare them with?
2. It is the noughts and crosses of [the lesson](ruta:imperativo.cuadriculas) with sums instead of equal cells.
3. Take the sum of the first row as the target; a single different sum is enough for it not to be magic.
4. A boolean box starts as true and changes if any row, column or diagonal does not add up to the target. Close with the variant.
:::

::: variante
Also require the nine numbers to be different.
:::

::: docentes
The last hidden case has rows and diagonals that add up to 15 but two columns that do not: it uncovers whoever does not check the columns.
:::

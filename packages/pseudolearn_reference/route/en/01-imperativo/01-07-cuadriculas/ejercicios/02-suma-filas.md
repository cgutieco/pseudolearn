---
id: imperativo.cuadriculas.suma-filas
leccion: imperativo.cuadriculas
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The sum of each row
---

::: enunciado
Read the 9 numbers of a 3 × 3 grid, row by row, and show the sum of each row, one per line.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many sums do you have to show? How many numbers go into each one?
2. Keep the grid in a matrix, like the board in [the lesson](ruta:imperativo.cuadriculas).
3. For each row, the sum starts at 0 and gathers the three columns.
4. One loop over the rows; inside, the sum at 0 and a loop over the columns; at the end of each row, it is shown. Close with the variant.
:::

::: variante
Also show the sum of each column.
:::

::: explicacion
Frequent mistake: setting the sum to 0 only once, before all the loops, which piles up the previous rows: 6, 21, 45.
:::

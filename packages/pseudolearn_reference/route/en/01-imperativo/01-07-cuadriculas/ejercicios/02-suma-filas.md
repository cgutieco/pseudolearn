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
Algoritmo RowSums
  Dimension m[3, 3] Como Entero;
  Para f <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer m[f, c];
    FinPara
  FinPara
  Para f <- 0 Hasta 2 Hacer
    Definir sum Como Entero <- 0;
    Para c <- 0 Hasta 2 Hacer
      sum <- sum + m[f, c];
    FinPara
    Escribir sum;
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 | 6 ⏎ 15 ⏎ 24
visible | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0 ⏎ 0 ⏎ 0
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 | 3 ⏎ 3 ⏎ 3
oculto | 9 ; 0 ; 0 ; 0 ; 9 ; 0 ; 0 ; 0 ; 9 | 9 ⏎ 9 ⏎ 9
oculto | -1 ; 1 ; 0 ; 2 ; 2 ; 2 ; 5 ; 0 ; 0 | 0 ⏎ 6 ⏎ 5
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

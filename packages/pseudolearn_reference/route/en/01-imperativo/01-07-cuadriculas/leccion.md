---
id: imperativo.cuadriculas
numero: "1.7"
tipo: leccion
titulo: Boards and grids
duracion: 30
problema_breve: Who won at noughts and crosses?
necesita: [imperativo.esquemas]
introduce: [matriz, bucle-anidado, concatenar]
usa: [arreglo, indice, esquema, bucle-contado, caso-borde, condicion-compuesta]
---

::: frase
A matrix is an array with rows and columns, and each cell is found with two numbers.
:::

## The problem {#problema}

::: problema
At break they play noughts and crosses. When they finish, the board is written down row by row: **0** for an empty cell, **1** for X and **2** for O.

**Who won?**
:::

## Try it {#intentalo}

::: intento
Decide who won with this board, written row by row: 1, 2, 1 / 2, 1, 2 / 2, 1, 1.
:::

::: respuesta
X wins, by the diagonal that goes from the top left corner to the bottom right one: the three cells hold 1.
:::

## Understand {#entender fase=1}

::: ficha
- entra: nine numbers, row by row: 0 empty, 1 X and 2 O.
- sale: «Gana X», «Gana O» or «Nadie» (nobody).
- relacion: whoever completes a row, a column or one of the two diagonals wins.
- ejemplo: the board in the task → X wins, by a diagonal.
- ejemplo: a board without three in a row → nobody.
- ejemplo: an empty board → nobody.
:::

There are eight ways to win: three rows, three columns and two diagonals. An empty cell does not win even if there are three in a row: the empty board is the edge case.

## Plan {#planear fase=2}

```figura id=ruta-matriz-coordenadas
pie: Each cell has a row and a column. On one diagonal the row equals the column; on the other, they add up to 2.
```

1. Read the nine numbers into their cells.
2. Check each row, each column and the two diagonals: it is the search pattern, eight times.
3. If any has three equal, non-empty cells, whoever is in them won.

## The new tool {#herramienta}

A [[def:matriz|matrix]] is a two-dimensional array: each cell is found with two indices, the row and the column. Both start at 0.

```figura-especificacion seccion=tipos.arreglos figura=arreglo-casillas
```

To walk through a whole matrix you use a [[def:bucle-anidado|nested loop]]: one loop over the rows and, inside, another over the columns of each row.

To show a row on a single line it pays to [[def:concatenar|concatenate]]: join texts with `+` to make a new one. A number is turned into text with `toText`.

```programa id=dibujar-tablero titulo="Drawing the board" ejecutar
```

```salida
XOX
OXO
OXX
```

::: especificacion
- tipos.arreglos
- expresiones.concatenacion
:::

## Write {#escribir fase=3}

```programa id=tres-en-raya titulo="Noughts and crosses" ejecutar
```

```entrada
1
2
1
2
1
2
2
1
1
```

```salida
Gana X
```

## Test {#probar fase=4}

| Board | By hand | The program |
|---|---|---|
| 1, 1, 1 / 2, 2, 0 / 0, 0, 0 | X wins by a row | Gana X |
| 2, 1, 1 / 2, 1, 0 / 2, 0, 0 | O wins by a column | Gana O |
| 1, 2, 1 / 2, 1, 2 / 2, 1, 1 | X wins by a diagonal | Gana X |
| 2, 0, 1 / 0, 1, 0 / 1, 0, 2 | X wins by the other diagonal | Gana X |
| 1, 2, 1 / 1, 2, 2 / 2, 1, 1 | nobody | Nadie |

## Improve {#mejorar fase=5}

In one sentence: «The program keeps the board in a matrix and checks the eight lines looking for three equal cells».

For a 4 × 4 board the limits of the loops and the row of the second diagonal change. If the size were in a box with a name, it would be a single change.

## What you learned {#aprendiste}

::: resumen
- {matriz} A matrix keeps values in rows and columns; each cell has two indices.
- {bucle-anidado} A nested loop walks through all the columns of each row.
- {concatenar} Concatenating is joining texts to make a new one.
:::

## Practise {#practica}

::: practica
- imperativo.cuadriculas.filas-texto
- imperativo.cuadriculas.suma-filas
- imperativo.cuadriculas.raya-romper
- imperativo.cuadriculas.negativo
- imperativo.cuadriculas.cuadrado-magico
- imperativo.cuadriculas.casillas
:::

::: profundizar titulo="Common pitfalls"
- **Confusing row and column.** The row comes first. Point at `[0, 2]` in the figure before writing.
- **Indices from 1.** The centre of a 3 × 3 board is `[1, 1]`.
- **Checking only rows.** Try a board won by a column and another by the second diagonal.
:::

::: siguiente
I am thinking of a number between 1 and 100. How many questions do you need to guess it? Is there a better way than trying one by one?
:::

---
id: imperativo.cuadriculas.cuadrado-magico
leccion: imperativo.cuadriculas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The magic square
---

::: enunciado
Read 9 numbers, row by row, of a 3 × 3 grid. It is magic if all the rows, all the columns and both diagonals add up to the same. Show «Is magic» or «Not magic».
:::

```programa rol=referencia
Algoritmo MagicSquare
  Dimension m[3, 3] Como Entero;
  Para r <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer m[r, c];
    FinPara
  FinPara
  Definir target Como Entero <- m[0, 0] + m[0, 1] + m[0, 2];
  Definir isMagic Como Logico <- Verdadero;
  Para i <- 0 Hasta 2 Hacer
    Si m[i, 0] + m[i, 1] + m[i, 2] <> target Entonces
      isMagic <- Falso;
    FinSi
    Si m[0, i] + m[1, i] + m[2, i] <> target Entonces
      isMagic <- Falso;
    FinSi
  FinPara
  Si m[0, 0] + m[1, 1] + m[2, 2] <> target Entonces
    isMagic <- Falso;
  FinSi
  Si m[0, 2] + m[1, 1] + m[2, 0] <> target Entonces
    isMagic <- Falso;
  FinSi
  Si isMagic Entonces
    Escribir "Is magic";
  Sino
    Escribir "Not magic";
  FinSi
FinAlgoritmo
```

```casos
visible | 2 ; 7 ; 6 ; 9 ; 5 ; 1 ; 4 ; 3 ; 8 | Is magic
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 | Not magic
oculto | 8 ; 1 ; 6 ; 3 ; 5 ; 7 ; 4 ; 9 ; 2 | Is magic
oculto | 5 ; 5 ; 5 ; 5 ; 5 ; 5 ; 5 ; 5 ; 5 | Is magic
oculto | 2 ; 7 ; 6 ; 9 ; 5 ; 1 ; 4 ; 8 ; 3 | Not magic
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

::: explicacion
The last hidden case has rows and diagonals that add up to 15 but two columns that do not: it uncovers whoever does not check the columns.
:::

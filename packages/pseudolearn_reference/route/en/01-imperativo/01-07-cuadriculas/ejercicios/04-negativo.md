---
id: imperativo.cuadriculas.negativo
leccion: imperativo.cuadriculas
tipo: resolver
nivel: brote
obligatorio: false
titulo: The negative of an image
---

::: enunciado
A 4 × 4 image is made of white (0) and black (1) dots. Read the 16 values, row by row, and show the inverted image: each white becomes black and each black white. One row per line, without spaces.
:::

```programa rol=referencia
Algoritmo Negative
  Dimension image[4, 4] Como Entero;
  Para r <- 0 Hasta 3 Hacer
    Para c <- 0 Hasta 3 Hacer
      Leer image[r, c];
    FinPara
  FinPara
  Para r <- 0 Hasta 3 Hacer
    Definir line Como Cadena <- "";
    Para c <- 0 Hasta 3 Hacer
      line <- line + ConvertirATexto(1 - image[r, c]);
    FinPara
    Escribir line;
  FinPara
FinAlgoritmo
```

```casos
visible | 0 ; 1 ; 1 ; 0 ; 1 ; 0 ; 0 ; 1 ; 1 ; 0 ; 0 ; 1 ; 0 ; 1 ; 1 ; 0 | 1001 ⏎ 0110 ⏎ 0110 ⏎ 1001
visible | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 1111 ⏎ 1111 ⏎ 1111 ⏎ 1111
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 | 0000 ⏎ 0000 ⏎ 0000 ⏎ 0000
oculto | 1 ; 0 ; 0 ; 0 ; 0 ; 1 ; 0 ; 0 ; 0 ; 0 ; 1 ; 0 ; 0 ; 0 ; 0 ; 1 | 0111 ⏎ 1011 ⏎ 1101 ⏎ 1110
oculto | 1 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0111 ⏎ 1111 ⏎ 1111 ⏎ 1111
```

::: pistas
1. Which sum turns 0 into 1 and 1 into 0?
2. Read the image into a matrix with a nested loop, as in [the lesson](ruta:imperativo.cuadriculas).
3. Each row is built as a text, joining one digit per column.
4. `1 - image[r, c]` inverts each dot; `toText` joins it to the line. Close with the variant.
:::

::: variante
Show the image flipped from left to right, like in a mirror, without inverting the colours.
:::

::: explicacion
Hidden cases: all black, the diagonal and a single dot. Frequent mistake: showing each digit with its own `Write`, which puts one per line.
:::

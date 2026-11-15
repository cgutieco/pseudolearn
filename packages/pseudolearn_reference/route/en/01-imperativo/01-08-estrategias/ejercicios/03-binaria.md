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
Algoritmo Binary
  Dimension v[10] Como Entero;
  Para i <- 0 Hasta 9 Hacer
    Leer v[i];
  FinPara
  Definir searched Como Entero;
  Leer searched;
  Definir low Como Entero <- 0;
  Definir high Como Entero <- 9;
  Definir middle Como Entero;
  Definir position Como Entero <- -1;
  Mientras low <= high Y position = -1 Hacer
    middle <- (low + high) div 2;
    Si v[middle] = searched Entonces
      position <- middle;
    Sino
      Si v[middle] < searched Entonces
        low <- middle + 1;
      Sino
        high <- middle - 1;
      FinSi
    FinSi
  FinMientras
  Escribir position;
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ; 10 ; 7 | 6
visible | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 5 | -1
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 2 | 0
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 20 | 9
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 1 | -1
oculto | 2 ; 4 ; 6 ; 8 ; 10 ; 12 ; 14 ; 16 ; 18 ; 20 ; 21 | -1
```

::: pistas
1. Which two positions mark what can still contain the searched number?
2. It is the guessing game of [the lesson](ruta:imperativo.estrategias), over an array.
3. Repeat while what is possible is not empty and you have not found it. What do you do with the middle if it is not the searched one?
4. With `low` and `high`, look at `v[middle]`: if smaller, `low <- middle + 1`; if greater, `high <- middle - 1`. Close with the variant.
:::

::: variante
Also show how many steps were needed. With 10 values, what is the maximum?
:::

::: explicacion
Hidden cases: the searched number at both ends, smaller than all and greater than all. Frequent mistake: leaving the middle inside the interval, which in some cases never ends.
:::

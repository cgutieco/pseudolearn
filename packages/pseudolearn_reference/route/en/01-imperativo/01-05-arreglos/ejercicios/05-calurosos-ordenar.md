---
id: imperativo.arreglos.calurosos-ordenar
leccion: imperativo.arreglos
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordering the hot days
---

::: enunciado
The lines of a program that shows the days hotter than the average are mixed up. Put them in order so that it works.
:::

```programa rol=referencia
Algoritmo HotDays
  Dimension temperatures[7] Como Entero;
  Definir sum Como Entero <- 0;
  Para i <- 0 Hasta 6 Hacer
    Leer temperatures[i];
    sum <- sum + temperatures[i];
  FinPara
  Definir average Como Real <- sum / 7;
  Para i <- 0 Hasta 6 Hacer
    Si temperatures[i] > average Entonces
      Escribir "Day ", i;
    FinSi
  FinPara
FinAlgoritmo
```

```casos
visible | 20 ; 23 ; 19 ; 25 ; 22 ; 18 ; 26 | Day 1 ⏎ Day 3 ⏎ Day 4 ⏎ Day 6
oculto | 10 ; 10 ; 10 ; 10 ; 10 ; 10 ; 30 | Day 6
oculto | 30 ; 10 ; 10 ; 10 ; 10 ; 10 ; 10 | Day 0
```

::: explicacion
First the array and the accumulator are declared; the first pass reads and adds; then the average is computed; the second pass compares each day. The average cannot go before the first pass.
:::

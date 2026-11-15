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
Algoritmo HighestMark
  Definir mark Como Entero;
  Definir highest Como Entero;
  Leer highest;
  Para i <- 2 Hasta 5 Hacer
    Leer mark;
    Si mark > highest Entonces
      highest <- mark;
    FinSi
  FinPara
  Escribir highest;
FinAlgoritmo
```

```casos
visible | 4 ; 9 ; 7 ; 9 ; 2 | 9
visible | 1 ; 1 ; 1 ; 1 ; 1 | 1
oculto | 0 ; 0 ; 0 ; 0 ; 10 | 10
oculto | 10 ; 0 ; 0 ; 0 ; 0 | 10
oculto | 5 ; 6 ; 7 ; 8 ; 9 | 9
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

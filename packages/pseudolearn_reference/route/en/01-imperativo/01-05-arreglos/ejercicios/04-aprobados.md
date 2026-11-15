---
id: imperativo.arreglos.aprobados
leccion: imperativo.arreglos
tipo: resolver
nivel: brote
obligatorio: false
titulo: How many passed?
---

::: enunciado
Read 6 marks, from 0 to 10, and show how many are 6 or more. The program shows only the number.
:::

```programa rol=referencia
Algoritmo Passed
  Dimension marks[6] Como Entero;
  Definir passed Como Entero <- 0;
  Para i <- 0 Hasta 5 Hacer
    Leer marks[i];
  FinPara
  Para Cada mark En marks Hacer
    Si mark >= 6 Entonces
      passed <- passed + 1;
    FinSi
  FinPara
  Escribir passed;
FinAlgoritmo
```

```casos
visible | 6 ; 5 ; 7 ; 10 ; 2 ; 6 | 4
visible | 5 ; 5 ; 5 ; 5 ; 5 ; 5 | 0
oculto | 6 ; 6 ; 6 ; 6 ; 6 ; 6 | 6
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 10 | 1
oculto | 10 ; 10 ; 10 ; 10 ; 10 ; 10 | 6
```

::: pistas
1. Where is the edge between passing and failing? On which side is 6?
2. Keep the marks and walk through them; for each one, a question.
3. A box counts the ones that meet it. If you do not need the position, you can walk through without an index.
4. Walk through with `For Each` and add 1 when the mark is 6 or more. Close with the variant.
:::

::: variante
Also show the average of the passing marks, or «Nobody passed».
:::

::: explicacion
The edge is 6, which passes. Hidden cases: all on the edge and nobody passing. Frequent mistake: `> 6`.
:::

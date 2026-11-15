---
id: imperativo.esquemas.primer-desaprobado
leccion: imperativo.esquemas
tipo: resolver
nivel: brote
obligatorio: true
titulo: The first fail
---

::: enunciado
Read 6 marks and show the position, from 0 to 5, of the first mark less than 6. If there is none, show -1.
:::

```programa rol=referencia
Algoritmo FirstFailed
  Dimension marks[6] Como Entero;
  Para i <- 0 Hasta 5 Hacer
    Leer marks[i];
  FinPara
  Definir position Como Entero <- -1;
  Para i <- 0 Hasta 5 Hacer
    Si marks[i] < 6 Entonces
      position <- i;
      Salir;
    FinSi
  FinPara
  Escribir position;
FinAlgoritmo
```

```casos
visible | 7 ; 8 ; 3 ; 9 ; 2 ; 6 | 2
visible | 6 ; 7 ; 8 ; 9 ; 10 ; 6 | -1
oculto | 5 ; 9 ; 9 ; 9 ; 9 ; 9 | 0
oculto | 6 ; 6 ; 6 ; 6 ; 6 ; 5 | 5
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0
```

::: pistas
1. Which way of solving is this: counting, searching, filtering? When can you stop looking?
2. Look at the table of shapes in [the lesson](ruta:imperativo.esquemas).
3. Start with the answer for «there is none» and change it only if you find one.
4. Start the position at -1; walk through and, at the first mark less than 6, keep the position and exit. Close with the variant.
:::

::: variante
Show the position of the last mark less than 6. What changes in the walk?
:::

::: explicacion
Hidden cases: the first one in position 0, the last one in 5 and all failing (0 wins). Frequent mistake: not exiting the loop, which returns the last one and not the first.
:::

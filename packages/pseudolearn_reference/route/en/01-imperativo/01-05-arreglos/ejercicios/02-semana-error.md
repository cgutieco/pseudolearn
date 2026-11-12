---
id: imperativo.arreglos.semana-error
leccion: imperativo.arreglos
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The week that ends badly
---

::: enunciado
The program reads the 7 temperatures of the week and shows their sum, but it stops before showing it. Find the error and fix it.
:::

```programa rol=inicial
Algoritmo Week
  Dimension temperatures[7] Como Entero;
  Definir sum Como Entero <- 0;
  Para i <- 0 Hasta 7 Hacer
    Leer temperatures[i];
    sum <- sum + temperatures[i];
  FinPara
  Escribir sum;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Week
  Dimension temperatures[7] Como Entero;
  Definir sum Como Entero <- 0;
  Para i <- 0 Hasta 6 Hacer
    Leer temperatures[i];
    sum <- sum + temperatures[i];
  FinPara
  Escribir sum;
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 | 28
visible | 20 ; 20 ; 20 ; 20 ; 20 ; 20 ; 20 | 140
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 0
oculto | 30 ; 31 ; 32 ; 33 ; 34 ; 35 ; 36 | 231
oculto | -1 ; -1 ; -1 ; -1 ; -1 ; -1 ; -1 | -7
```

::: pistas
1. Is it a compile error, a runtime error or a logic error? On which pass does it stop?
2. Count the passes of the loop: how many does it make, and how many cells does the array have?
3. If the array has 7 cells, which is the last index that exists?
4. The loop has to go from 0 to 6. Close with the variant.
:::

::: variante
Write the loop so that it works with any size, keeping the size in a box with a name.
:::

::: explicacion
The loop makes 8 passes for 7 cells: on the eighth it asks for cell 7, which does not exist, and the program stops out of range. Frequent mistake: fixing it with an array of 8.
:::

---
id: procedimental.ambito.cambiar-figuritas
leccion: procedimental.ambito
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The swap that does not swap
---

::: enunciado
The program reads two numbers and should show them the other way round, using `Swap`. But it shows them in the same order. Find the error and fix it.
:::

```programa rol=inicial
SubProceso Swap(a Como Entero, b Como Entero)
  Definir saved Como Entero <- a;
  a <- b;
  b <- saved;
FinSubProceso

Algoritmo Main
  Definir firstNumber, secondNumber Como Entero;
  Leer firstNumber;
  Leer secondNumber;
  Swap(firstNumber, secondNumber);
  Escribir firstNumber, " ", secondNumber;
FinAlgoritmo
```

```programa rol=referencia
SubProceso Swap(a Como Entero Por Referencia, b Como Entero Por Referencia)
  Definir saved Como Entero <- a;
  a <- b;
  b <- saved;
FinSubProceso

Algoritmo Main
  Definir firstNumber, secondNumber Como Entero;
  Leer firstNumber;
  Leer secondNumber;
  Swap(firstNumber, secondNumber);
  Escribir firstNumber, " ", secondNumber;
FinAlgoritmo
```

```casos
visible | 3 ; 8 | 8 3
visible | 1 ; 1 | 1 1
oculto | 0 ; 5 | 5 0
oculto | -2 ; 4 | 4 -2
oculto | 9 ; 0 | 0 9
```

::: pistas
1. Which boxes does `Swap` change? Are they the same ones the main algorithm reads?
2. Look at the balance that did not double in [the lesson](ruta:procedimental.ambito).
3. Returning is not enough here: you have to give back two values.
4. Mark both parameters with `By Reference`. Close with the variant.
:::

::: variante
Write `SortThree`, which leaves three numbers from smallest to largest using `Swap`.
:::

::: explicacion
The subprogram swaps its copies. Since two values have to come back, the solution lends both boxes. The 1 and 1 case does not uncover the error: that is why more cases are needed.
:::

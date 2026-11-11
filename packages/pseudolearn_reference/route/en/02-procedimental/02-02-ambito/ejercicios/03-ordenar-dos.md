---
id: procedimental.ambito.ordenar-dos
leccion: procedimental.ambito
tipo: resolver
nivel: brote
obligatorio: true
titulo: The smaller one first
---

::: enunciado
Read two numbers and show them as `smaller larger`, separated by a space.
:::

::: restriccion
A subprogram `SortTwo` receives both boxes and leaves the smaller in the first and the larger in the second; the main algorithm only reads, calls and shows.
:::

```programa rol=referencia
SubProceso SortTwo(a Como Entero Por Referencia, b Como Entero Por Referencia)
  Si a > b Entonces
    Definir saved Como Entero <- a;
    a <- b;
    b <- saved;
  FinSi
FinSubProceso

Algoritmo Main
  Definir firstNumber, secondNumber Como Entero;
  Leer firstNumber;
  Leer secondNumber;
  SortTwo(firstNumber, secondNumber);
  Escribir firstNumber, " ", secondNumber;
FinAlgoritmo
```

```casos
visible | 9 ; 4 | 4 9
visible | 2 ; 7 | 2 7
oculto | 5 ; 5 | 5 5
oculto | -1 ; -3 | -3 -1
oculto | 0 ; 10 | 0 10
```

```aserciones
- declara-subprograma | SortTwo | 2 | The subprogram SortTwo, which receives both boxes, is missing.
```

::: pistas
1. When do you have to change something and when not?
2. It is the swap of the previous exercise, done only when needed.
3. Both boxes have to come back changed: lend them.
4. If the first is greater than the second, swap them. Close with the variant.
:::

::: variante
Make `SortTwo` also return whether it had to swap.
:::

::: explicacion
Hidden cases: equal, negatives and already sorted. Frequent mistake: passing the boxes by value, which shows the original order.
:::

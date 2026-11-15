---
id: procedimental.recursion.suma-sin-fin
leccion: procedimental.recursion
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The sum that never ends
---

::: enunciado
This program reads a non-negative number and should show the sum from 1 to that number. But it never ends well. Find the error and fix it.
:::

```programa rol=inicial
Funcion total <- SumUpTo(n Como Entero)
  Definir total Como Entero;
  total <- n + SumUpTo(n - 1);
FinFuncion

Algoritmo Main
  Definir n Como Entero;
  Leer n;
  Escribir SumUpTo(n);
FinAlgoritmo
```

```programa rol=referencia
Funcion total <- SumUpTo(n Como Entero)
  Definir total Como Entero;
  Si n = 0 Entonces
    total <- 0;
  Sino
    total <- n + SumUpTo(n - 1);
  FinSi
FinFuncion

Algoritmo Main
  Definir n Como Entero;
  Leer n;
  Escribir SumUpTo(n);
FinAlgoritmo
```

```casos
visible | 3 | 6
visible | 1 | 1
oculto | 0 | 0
oculto | 10 | 55
oculto | 100 | 5050
```

::: pistas
1. Is it a compile error, a runtime error or a logic error? What does the engine say?
2. Compare with the factorial of [the lesson](ruta:procedimental.recursion). Which part is this function missing?
3. What is the smallest sum you already know without computing anything?
4. If `n` is 0, the sum is 0; otherwise, `n + SumUpTo(n - 1)`. Close with the variant.
:::

::: variante
Write `SumEvens(n)`, the sum of the even numbers from 2 to `n`.
:::

::: explicacion
Without a base case, the function calls itself with -1, -2, … until the engine stops it by depth. The 100 case checks that the reference does not run out of frames.
:::

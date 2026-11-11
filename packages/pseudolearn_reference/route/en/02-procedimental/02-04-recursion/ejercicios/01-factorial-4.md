---
id: procedimental.recursion.factorial-4
leccion: procedimental.recursion
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The factorial of 4
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Funcion r <- Factorial(n Como Entero)
  Definir r Como Entero;
  Si n = 0 Entonces
    r <- 1;
  Sino
    r <- n * Factorial(n - 1);
  FinSi
FinFuncion

Algoritmo Main
  Escribir Factorial(4);
FinAlgoritmo
```

```salida
24
```

::: explicacion
`Factorial(4)` is 4 times `Factorial(3)`, which is 3 times `Factorial(2)`, and so on down to `Factorial(0)`, which is 1. As the frames close: 1, 1, 2, 6, 24.
:::

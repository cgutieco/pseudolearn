---
id: procedimental.recursion.factorial-4
leccion: procedimental.recursion
tipo: predecir
nivel: semilla
obligatorio: true
titulo: El factorial de 4
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
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

Algoritmo Principal
  Escribir Factorial(4);
FinAlgoritmo
```

```salida
24
```

::: explicacion
`Factorial(4)` es 4 por `Factorial(3)`, que es 3 por `Factorial(2)`, y así hasta `Factorial(0)`, que es 1. Al cerrarse los marcos: 1, 1, 2, 6, 24.
:::

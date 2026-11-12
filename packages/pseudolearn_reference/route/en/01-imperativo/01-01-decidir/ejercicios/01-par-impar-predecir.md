---
id: imperativo.decidir.par-impar-predecir
leccion: imperativo.decidir
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Which path does it take?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo EvenOdd
  Definir x Como Entero <- 7;
  Si x mod 2 = 0 Entonces
    Escribir "even";
  Sino
    Escribir "odd";
  FinSi
FinAlgoritmo
```

```salida
odd
```

::: explicacion
7 shared out in twos leaves 1: `x mod 2` is 1, the condition is false and the finger jumps to the `Else` branch.
:::

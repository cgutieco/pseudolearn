---
id: imperativo.mientras.misterio
leccion: imperativo.mientras
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The mystery number
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo Mystery
  Definir n Como Entero <- 0;
  Definir total Como Entero <- 0;
  Mientras total < 10 Hacer
    n <- n + 1;
    total <- total + n;
  FinMientras
  Escribir n, " ", total;
FinAlgoritmo
```

```salida
4 10
```

::: explicacion
`n` moves one by one and `total` keeps gathering: 1, 3, 6, 10. With 10, the condition `total < 10` is already false and the loop ends.
:::

---
id: imperativo.mientras.misterio
leccion: imperativo.mientras
tipo: predecir
nivel: semilla
obligatorio: true
titulo: El número misterioso
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo Misterio
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
`n` avanza de 1 en 1 y `total` va juntando: 1, 3, 6, 10. Con 10, la condición `total < 10` ya es falsa y el bucle termina.
:::

---
id: imperativo.arreglos.posiciones
leccion: imperativo.arreglos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Las posiciones
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo Posiciones
  Dimension v[5] Como Entero;
  v[0] <- 4;
  v[1] <- 8;
  v[2] <- 15;
  v[3] <- 16;
  v[4] <- 23;
  Escribir v[1] + v[3];
FinAlgoritmo
```

```salida
24
```

::: explicacion
La casilla 1 es la segunda, con 8, y la casilla 3 es la cuarta, con 16. Suman 24.
:::

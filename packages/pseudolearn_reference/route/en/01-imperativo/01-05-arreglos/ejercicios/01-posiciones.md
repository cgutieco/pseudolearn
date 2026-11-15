---
id: imperativo.arreglos.posiciones
leccion: imperativo.arreglos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The positions
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo Positions
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
Cell 1 is the second one, with 8, and cell 3 is the fourth one, with 16. They add up to 24.
:::

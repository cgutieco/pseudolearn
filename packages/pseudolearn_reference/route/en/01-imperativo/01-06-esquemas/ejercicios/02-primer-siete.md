---
id: imperativo.esquemas.primer-siete
leccion: imperativo.esquemas
tipo: predecir
nivel: semilla
obligatorio: false
titulo: The first seven
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo FirstSeven
  Dimension v[4] Como Entero;
  v[0] <- 3;
  v[1] <- 7;
  v[2] <- 9;
  v[3] <- 7;
  Definir position Como Entero <- -1;
  Para i <- 0 Hasta 3 Hacer
    Si v[i] = 7 Entonces
      position <- i;
      Salir;
    FinSi
  FinPara
  Escribir position;
FinAlgoritmo
```

```salida
1
```

::: explicacion
The search stops at the first 7, in position 1. The second 7, in position 3, is never looked at.
:::

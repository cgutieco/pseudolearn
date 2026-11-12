---
id: imperativo.esquemas.primer-siete
leccion: imperativo.esquemas
tipo: predecir
nivel: semilla
obligatorio: false
titulo: El primer siete
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo PrimerSiete
  Dimension v[4] Como Entero;
  v[0] <- 3;
  v[1] <- 7;
  v[2] <- 9;
  v[3] <- 7;
  Definir posicion Como Entero <- -1;
  Para i <- 0 Hasta 3 Hacer
    Si v[i] = 7 Entonces
      posicion <- i;
      Salir;
    FinSi
  FinPara
  Escribir posicion;
FinAlgoritmo
```

```salida
1
```

::: explicacion
La búsqueda se detiene en el primer 7, en la posición 1. El segundo 7, en la posición 3, nunca se mira.
:::

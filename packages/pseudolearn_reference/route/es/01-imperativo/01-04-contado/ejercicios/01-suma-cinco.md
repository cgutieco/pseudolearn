---
id: imperativo.contado.suma-cinco
leccion: imperativo.contado
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Del 1 al 5
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo SumaCinco
  Definir total Como Entero <- 0;
  Para i <- 1 Hasta 5 Hacer
    total <- total + i;
  FinPara
  Escribir total;
FinAlgoritmo
```

```salida
15
```

::: explicacion
`i` toma los valores 1, 2, 3, 4 y 5, y `total` los va juntando: 1, 3, 6, 10, 15.
:::

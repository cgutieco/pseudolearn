---
id: imperativo.contado.suma-cinco
leccion: imperativo.contado
tipo: predecir
nivel: semilla
obligatorio: true
titulo: From 1 to 5
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo SumFive
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
`i` takes the values 1, 2, 3, 4 and 5, and `total` keeps gathering them: 1, 3, 6, 10, 15.
:::

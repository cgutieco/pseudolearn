---
id: inicio.nombres.cajas
leccion: inicio.nombres
tipo: predecir
nivel: semilla
obligatorio: true
titulo: What is left in each box?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
`b <- a` copies 5 into `b` at that moment. When `a` later becomes 7, `b` does not notice: each box keeps its own value and does not recompute itself.
:::

::: docentes
Frequent mistake: answering `7 7`, as if `b` were tied to `a`. Ask them to draw both boxes and cross out the old value at each assignment.
:::

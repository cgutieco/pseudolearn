---
id: concurrente.elegir.canceladas
leccion: concurrente.elegir
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The supplier that fails
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
Only South has stock 0: its query ends with `Failure` and the scope keeps that error as the first one. How many queries get cut depends on the turns; that is why this program does not show it.
:::

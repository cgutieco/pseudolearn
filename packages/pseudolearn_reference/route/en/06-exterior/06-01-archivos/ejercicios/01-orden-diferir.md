---
id: exterior.archivos.orden-diferir
leccion: exterior.archivos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Three cleanups
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
The deferred orders are kept and run on leaving, in reverse order: the last one written is the first one run. That is why «fin» comes first.
:::

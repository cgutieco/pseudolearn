---
id: concurrente.tareas.suma-tareas
leccion: concurrente.tareas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The sum of two tasks
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
Each task gives back a square: 9 and 16. `Await` hands over each result when its task has finished, and the sum is 25, no matter which one finished first.
:::

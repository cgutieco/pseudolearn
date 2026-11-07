---
id: concurrente.canales.canal-suma
leccion: concurrente.canales
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The sum that arrives in parts
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
The producer sends 4, 5 and 6 and closes. The consumer adds each message and, when `Receive` gives `None`, it leaves the loop and writes 15.
:::

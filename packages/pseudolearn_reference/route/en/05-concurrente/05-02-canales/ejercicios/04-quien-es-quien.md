---
id: concurrente.canales.quien-es-quien
leccion: concurrente.canales
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: Who is who?
---

::: enunciado
Place each part: does it produce messages or consume them?
:::

```categorias
- Producer
- Consumer
```

```elementos
- The kitchen that leaves dishes. | Producer
- The window that hands them over. | Consumer
- A sensor that sends temperatures. | Producer
- The screen that shows them. | Consumer
```

::: explicacion
The producer puts messages in the channel; the consumer takes them out and does something with them. The same task can be both, but here each one does only one.
:::

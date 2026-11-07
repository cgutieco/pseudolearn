---
id: concurrente.canales.sin-cerrar
leccion: concurrente.canales
tipo: encontrar-error
nivel: brote
obligatorio: false
titulo: The window that never finishes
---

::: enunciado
The program hands over all the orders, but it never shows the final count and the engine stops it. Find the error and fix it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. What does the window wait for after the last order?
2. The window leaves the loop only when `Receive` gives `None`.
3. `Receive` gives `None` when the channel was closed and is empty. Who closes it?
4. `mostrador.Close()` is missing at the end of the kitchen. Close with the variant.
:::

::: variante
What would happen if the window closed the channel instead of the kitchen?
:::

::: docentes
The engine ends with `taskDeadlock`: no task can move forward. It is the error of forgetting to close the channel, the second one in the lesson's list.
:::

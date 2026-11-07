---
id: concurrente.tareas.turnos-ordenar
leccion: concurrente.tareas
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Order the kitchen
---

::: enunciado
The lines of the kitchen program are mixed up. Put them in order so that it works.
:::

```programa rol=referencia
```

```casos
```

::: explicacion
The tasks are launched inside the scope, the tray awaits the three results before closing it, and «Bandeja entregada» goes after `EndTasks`.
:::

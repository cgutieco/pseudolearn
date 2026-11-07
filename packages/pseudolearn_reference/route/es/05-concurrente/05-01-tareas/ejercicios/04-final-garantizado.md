---
id: concurrente.tareas.final-garantizado
leccion: concurrente.tareas
tipo: explicar
nivel: semilla
obligatorio: false
titulo: Lo que se puede asegurar
---

::: enunciado
Un programa lanza dos tareas que saludan, una a Ana y otra a Leo, y escribe «listo» después de cerrar el ámbito. ¿Qué se puede asegurar de la salida?
:::

```opciones
- [x] Que «listo» sale último. | El ámbito espera a sus dos tareas antes de seguir, así que «listo» va después de los dos saludos.
- [ ] Que Ana saluda antes que Leo. | Es lo que hoy da el motor, pero el orden entre las dos tareas lo decide la agenda y el programa no lo promete.
- [ ] Que los saludos salen alternados. | Cada saludo es una sola línea; no hay nada que alternar, y la agenda no promete un orden.
```

::: explicacion
Lo garantizado es lo que impone el programa: el cierre del ámbito espera a todas sus tareas. Lo demás es lo observado, y puede cambiar.
:::

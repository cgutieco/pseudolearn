---
id: concurrente.tareas.final-garantizado
leccion: concurrente.tareas
tipo: explicar
nivel: semilla
obligatorio: false
titulo: What can be guaranteed
---

::: enunciado
A program launches two tasks that greet, one Ana and the other Leo, and writes «listo» after closing the scope. What can be guaranteed about the output?
:::

```opciones
- [x] That «listo» comes last. | The scope waits for its two tasks before going on, so «listo» goes after the two greetings.
- [ ] That Ana greets before Leo. | It is what the engine gives today, but the order between the two tasks is decided by the schedule and the program does not promise it.
- [ ] That the greetings come alternated. | Each greeting is a single line; there is nothing to alternate, and the schedule does not promise an order.
```

::: explicacion
What is guaranteed is what the program imposes: closing the scope waits for all its tasks. The rest is what is observed, and it can change.
:::

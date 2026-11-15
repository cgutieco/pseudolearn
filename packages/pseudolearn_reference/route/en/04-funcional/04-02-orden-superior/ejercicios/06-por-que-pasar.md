---
id: funcional.orden-superior.por-que-pasar
leccion: funcional.orden-superior
tipo: explicar
nivel: semilla
obligatorio: false
titulo: What is gained?
---

::: enunciado
What is gained by passing the operation as a value, instead of writing a walk for each operation?
:::

```opciones
- [x] The walk is written only once, and each new operation is a small function. | What was repeated stays in one place; what changes is a value.
- [ ] The program is faster. | It takes the same steps; what changes is how much has to be written and checked.
- [ ] Functions are no longer needed. | The opposite: each operation is a function.
```

::: explicacion
Separating what repeats from what changes is the same idea as subprograms, one step further: now what changes is an operation.
:::

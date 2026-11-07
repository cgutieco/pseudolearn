---
id: imperativo.estrategias.guia-telefonica
leccion: imperativo.estrategias
tipo: comparar
nivel: semilla
obligatorio: false
titulo: The list of 1000 names
---

::: enunciado
You have to find a name in an alphabetically sorted list of 1000 names. Which way of searching suits, and how many steps does it need at most?
:::

```opciones
- [ ] One by one, from the start: at most 500 steps. | In the worst case the name is at the end, or it is not there: 1000 steps.
- [x] By halves: at most 10 steps. | Each step discards half: 1000, 500, 250, … in 10 steps only one is left.
- [ ] By halves: at most 100 steps. | Discarding half ten times already leaves a single name.
- [ ] It makes no difference: both take the same in the worst case. | One by one may need 1000 steps; by halves, 10.
```

::: explicacion
With 1000 values, brute force may need 1000 steps; searching by halves, 10. With a million, the difference is between a million and 20.
:::

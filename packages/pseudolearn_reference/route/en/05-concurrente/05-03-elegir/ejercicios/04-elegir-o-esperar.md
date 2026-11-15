---
id: concurrente.elegir.elegir-o-esperar
leccion: concurrente.elegir
tipo: comparar
nivel: brote
obligatorio: true
titulo: Who serves first?
---

::: enunciado
Two bakeries send their bread offer, and only the first one matters. Ana waits for the two offers, one after another; Beto serves whichever arrives first. Who serves first?
:::

```opciones
- [x] Beto: he serves the first one ready without waiting for the other. | With only one answer that matters, waiting for the one that arrives later only adds waiting.
- [ ] Ana: waiting for both is safer. | Ana ends up with the first offer too, but only after both have arrived.
- [ ] Both at the same time. | Only if the two offers arrive together; in any other case Ana waits too long.
```

::: explicacion
It is the difference between awaiting one task after another and using `Select`: the second way serves the first answer ready.
:::

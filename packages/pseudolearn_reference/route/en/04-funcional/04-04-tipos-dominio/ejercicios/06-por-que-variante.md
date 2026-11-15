---
id: funcional.tipos-dominio.por-que-variante
leccion: funcional.tipos-dominio
tipo: explicar
nivel: semilla
obligatorio: false
titulo: What does the kiosk gain?
---

::: enunciado
What does the kiosk gain by keeping orders with one shape per state, instead of four loose values?
:::

```opciones
- [x] An order delivered with no time can no longer be written. | The delivered shape requires the time: the error disappears before running.
- [ ] The program takes less memory. | It is not what matters: what matters is what can be written.
- [ ] Decisions are no longer needed. | A `Switch` is needed, but the engine warns if a shape is missing.
```

::: explicacion
With loose values, you have to check everywhere that the data makes sense. With a variant, what makes no sense cannot be written.
:::

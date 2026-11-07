---
id: funcional.cara-a-cara.mezcla
leccion: funcional.cara-a-cara
tipo: explicar
nivel: brote
obligatorio: true
titulo: Why mix?
---

::: enunciado
Why does a real program usually mix the three ways of thinking?
:::

```opciones
- [x] Because each part of the program expects a different kind of change. | Calculations grow with new operations, things with state grow with new kinds, and the edge is short.
- [ ] Because that way it is faster. | Speed does not decide the way of thinking.
- [ ] Because none of them is any good on its own. | Each one works on its own; mixing them makes use of what each one makes easy.
```

::: explicacion
A real kiosk has calculations, best written as pure functions; things with state, such as the inventory, best written as objects; and an edge that reads and shows, which is imperative and short.
:::

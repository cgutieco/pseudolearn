---
id: funcional.cara-a-cara.medio-nuevo
leccion: funcional.cara-a-cara
tipo: comparar
nivel: brote
obligatorio: false
titulo: And a payment method?
---

::: enunciado
Now a new way of paying has to be added, with its own surcharge. In which version is less touched?
:::

```opciones
- [x] In the object one. | A new class that meets the payment methods contract; the till does not change.
- [ ] In the functional one. | A new function is enough, but every place that chooses the method needs to know it.
- [ ] In the imperative one. | Each decision about the payment method needs one more case.
```

::: explicacion
A payment method is a new kind of thing that shares a contract: it is the change objects make easy.
:::

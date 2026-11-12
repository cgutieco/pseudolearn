---
id: funcional.cara-a-cara.impuesto
leccion: funcional.cara-a-cara
tipo: comparar
nivel: brote
obligatorio: true
titulo: Where is a tax added?
---

::: enunciado
A 5 % tax has to be added to the total, before the discount. In which version of the kiosk is less touched?
:::

```opciones
- [x] In the functional one. | A new function `ConImpuesto` and the total expression change; nothing else is touched.
- [ ] In the object one. | The till methods that compute the total have to change, and its state has to be looked after.
- [ ] In the imperative one. | An assignment has to be added at the exact place in the order, and everything after it checked.
```

::: explicacion
A tax is a new operation on the same data: it is the change the functional version makes easy.
:::

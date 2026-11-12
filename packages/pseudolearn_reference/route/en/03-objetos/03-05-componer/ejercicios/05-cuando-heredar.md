---
id: objetos.componer.cuando-heredar
leccion: objetos.componer
tipo: explicar
nivel: brote
obligatorio: false
titulo: When does inheriting fit?
---

::: enunciado
When is it a good idea to write a kind of thing as a particular case of another, with `Inherits From`?
:::

```opciones
- [x] When the child is a particular case of the parent and there are no traits that combine. | A cashier is an employee; if there are no combinations, the hierarchy does not explode.
- [ ] Whenever two classes share code. | Sharing code is not enough: if the child is not a particular case, composing fits better.
- [ ] When an object holds another inside. | That is composing: a product has an offer.
```

::: explicacion
Inheriting says what something is, and works well with stable particular cases. When traits combine, the particular cases multiply and composing scales better.
:::

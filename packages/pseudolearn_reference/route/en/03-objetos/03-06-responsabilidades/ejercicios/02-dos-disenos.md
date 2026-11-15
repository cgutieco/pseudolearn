---
id: objetos.responsabilidades.dos-disenos
leccion: objetos.responsabilidades
tipo: comparar
nivel: brote
obligatorio: true
titulo: Two ways of sharing out
---

::: enunciado
In one design, the till computes each amount by multiplying the price by the quantity. In another, the product knows how to compute its amount and the till asks it. Now a tax has to be added to the amount of some products. Which design changes less?
:::

```opciones
- [x] The one that puts the calculation in the product. | The tax depends on the product: only the product's method changes, and the till stays the same.
- [ ] The one that puts the calculation in the till. | The till would have to know which products carry the tax, and so would every piece that computes amounts.
- [ ] Both change the same. | In one, a single piece changes; in the other, all those that compute amounts.
```

::: explicacion
The job belongs to whoever has the information. The price and the tax belong to the product: so does the calculation.
:::

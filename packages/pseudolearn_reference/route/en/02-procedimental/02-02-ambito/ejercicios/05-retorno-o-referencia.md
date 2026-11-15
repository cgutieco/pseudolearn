---
id: procedimental.ambito.retorno-o-referencia
leccion: procedimental.ambito
tipo: comparar
nivel: brote
obligatorio: false
titulo: How to give back the double?
---

::: enunciado
You have to write a piece that computes the double of a price. How should it give back the result?
:::

```opciones
- [x] Return the double, and let whoever calls keep it. | Whoever reads `price <- Double(price);` sees that the price changes.
- [ ] Receive the price by reference and change it inside. | It works, but the call `Double(price);` hides that the price changes.
- [ ] Show the double with `Write` inside the piece. | That way the result cannot be used in another sum.
```

::: explicacion
With a single result, returning keeps the change in view of whoever reads the program. Lending the box suits when more than one value has to come back.
:::

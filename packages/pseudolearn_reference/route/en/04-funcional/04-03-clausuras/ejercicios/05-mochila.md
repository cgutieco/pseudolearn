---
id: funcional.clausuras.mochila
leccion: funcional.clausuras
tipo: explicar
nivel: semilla
obligatorio: false
titulo: What is in the backpack?
---

::: enunciado
What does the function given back by `CrearDescuento(20)` keep in its backpack?
:::

```opciones
- [x] The 20. | It is the percentage the factory received and that the function uses each time it is called.
- [ ] The price. | The price arrives each time the function is called; it is not kept.
- [ ] The list of prices. | The function knows nothing about the list: it receives one price at a time.
```

::: explicacion
The backpack keeps what the function needs and does not receive as a parameter. That is why `Mapear` can use it with a single parameter, the price.
:::

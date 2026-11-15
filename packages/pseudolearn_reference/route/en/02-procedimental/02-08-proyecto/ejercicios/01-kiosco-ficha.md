---
id: procedimental.proyecto.kiosco-ficha
leccion: procedimental.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: The card of the till with stock
---

::: enunciado
Place each piece of data from the till with stock problem in its zone of the card.
:::

```categorias
- In
- Fixed value
- Out
```

```elementos
- The code and the amount of each sale | In
- The 0 that closes the till | In
- The prices of the products | Fixed value
- The stock each product starts with | Fixed value
- The discount of 1 peso every 10 | Fixed value
- The lines of the receipt and the rejections | Out
- The total and the total with discount | Out
- The stock left of each product | Out
```

::: explicacion
The initial stock is a fixed value, like the prices; the final stock is an output, because it depends on what was sold during the day.
:::

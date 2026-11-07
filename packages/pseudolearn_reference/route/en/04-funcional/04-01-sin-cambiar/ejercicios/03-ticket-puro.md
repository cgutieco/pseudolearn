---
id: funcional.sin-cambiar.ticket-puro
leccion: funcional.sin-cambiar
tipo: resolver
nivel: brote
obligatorio: true
titulo: A pure receipt
---

::: enunciado
Read two sales, each with a product code and an amount, and show the total with discount. The prices are the kiosk's: 1 Juice 3, 2 Sandwich 5, 3 Biscuit 2, 4 Water 1 and 5 Fruit 2. For every 10 pesos, 1 is taken off.
:::

::: restriccion
The price, the line amount and the discount are functions; the main algorithm only reads and shows.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | ConDescuento | 1 | The function ConDescuento, which receives the total, is missing.
```

::: pistas
1. Which part is calculation and which part touches the world?
2. Use the functions of the functional till of [the lesson](ruta:funcional.sin-cambiar).
3. One function for the price of a code, another for the amount of a line and another for the discount.
4. The main algorithm reads the four values and shows a single expression that composes the functions. Close with the variant.
:::

::: variante
Also show how much was saved with the discount, without computing anything twice.
:::

::: docentes
In «3, 5, 5, 0» there are 5 biscuits (10 pesos) and 0 fruit: total 10, with discount 9. The assertion checks that `ConDescuento` exists; that it is pure is checked by the engine when compiling it.
:::

---
id: funcional.sin-cambiar.nucleo-o-borde
leccion: funcional.sin-cambiar
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: Core or edge?
---

::: enunciado
The kiosk needs these jobs. Place each one in the centre that only computes or in the edge that touches the world.
:::

```categorias
- Core
- Edge
```

```elementos
- Compute the VAT of a price. | Core
- Decide whether a product has expired, given its date and today's date. | Core
- Ask the cashier how many products the customer has. | Edge
- Show the receipt. | Edge
- Find out today's date. | Edge
```

::: explicacion
The trap is the date: deciding whether a product has expired is pure if today's date arrives as data. Finding it out touches the world, because each day gives a different result.
:::

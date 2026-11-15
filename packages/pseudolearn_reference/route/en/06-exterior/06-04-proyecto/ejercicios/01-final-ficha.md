---
id: exterior.proyecto.final-ficha
leccion: exterior.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: The card of the complete kiosk
---

::: enunciado
Place each piece of data from the complete kiosk problem in its zone of the card.
:::

```categorias
- Goes in
- Fixed datum
- Comes out
- Does not matter
```

```elementos
- The inventory saved the day before | Goes in
- The code and the amount of each sale | Goes in
- The 0 that closes the till | Goes in
- The initial stock of each product | Fixed datum
- The prices of the products | Fixed datum
- The discount of 1 peso every 10 | Fixed datum
- The ticket with the total and the discount | Comes out
- The new inventory that stays saved | Comes out
- The time the break starts | Does not matter
```

::: explicacion
The saved inventory goes in, like the sales: it changes from one day to the next. The initial stock is a fixed datum that is only used when nothing is saved. The time of the break changes no sum.
:::

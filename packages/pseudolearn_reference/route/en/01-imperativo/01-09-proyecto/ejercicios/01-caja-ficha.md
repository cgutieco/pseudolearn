---
id: imperativo.proyecto.caja-ficha
leccion: imperativo.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: The till card
---

::: enunciado
Place each piece of data from the till problem in its zone of the card.
:::

```categorias
- In
- Fixed value
- Out
- Does not matter
```

```elementos
- The code of each sale | In
- The amount of each sale | In
- The 0 that closes the till | In
- The prices of the products | Fixed value
- The discount of 1 peso every 10 | Fixed value
- The lines of the receipt | Out
- The total and the total with discount | Out
- The best-selling product | Out
- The time of the break | Does not matter
```

::: explicacion
What the till writes during break goes in, including the 0, which is not a sale but the signal that they are over. The prices and the discount do not change from one day to the next: they are written in the program. The time of the break changes nothing on the receipt.
:::

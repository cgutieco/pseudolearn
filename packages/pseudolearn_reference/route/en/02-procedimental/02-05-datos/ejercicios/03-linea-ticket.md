---
id: procedimental.datos.linea-ticket
leccion: procedimental.datos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: A receipt line
---

::: enunciado
Read the name, the price and the amount of a product, in that order, and show the receipt line in the format `Jugo x 3 = 9`.
:::

::: restriccion
The name and the price are kept together in a record `Producto`.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Which values describe the product and which one describes the sale?
2. Look at the kiosk product in [the lesson](ruta:procedimental.datos).
3. The record keeps name and price; the amount belongs to the sale.
4. Create `Producto(nombre, precio)` and show its fields with the amount. Close with the variant.
:::

::: variante
Add a field `stock` and show how much is left after the sale.
:::

::: docentes
Hidden cases: amount 0 and price 1. The record does not change the output; it organises the data for the variant.
:::

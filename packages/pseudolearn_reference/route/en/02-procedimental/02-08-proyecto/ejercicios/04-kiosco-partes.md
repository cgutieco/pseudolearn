---
id: procedimental.proyecto.kiosco-partes
leccion: procedimental.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The till in parts
---

::: enunciado
Write the till with stock. Read pairs of code and amount until code 0 and show the receipt with the exact format of the lesson: a line `Jugo x 3 = 9` per accepted sale, `Sándwich x 6 rechazado: quedan 5` if the stock is not enough, «Código 9 no existe» and «Cantidad 0 no válida» for the other rejections; at the end `Total: `, `Con descuento: `, `Stock final:` and one line per product, in code order, such as `Jugo 7`.
:::

::: restriccion
Use at least three pure functions (for example, the price, the discount and the code check) and a record for the products.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Go back to your tree: which jobs are pure calculations and which ones read or write?
2. It is the till of [Part I](ruta:imperativo.proyecto), with the checks of [lesson 2.6](ruta:procedimental.fallos) and the records of [lesson 2.5](ruta:procedimental.datos).
3. A record `Producto` with name, price and stock in a vector; pure functions for the price, the discount and the valid code; the main algorithm reads, checks and shows.
4. Check in order: code, amount and stock. Only if all three pass, take off the stock, put the card back in the vector, write the line and add. Close with the variant.
:::

::: variante
Also show how many sales were rejected during the day and for which reason.
:::

::: explicacion
The app's closed catalogue of checks cannot count pure functions or require a record: the restriction asks for them, and the cases tell the three rejections apart with their exact reason. Hidden cases: a sale that leaves the stock exactly at 0 and the next one rejected, a sale of 0 units, everything rejected, sales that use up three products, stock rejections after accepted sales and a single sale.
:::

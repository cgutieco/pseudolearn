---
id: procedimental.datos.paralelos-a-registros
leccion: procedimental.datos
tipo: modificar
nivel: arbol
obligatorio: false
titulo: From separate rows to cards
---

::: enunciado
This program reads three products (name and price) in separate rows and shows them. Now each product also brings its stock, which is read after the price. Change the program so that it shows each product as `Jugo 3 (quedan 10)`.
:::

::: restriccion
Each product is kept as a card with its three values together, in a vector.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. With separate rows, how many things do you have to touch to add the stock?
2. Look at the end of [the lesson](ruta:procedimental.datos): adding a value to a card is adding a field.
3. Define a card with name, price and stock, and keep the three in a vector.
4. A record `Producto` with three fields, a vector filled in the first loop and a `For Each` that shows. Close with the variant.
:::

::: variante
Show at the end the product with the least stock.
:::

::: docentes
The app's catalogue of checks cannot require a record; the restriction asks for it, and the cases require the new stock. Frequent mistake: adding a third separate row, which works but leaves three rows to keep aligned.
:::

---
id: imperativo.proyecto.caja
leccion: imperativo.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The kiosk till
---

::: enunciado
Write the till program. Read pairs of code and amount until code 0 and show the receipt with the exact format of the lesson: one line per sale such as `Jugo x 3 = 9`, «Código 7 no existe» if the code is invalid, and at the end `Total: `, `Con descuento: ` and `Más vendido: ` with their value, or `Ninguno` if there were no sales. In a tie of units, the product with the lowest code wins.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Go back to your card: which boxes do you need to remember what happened all day?
2. It is the dictated money box of [lesson 1.3](ruta:imperativo.mientras), with arrays as in [lesson 1.5](ruta:imperativo.arreglos) and the best seller of [lesson 1.4](ruta:imperativo.contado).
3. Three parallel arrays: names, prices and units sold. The code minus 1 is the index.
4. Read the code; while it is not 0, read the amount, check, write the line and add; at the end, the total, the discount and the search for the best seller. Close with the variant.
:::

::: variante
Add to the closing how many valid sales there were and the average price per sale.
:::

::: explicacion
Hidden cases: an invalid code in the middle, a tie (biscuit and juice with 2 units: juice wins, with the lowest code), a single sale, the five products, large amounts and a day whose only sale is invalid. Frequent mistake: searching for the best seller with `>=`, which in a tie picks the one with the highest code.
:::

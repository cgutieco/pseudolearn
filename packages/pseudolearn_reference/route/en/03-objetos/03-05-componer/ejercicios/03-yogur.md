---
id: objetos.componer.yogur
leccion: objetos.componer
tipo: modificar
nivel: brote
obligatorio: true
titulo: The yoghurt that had no place
---

::: enunciado
The program reads a type of product (1 normal, 2 expires soon, 3 on a 25 % offer, 4 both) and its price, and shows the final price. A product that expires soon sells at half price. Type 4 does not work: it is charged as a normal product. Rewrite the program so that the traits combine, without changing the prices of the other types.
:::

::: restriccion
The product holds its traits inside, instead of having a particular case for each combination.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. How many particular cases would be needed if one more trait were added?
2. Look at the product that has traits in [the lesson](ruta:objetos.componer).
3. Each trait is a class that knows how to apply its part to the price; the product has each one.
4. A `Producto` that has an offer and an expiry (of 0 % and far away if they do not apply), and a `PrecioFinal` that applies both. Close with the variant.
:::

::: variante
Add the deposit bottle, which adds 2 pesos to the price. How many new classes are needed?
:::

::: explicacion
The app's catalogue of checks cannot forbid a class from inheriting from another; the restriction asks for it and type 4 requires it, because with inheritance one more class would be needed. Hidden cases: each trait alone, the combination with another price and a price of 0.
:::

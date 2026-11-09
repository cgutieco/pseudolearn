---
id: exterior.proyecto.final-nucleo
leccion: exterior.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The core of the kiosk
---

::: enunciado
Write the core of the kiosk, without files: start with the initial stock, read the sales, code and amount, until a 0, and check each one with the rules of Part II. At the end show the total, the total with discount and «Inventario: » with the final inventory in JSON, as in the lesson.
:::

::: restriccion
The JSON text of the inventory is built by a pure function, `InventarioJson`, which receives the list of products.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | InventarioJson | 1 | The function InventarioJson, which receives the list of products, is missing.
```

::: pistas
1. Go back to your card and your plan: which steps belong to the core?
2. It is the till with stock of Part II; only the closing changes.
3. `InventarioJson` walks through the products and joins each pair with commas, between braces, like the inventory of lesson 6.2.
4. The first entry carries no comma before it: check whether the text is still only the brace. Close with the variant.
:::

::: variante
Add to the closing how many sales were rejected.
:::

::: explicacion
Hidden cases: an invalid sale in the middle, a sale that leaves a stock at 0, one that asks for more than there is, the five products, large amounts rejected, a day with only rejections and an amount of 0. The keys of the JSON are the names of the catalogue, with a capital letter and an accent.
:::

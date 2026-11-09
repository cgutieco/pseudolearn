---
id: exterior.archivos.linea-stock
leccion: exterior.archivos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: One line of the file
---

::: enunciado
Read the name of a product and its stock, and show the line that is saved in the file: the name, a semicolon and the stock, like «jugo;10».
:::

::: restriccion
The line is built by a pure function, `LineaStock`, which receives the name and the stock.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | LineaStock | 2 | The function LineaStock, which receives the name and the stock, is missing.
```

::: pistas
1. Which part of the line is fixed and which part changes?
2. It is the function of the lesson: it joins the name, the semicolon and the stock.
3. The stock is a number: turn it into text with `toText` before joining it.
4. The algorithm reads, calls the function and shows what it gives back. Close with the variant.
:::

::: variante
Make another function that builds the line with the price as well as the stock: «jugo;10;3».
:::

::: explicacion
The function opens no file: that is why it can be tested on its own. The cases include stock 0, a three-digit number and a name with an accent.
:::

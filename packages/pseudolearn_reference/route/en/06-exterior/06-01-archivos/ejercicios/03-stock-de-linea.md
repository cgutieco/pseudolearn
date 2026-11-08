---
id: exterior.archivos.stock-de-linea
leccion: exterior.archivos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Reading a line
---

::: enunciado
Read a line of the file, like «jugo;10», and show «jugo tiene 10». If the line has no semicolon, show «Línea inválida». If it has more than one, the name is what goes before the first one.
:::

::: restriccion
The text is built by a pure function, `StockDeLinea`, which receives the line.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | StockDeLinea | 1 | The function StockDeLinea, which receives the line, is missing.
```

::: pistas
1. What separates the name from the stock?
2. `indexOf` says where the first semicolon is, or `None` if there is none.
3. With that position, `substring` cuts what comes before and what comes after.
4. A `Switch` on the position chooses between the message and «Línea inválida». Close with the variant.
:::

::: variante
Make the function give back «Línea inválida» also when the name is empty.
:::

::: docentes
It is the inverse of `LineaStock`. «x;y;3» confirms that the cut is at the first semicolon: what comes after stays whole, even if it has another one.
:::

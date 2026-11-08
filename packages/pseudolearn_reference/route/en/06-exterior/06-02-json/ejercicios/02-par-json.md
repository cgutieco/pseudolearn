---
id: exterior.json.par-json
leccion: exterior.json
tipo: resolver
nivel: semilla
obligatorio: true
titulo: A product in JSON
---

::: enunciado
Read the name of a product and its stock, and show the JSON text with that single pair between braces, like {"jugo": 10}.
:::

::: restriccion
The text is built by a pure function, `ParJson`, which receives the name and the stock.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | ParJson | 2 | The function ParJson, which receives the name and the stock, is missing.
```

::: pistas
1. Which parts of the text are fixed and which change?
2. It is like the line «jugo;10» of the previous lesson, with braces, quotes and a colon.
3. A text between single quotes can carry double quotes inside.
4. Join the brace, the key between quotes, the colon, the stock with `toText` and the closing brace. Close with the variant.
:::

::: variante
Check the result with `parseJson` before showing it.
:::

::: docentes
The space after the colon is part of the format asked for. The cases include stock 0 and a three-digit number.
:::

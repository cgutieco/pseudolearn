---
id: exterior.json.dos-pares
leccion: exterior.json
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Two products in JSON
---

::: enunciado
Read two products, each one with its name and its stock, and show the JSON text with the two pairs between braces, like {"jugo": 10, "agua": 12}.
:::

::: restriccion
Each pair is built by a pure function, `ParJson`, which receives the name and the stock.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | ParJson | 2 | The function ParJson, which receives the name and the stock, is missing.
```

::: pistas
1. Which part is repeated for each product?
2. Each pair is the key between quotes, a colon and the stock, without braces.
3. The algorithm puts the braces and the comma between the two pairs.
4. Call `ParJson` twice and join everything in a single `Write`. Close with the variant.
:::

::: variante
Extend it to the five products of the kiosk, as in the lesson.
:::

::: docentes
Separating the pair from the object lets you reuse `ParJson` for any number of products. A name with an accent changes nothing: JSON accepts any text.
:::

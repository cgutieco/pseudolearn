---
id: exterior.json.par-json
leccion: exterior.json
tipo: resolver
nivel: semilla
obligatorio: true
titulo: A product in JSON
---

::: enunciado
Read the name of a product and its stock, and show the JSON text with that single pair between braces, like {"juice": 10}.
:::

::: restriccion
The text is built by a pure function, `JsonPair`, which receives the name and the stock.
:::

```programa rol=referencia
Funcion pair <- JsonPair(name Como Cadena, stock Como Entero)
  Definir pair Como Cadena;
  pair <- '{"' + name + '": ' + ATexto(stock) + "}";
FinFuncion

Algoritmo Pair
  Definir name Como Cadena;
  Definir stock Como Entero;
  Leer name;
  Leer stock;
  Escribir JsonPair(name, stock);
FinAlgoritmo
```

```casos
visible | juice ; 10 | {"juice": 10}
visible | water ; 0 | {"water": 0}
oculto | fruit ; 6 | {"fruit": 6}
oculto | biscuit ; 125 | {"biscuit": 125}
oculto | sandwich ; 1 | {"sandwich": 1}
```

```aserciones
- declara-subprograma | JsonPair | 2 | The function JsonPair, which receives the name and the stock, is missing.
```

::: pistas
1. Which parts of the text are fixed and which change?
2. It is like the line «juice;10» of the previous lesson, with braces, quotes and a colon.
3. A text between single quotes can carry double quotes inside.
4. Join the brace, the key between quotes, the colon, the stock with `toText` and the closing brace. Close with the variant.
:::

::: variante
Check the result with `parseJson` before showing it.
:::

::: explicacion
The space after the colon is part of the format asked for. The cases include stock 0 and a three-digit number.
:::

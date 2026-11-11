---
id: exterior.json.dos-pares
leccion: exterior.json
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Two products in JSON
---

::: enunciado
Read two products, each one with its name and its stock, and show the JSON text with the two pairs between braces, like {"juice": 10, "water": 12}.
:::

::: restriccion
Each pair is built by a pure function, `JsonPair`, which receives the name and the stock.
:::

```programa rol=referencia
Funcion pair <- JsonPair(name Como Cadena, stock Como Entero)
  Definir pair Como Cadena;
  pair <- '"' + name + '": ' + ATexto(stock);
FinFuncion

Algoritmo TwoPairs
  Definir primero Como Cadena;
  Definir firstStock Como Entero;
  Definir segundo Como Cadena;
  Definir secondStock Como Entero;
  Leer primero;
  Leer firstStock;
  Leer segundo;
  Leer secondStock;
  Escribir "{", JsonPair(primero, firstStock), ", ", JsonPair(segundo, secondStock), "}";
FinAlgoritmo
```

```casos
visible | juice ; 10 ; water ; 12 | {"juice": 10, "water": 12}
visible | a ; 0 ; b ; 0 | {"a": 0, "b": 0}
oculto | fruit ; 6 ; biscuit ; 8 | {"fruit": 6, "biscuit": 8}
oculto | café ; 1 ; sandwich ; 125 | {"café": 1, "sandwich": 125}
oculto | x ; 3 ; y ; 4 | {"x": 3, "y": 4}
```

```aserciones
- declara-subprograma | JsonPair | 2 | The function JsonPair, which receives the name and the stock, is missing.
```

::: pistas
1. Which part is repeated for each product?
2. Each pair is the key between quotes, a colon and the stock, without braces.
3. The algorithm puts the braces and the comma between the two pairs.
4. Call `JsonPair` twice and join everything in a single `Write`. Close with the variant.
:::

::: variante
Extend it to the five products of the kiosk, as in the lesson.
:::

::: explicacion
Separating the pair from the object lets you reuse `JsonPair` for any number of products. A name with an accent changes nothing: JSON accepts any text.
:::

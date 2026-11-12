---
id: exterior.archivos.stock-de-linea
leccion: exterior.archivos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Reading a line
---

::: enunciado
Read a line of the file, like «juice;10», and show «juice has 10». If the line has no semicolon, show «Invalid line». If it has more than one, the name is what goes before the first one.
:::

::: restriccion
The text is built by a pure function, `StockFromLine`, which receives the line.
:::

```programa rol=referencia
Funcion message <- StockFromLine(line Como Cadena)
  Definir message Como Cadena;
  Segun PosicionDe(line, ";") Hacer
    Algo(cut):
      message <- Subcadena(line, 0, cut - 1) + " has " + Subcadena(line, cut + 1, Longitud(line) - 1);
    Nada: message <- "Invalid line";
  FinSegun
FinFuncion

Algoritmo ReadLine
  Definir line Como Cadena;
  Leer line;
  Escribir StockFromLine(line);
FinAlgoritmo
```

```casos
visible | juice;10 | juice has 10
visible | water | Invalid line
oculto | fruit;0 | fruit has 0
oculto | x;y;3 | x has y;3
oculto | café;1 | café has 1
```

```aserciones
- declara-subprograma | StockFromLine | 1 | The function StockFromLine, which receives the line, is missing.
```

::: pistas
1. What separates the name from the stock?
2. `indexOf` says where the first semicolon is, or `None` if there is none.
3. With that position, `substring` cuts what comes before and what comes after.
4. A `Switch` on the position chooses between the message and «Invalid line». Close with the variant.
:::

::: variante
Make the function give back «Invalid line» also when the name is empty.
:::

::: explicacion
It is the inverse of `StockLine`. «x;y;3» confirms that the cut is at the first semicolon: what comes after stays whole, even if it has another one.
:::

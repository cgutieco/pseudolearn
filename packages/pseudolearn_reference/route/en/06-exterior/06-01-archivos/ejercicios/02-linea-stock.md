---
id: exterior.archivos.linea-stock
leccion: exterior.archivos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: One line of the file
---

::: enunciado
Read the name of a product and its stock, and show the line that is saved in the file: the name, a semicolon and the stock, like «juice;10».
:::

::: restriccion
The line is built by a pure function, `StockLine`, which receives the name and the stock.
:::

```programa rol=referencia
Funcion line <- StockLine(name Como Cadena, stock Como Entero)
  Definir line Como Cadena;
  line <- name + ";" + ATexto(stock);
FinFuncion

Algoritmo FileLine
  Definir name Como Cadena;
  Definir stock Como Entero;
  Leer name;
  Leer stock;
  Escribir StockLine(name, stock);
FinAlgoritmo
```

```casos
visible | juice ; 10 | juice;10
visible | water ; 0 | water;0
oculto | fruit ; 6 | fruit;6
oculto | biscuit ; 125 | biscuit;125
oculto | café ; 1 | café;1
```

```aserciones
- declara-subprograma | StockLine | 2 | The function StockLine, which receives the name and the stock, is missing.
```

::: pistas
1. Which part of the line is fixed and which part changes?
2. It is the function of the lesson: it joins the name, the semicolon and the stock.
3. The stock is a number: turn it into text with `toText` before joining it.
4. The algorithm reads, calls the function and shows what it gives back. Close with the variant.
:::

::: variante
Make another function that builds the line with the price as well as the stock: «juice;10;3».
:::

::: explicacion
The function opens no file: that is why it can be tested on its own. The cases include stock 0, a three-digit number and a name with an accent.
:::

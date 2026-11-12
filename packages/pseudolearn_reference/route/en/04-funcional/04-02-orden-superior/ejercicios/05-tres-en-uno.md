---
id: funcional.orden-superior.tres-en-uno
leccion: funcional.orden-superior
tipo: modificar
nivel: brote
obligatorio: false
titulo: Three in one
---

::: enunciado
This program reads five prices and shows three lists: the prices with 1 peso more, doubled and with 1 peso less. It has three almost identical walks. Rewrite it with a single walk that receives the operation, without changing what it shows.
:::

::: restriccion
A function `Map` that receives the vector and the operation, and three small functions that are passed to it.
:::

```programa rol=inicial
Algoritmo Prices
  Definir prices Como Vector<Entero> <- Vector();
  Definir entered Como Entero;
  Para i <- 1 Hasta 5 Hacer
    Leer entered;
    prices.Agregar(entered);
  FinPara
  Definir changed Como Vector<Entero> <- Vector();
  Para Cada price En prices Hacer
    changed.Agregar(price + 1);
  FinPara
  Escribir changed;
  changed <- Vector();
  Para Cada price En prices Hacer
    changed.Agregar(price * 2);
  FinPara
  Escribir changed;
  changed <- Vector();
  Para Cada price En prices Hacer
    changed.Agregar(price - 1);
  FinPara
  Escribir changed;
FinAlgoritmo
```

```programa rol=referencia
Funcion next <- PlusOne(x Como Entero)
  Definir next Como Entero;
  next <- x + 1;
FinFuncion

Funcion twice <- Double(x Como Entero)
  Definir twice Como Entero;
  twice <- x * 2;
FinFuncion

Funcion previous <- MinusOne(x Como Entero)
  Definir previous Como Entero;
  previous <- x - 1;
FinFuncion

Funcion mapped <- Map(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir mapped Como Vector<Entero> <- Vector();
  Para Cada item En v Hacer
    mapped.Agregar(f(item));
  FinPara
FinFuncion

Algoritmo Prices
  Definir prices Como Vector<Entero> <- Vector();
  Definir entered Como Entero;
  Para i <- 1 Hasta 5 Hacer
    Leer entered;
    prices.Agregar(entered);
  FinPara
  Escribir Map(prices, PlusOne);
  Escribir Map(prices, Double);
  Escribir Map(prices, MinusOne);
FinAlgoritmo
```

```casos
```

```aserciones
- declara-subprograma | Map | 2 | The function Map, which receives the vector and the operation, is missing.
```

::: pistas
1. Which line changes between the three walks?
2. Look at the `Map` of [the lesson](ruta:funcional.orden-superior).
3. Each operation is a function of one number; the walk is a single one.
4. Three calls: `Map(prices, PlusOne)`, `Map(prices, Double)` and `Map(prices, MinusOne)`. Close with the variant.
:::

::: variante
Add a fourth vector with the prices squared. How many lines did you write?
:::

::: explicacion
The assertion checks that `Map` exists. The cases are those of the initial program: what is shown does not change.
:::

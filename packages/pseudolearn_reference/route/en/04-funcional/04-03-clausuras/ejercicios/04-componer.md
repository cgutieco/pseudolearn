---
id: funcional.clausuras.componer
leccion: funcional.clausuras
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Composing two functions
---

::: enunciado
Read a number and show two results, one per line: first double the number plus one, and then double the next number.
:::

::: restriccion
A function `Compose(f, g)` that gives back a function that applies `g` and then `f`, used with `PlusOne` and `Double` in both orders.
:::

```programa rol=referencia
Funcion next <- PlusOne(x Como Entero)
  Definir next Como Entero;
  next <- x + 1;
FinFuncion

Funcion twice <- Double(x Como Entero)
  Definir twice Como Entero;
  twice <- x * 2;
FinFuncion

Funcion composed <- Compose(f Como Funcion(Entero) Como Entero, g Como Funcion(Entero) Como Entero)
  Definir composed Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar f(g(x));
  FinFuncion;
FinFuncion

Algoritmo Composition
  Definir x Como Entero;
  Leer x;
  Definir doublePlusOne Como Funcion(Entero) Como Entero <- Compose(PlusOne, Double);
  Definir doubleOfNext Como Funcion(Entero) Como Entero <- Compose(Double, PlusOne);
  Escribir doublePlusOne(x);
  Escribir doubleOfNext(x);
FinAlgoritmo
```

```casos
```

```aserciones
- declara-subprograma | Compose | 2 | The function Compose, which receives two functions, is missing.
```

::: pistas
1. «Double plus one» and «double of the next one»: what is applied first in each case?
2. `Compose` is a factory, like the adder of [the lesson](ruta:funcional.clausuras), that carries two functions in its backpack.
3. The manufactured function receives `x` and returns `f(g(x))`.
4. `Compose(PlusOne, Double)` gives double plus one; `Compose(Double, PlusOne)`, double of the next one. Close with the variant.
:::

::: variante
Use `Compose` twice to build «double of double plus one».
:::

::: explicacion
The order matters: composing is not commutative. Hidden cases: negatives, 10 and 1.
:::

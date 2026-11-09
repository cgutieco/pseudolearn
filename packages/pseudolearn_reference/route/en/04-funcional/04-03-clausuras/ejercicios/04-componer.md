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
A function `Componer(f, g)` that gives back a function that applies `g` and then `f`, used with `MasUno` and `Doble` in both orders.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Componer | 2 | The function Componer, which receives two functions, is missing.
```

::: pistas
1. «Double plus one» and «double of the next one»: what is applied first in each case?
2. `Componer` is a factory, like the adder of [the lesson](ruta:funcional.clausuras), that carries two functions in its backpack.
3. The manufactured function receives `x` and returns `f(g(x))`.
4. `Componer(MasUno, Doble)` gives double plus one; `Componer(Doble, MasUno)`, double of the next one. Close with the variant.
:::

::: variante
Use `Componer` twice to build «double of double plus one».
:::

::: explicacion
The order matters: composing is not commutative. Hidden cases: negatives, 10 and 1.
:::

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
A function `Mapear` that receives the vector and the operation, and three small functions that are passed to it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Mapear | 2 | The function Mapear, which receives the vector and the operation, is missing.
```

::: pistas
1. Which line changes between the three walks?
2. Look at the `Mapear` of [the lesson](ruta:funcional.orden-superior).
3. Each operation is a function of one number; the walk is a single one.
4. Three calls: `Mapear(precios, MasUno)`, `Mapear(precios, Doble)` and `Mapear(precios, MenosUno)`. Close with the variant.
:::

::: variante
Add a fourth vector with the prices squared. How many lines did you write?
:::

::: docentes
The assertion checks that `Mapear` exists. The cases are those of the initial program: what is shown does not change.
:::

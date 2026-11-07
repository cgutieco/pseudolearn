---
id: funcional.orden-superior.pares
leccion: funcional.orden-superior
tipo: resolver
nivel: brote
obligatorio: true
titulo: Only the even ones
---

::: enunciado
Read numbers until a 0 and show the list of the even ones, in the order they arrived, such as `[4, 2]`.
:::

::: restriccion
A function `Filtrar` that receives the vector and a condition, and a function `EsPar` that is passed to it as a value.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Filtrar | 2 | The function Filtrar, which receives the vector and the condition, is missing.
```

::: pistas
1. Does the result have the same length as the numbers read?
2. It is the `Filtrar` of [the lesson](ruta:funcional.orden-superior), with another condition.
3. Keep the numbers in a vector; the condition is a function that says whether a number is even.
4. `Write Filtrar(numeros, EsPar);` after reading. Close with the variant.
:::

::: variante
Show the sum of the even ones with `Reducir`.
:::

::: docentes
Hidden cases: no even number, 0 straight away and negative even numbers. Frequent mistake: passing `EsPar(x)`, which is a value and not the function.
:::

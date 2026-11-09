---
id: funcional.orden-superior.maximo-reducir
leccion: funcional.orden-superior
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The greatest, by reducing
---

::: enunciado
Read numbers until a 0 and show the greatest. If no number arrived, show «Sin números».
:::

::: restriccion
The greatest is computed with `Reducir` and a function `Mayor` of two numbers.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Reducir | 3 | The function Reducir, which receives the vector, the function and the initial value, is missing.
```

::: pistas
1. Which value does the greatest have to start with? Does 0 work?
2. It is the `Reducir` of [the lesson](ruta:funcional.orden-superior), with another function.
3. `Mayor(a, b)` returns the greater of the two; the initial value is the first number read.
4. If the vector is empty, show the message; otherwise, `Reducir(numeros, Mayor, numeros[0])`. Close with the variant.
:::

::: variante
Also show the smallest, without writing another walk.
:::

::: explicacion
Starting at 0 fails with all negatives: that is why the initial value is the first number. Hidden cases: all negative, none and repeats.
:::

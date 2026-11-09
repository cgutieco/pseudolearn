---
id: procedimental.recursion.potencia
leccion: procedimental.recursion
tipo: resolver
nivel: brote
obligatorio: true
titulo: The power
---

::: enunciado
Read a base and a non-negative exponent, in that order, and show the base raised to the exponent. The program shows only the number.
:::

::: restriccion
No loops: the power is computed with a function that calls itself.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- no-contiene | bucle-condicional | No loops: the power is computed with recursion.
- no-contiene | bucle-condicional-posterior | No loops: the power is computed with recursion.
- no-contiene | bucle-contado | No loops: the power is computed with recursion.
```

::: pistas
1. What is any number raised to 0? And raised to 1?
2. It looks like the factorial of [the lesson](ruta:procedimental.recursion): a multiplication by a smaller version.
3. `base` raised to `exponente` is `base` times `base` raised to `exponente - 1`.
4. If the exponent is 0, the result is 1; otherwise, `base * Potencia(base, exponente - 1)`. Close with the variant.
:::

::: variante
Make it faster: if the exponent is even, `Potencia(base, exponente)` is the square of `Potencia(base, exponente div 2)`.
:::

::: explicacion
The assertions reject any loop. Hidden cases: exponent 1, base 1 with a large exponent and exponent 0 among the visible ones.
:::

---
id: procedimental.recursion.suma-sin-fin
leccion: procedimental.recursion
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The sum that never ends
---

::: enunciado
This program reads a non-negative number and should show the sum from 1 to that number. But it never ends well. Find the error and fix it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Is it a compile error, a runtime error or a logic error? What does the engine say?
2. Compare with the factorial of [the lesson](ruta:procedimental.recursion). Which part is this function missing?
3. What is the smallest sum you already know without computing anything?
4. If `n` is 0, the sum is 0; otherwise, `n + SumaHasta(n - 1)`. Close with the variant.
:::

::: variante
Write `SumaPares(n)`, the sum of the even numbers from 2 to `n`.
:::

::: docentes
Without a base case, the function calls itself with -1, -2, … until the engine stops it by depth. The 100 case checks that the reference does not run out of frames.
:::

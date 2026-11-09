---
id: imperativo.contado.primo-romper
leccion: imperativo.contado
tipo: romperlo
nivel: brote
obligatorio: true
titulo: An overconfident prime
---

::: enunciado
This program gets 7 and 9 right. Find a number it gets wrong.
:::

```programa rol=defectuoso
```

```programa rol=referencia
```

```casos
```

```rompe
```

::: pistas
1. Go back to the card in the lesson. Which examples are edge cases?
2. What happens with a number for which the loop makes zero passes?
3. If there are no divisors to try, the answer depends only on the value the answer box starts with.
4. With 1 the program says «Es primo», and 1 is not prime. Close with the variant.
:::

::: variante
Is there any number greater than 1 that breaks it? (No: for all of them the loop tries at least one divisor or, with 2, none and gets it right.)
:::

::: explicacion
1, 0 and the negatives break the program: for them the loop makes no passes and the answer stays true. The reference starts with `n >= 2`.
:::

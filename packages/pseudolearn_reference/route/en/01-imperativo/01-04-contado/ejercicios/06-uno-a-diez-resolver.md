---
id: imperativo.contado.uno-a-diez-resolver
leccion: imperativo.contado
tipo: resolver
nivel: brote
obligatorio: false
titulo: Until it is in range
---

::: enunciado
Ask for a number again and again until it is between 1 and 10, both included, and show `Aceptado: ` followed by the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many times do you have to read at least? Do you know how many at most?
2. Look at the figure for choosing the way of repeating in [the lesson](ruta:imperativo.contado).
3. The condition to finish combines two comparisons.
4. `Repeat` with `Read n;` and `Until n >= 1 And n <= 10`. Close with the variant.
:::

::: variante
Also show how many attempts were needed. (With 0, 15 and 7: 3 attempts.)
:::

::: explicacion
Hidden cases: the edges 10 and 1 and several invalid attempts in a row. Frequent mistake: `Or` instead of `And`, which accepts any number.
:::

---
id: inicio.primer-problema.mesas
leccion: inicio.primer-problema
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The canteen tables
---

::: enunciado
After the pizza, the 23 people at the party sit down in the canteen. Each table has 4 chairs. How many tables must be set up so that nobody is left standing? The program shows only the number.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Can the answer have decimals? What happens to the person who does not fill a table?
2. It is the same problem as the pizzas in [the lesson](ruta:inicio.primer-problema), with other numbers.
3. You only need one instruction inside the envelope of the program: show the sum rounded up.
4. `Write ceil(23 / 4);` shows 6. Close the exercise with the variant.
:::

::: variante
The new tables have 6 chairs. How many are needed now? (Answer: 4.)
:::

::: docentes
Solution: `Write ceil(23 / 4);`. Frequent mistake: answering 5, which leaves three people standing, or 5.75. There are no hidden cases: before reading values, the program has a single case.
:::

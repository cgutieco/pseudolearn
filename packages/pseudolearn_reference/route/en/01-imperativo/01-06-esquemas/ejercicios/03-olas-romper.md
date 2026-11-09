---
id: imperativo.esquemas.olas-romper
leccion: imperativo.esquemas
tipo: romperlo
nivel: brote
obligatorio: true
titulo: The waves that get away
---

::: enunciado
This heat wave program gets the lesson's case right. Find 14 temperatures it gets wrong.
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
1. Go back to the card in the lesson. Which edge case does the task's example not test?
2. Compare both programs. Which part of the lesson is this one missing?
3. Look for a wave that has not broken yet when the data runs out.
4. With the last three days above 30, the good one says one wave of 3 and this one says 0. Close with the variant.
:::

::: variante
What does this program show if all 14 days are above 30? (Olas: 0. The good one says a wave of 14.)
:::

::: explicacion
The program is missing the closing of the last streak after the loop. Any series whose last streak of 3 or more days reaches the end breaks it.
:::

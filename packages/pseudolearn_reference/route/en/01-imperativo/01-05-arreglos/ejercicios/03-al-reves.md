---
id: imperativo.arreglos.al-reves
leccion: imperativo.arreglos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Backwards
---

::: enunciado
Read 5 numbers and show them in reverse order, one per line.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Can you start showing before you have read the last number?
2. Keep the five in an array, like the temperatures in [the lesson](ruta:imperativo.arreglos).
3. To show them backwards, the index has to go from the last to the first.
4. One loop that reads from 0 to 4 and another that shows from 4 to 0 `Step -1`. Close with the variant.
:::

::: variante
Show only the ones in even positions: 0, 2 and 4.
:::

::: explicacion
Hidden cases: repeated numbers that make a program that does not reverse look right (7, 7, 7) and negatives. Frequent mistake: starting the second loop at 5.
:::

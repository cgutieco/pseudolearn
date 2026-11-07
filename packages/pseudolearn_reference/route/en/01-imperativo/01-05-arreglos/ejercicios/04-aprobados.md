---
id: imperativo.arreglos.aprobados
leccion: imperativo.arreglos
tipo: resolver
nivel: brote
obligatorio: false
titulo: How many passed?
---

::: enunciado
Read 6 marks, from 0 to 10, and show how many are 6 or more. The program shows only the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Where is the edge between passing and failing? On which side is 6?
2. Keep the marks and walk through them; for each one, a question.
3. A box counts the ones that meet it. If you do not need the position, you can walk through without an index.
4. Walk through with `For Each` and add 1 when the mark is 6 or more. Close with the variant.
:::

::: variante
Also show the average of the passing marks, or «Nadie aprobó».
:::

::: docentes
The edge is 6, which passes. Hidden cases: all on the edge and nobody passing. Frequent mistake: `> 6`.
:::

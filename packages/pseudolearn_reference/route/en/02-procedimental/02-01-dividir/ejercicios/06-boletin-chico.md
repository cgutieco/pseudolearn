---
id: procedimental.dividir.boletin-chico
leccion: procedimental.dividir
tipo: resolver
nivel: arbol
obligatorio: false
titulo: A smaller report card
---

::: enunciado
Three pupils have two marks each. Read, for each pupil, their name and their two marks. Show one line per pupil in the format `Ana: 7.5 aprobado` (a pupil passes with an average of 6 or more, otherwise `desaprobado`) and at the end `Mejor promedio: ` with the name. If there is a tie for the best average, the first one read wins.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Draw the decomposition tree of this report card. Which branches does it have?
2. It is the report card of [the lesson](ruta:procedimental.dividir) with two marks and three pupils.
3. One subprogram for the average, another for the status and the best so far in the main one. Which sign respects the tie?
4. Replace the best only if the new average is strictly greater. Close with the variant.
:::

::: variante
If there is a tie, show all the tied names.
:::

::: explicacion
The first one wins the tie because the comparison is strict. Hidden cases: a tie for first place, everyone failing and an average of exactly 6.0 in the second visible case.
:::

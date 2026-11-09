---
id: imperativo.esquemas.sin-lluvia
leccion: imperativo.esquemas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The dry streak
---

::: enunciado
Read 10 days: 1 if it rained and 0 if not. Show how many days the longest streak without rain lasted. The program shows only the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. It is a relative of the heat waves in [the lesson](ruta:imperativo.esquemas). What changes?
2. One box follows the current streak and another remembers the longest.
3. If you update the longest on each dry day, there is no need to check anything after the loop.
4. Dry: the streak goes up and, if it passes the longest, replaces it. Rain: the streak goes back to 0. Close with the variant.
:::

::: variante
Also show on which day the longest streak started.
:::

::: explicacion
Updating the longest inside the dry branch avoids the last streak error. Hidden cases: ten dry days and the longest streak at the end.
:::

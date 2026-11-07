---
id: procedimental.fallos.fecha
leccion: procedimental.fallos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Is it a valid date?
---

::: enunciado
Read a day and a month of a year that is not a leap year, in that order. Show «válida» (valid), «día fuera de rango» (day out of range) or «mes fuera de rango» (month out of range). If the month does not exist, that is the reason, even if the day is also wrong.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many days does each month have? Which is validated first, the day or the month?
2. They are the two filters in a row of [the lesson](ruta:procedimental.fallos).
3. One subprogram says how many days a month has; another applies the filters and returns the reason of the first one that fails.
4. First the month between 1 and 12; then the day between 1 and the days of that month. Close with the variant.
:::

::: variante
Add the year and take into account the leap years of [lesson 1.2](ruta:imperativo.caminos).
:::

::: docentes
Hidden cases: 29 February, the edges of April and December, day 0 and a case with both values wrong, where the month rules.
:::

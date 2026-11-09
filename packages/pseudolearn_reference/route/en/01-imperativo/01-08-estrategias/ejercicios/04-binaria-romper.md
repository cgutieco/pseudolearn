---
id: imperativo.estrategias.binaria-romper
leccion: imperativo.estrategias
tipo: romperlo
nivel: brote
obligatorio: true
titulo: The middle that does not move
---

::: enunciado
This search by halves finds the number in the centre. Find a searched number it gets wrong. The ten numbers are 1, 2, 3, 4, 5, 6, 7, 8, 9 and 10.
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
1. Compare the two ways of shrinking what is possible. Which one does not leave the middle out?
2. If the middle stays inside what is possible, does the interval always shrink?
3. Try a searched number greater than all.
4. With 11, the interval stays at 8 and 9 forever and the program never ends. Close with the variant.
:::

::: variante
Fix the line that does not move.
:::

::: explicacion
With a searched number to the right of the middle, the program does `bajo <- medio`. When `bajo` and `alto` end up together, the middle is `bajo` and the interval no longer changes: the loop is infinite and the engine cuts it by limit.
:::

---
id: imperativo.cuadriculas.raya-romper
leccion: imperativo.cuadriculas
tipo: romperlo
nivel: brote
obligatorio: true
titulo: A line that gets away
---

::: enunciado
This noughts and crosses program gets the lesson's board right. Find a board it gets wrong.
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
1. Count the ways of winning this program checks. Are there eight?
2. Compare with the figure in the lesson: which line of the board does it not check?
3. Build a board where someone wins only by that line.
4. With X in cells [0, 2], [1, 1] and [2, 0], the program says «Nadie». Close with the variant.
:::

::: variante
Build a board where this program gives the right winner even though the other diagonal is complete. (One that also has a full row of the same player.)
:::

::: docentes
The program is missing the diagonal from the top right corner to the bottom left. Any board won only by that diagonal breaks it.
:::

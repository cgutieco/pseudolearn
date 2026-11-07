---
id: imperativo.caminos.bisiesto-ordenar
leccion: imperativo.caminos
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordering the leap year
---

::: enunciado
The lines of a program that decides whether a year is a leap year are mixed up. Put them in order so that it works.
:::

```programa rol=referencia
```

```casos
```

::: explicacion
The questions go from the most specific to the most general: 400 first, then 100 and 4 at the end. Each `If` is closed by its own `EndIf`, from the inside out.
:::

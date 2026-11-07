---
id: imperativo.arreglos.calurosos-ordenar
leccion: imperativo.arreglos
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordering the hot days
---

::: enunciado
The lines of a program that shows the days hotter than the average are mixed up. Put them in order so that it works.
:::

```programa rol=referencia
```

```casos
```

::: explicacion
First the array and the accumulator are declared; the first pass reads and adds; then the average is computed; the second pass compares each day. The average cannot go before the first pass.
:::

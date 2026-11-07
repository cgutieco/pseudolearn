---
id: imperativo.mientras.misterio-tabla
leccion: imperativo.mientras
tipo: rastrear
nivel: brote
obligatorio: true
titulo: Trace the mystery
---

::: enunciado
Complete the pass table of the mystery number program: the value of each box at the end of each pass.
:::

```programa rol=objeto id=traza
```

```vueltas marca=7 inicio=4 columnas=n,total
```

::: explicacion
At the end of each pass, `total` is the sum from 1 to `n`: that is the invariant. On pass 4 it reaches 10 and the condition stops holding.
:::

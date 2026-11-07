---
id: imperativo.contado.hay-par
leccion: imperativo.contado
tipo: rastrear
nivel: brote
obligatorio: false
titulo: Is there an even one?
---

::: enunciado
Complete the pass table: the value of each box at the end of each pass.
:::

```programa rol=objeto id=traza
```

```vueltas marca=9 columnas=i,x,hayPar
```

::: explicacion
`hayPar` starts as false and changes the first time an even number appears, on pass 2. After that it never changes again, even though `x` is odd on pass 3.
:::

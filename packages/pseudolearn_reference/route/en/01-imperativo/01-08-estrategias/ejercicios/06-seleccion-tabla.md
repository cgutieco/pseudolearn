---
id: imperativo.estrategias.seleccion-tabla
leccion: imperativo.estrategias
tipo: rastrear
nivel: arbol
obligatorio: false
titulo: Tracing the selection
---

::: enunciado
Complete the table: what each cell of `v` holds at the end of each pass of the outer walk.
:::

```programa rol=objeto id=traza
```

```vueltas marca=17 inicio=7 columnas=v[0],v[1],v[2],v[3]
```

::: explicacion
The first pass brings 1 to the front by swapping it with 4. The second brings 2 to second place. On the third, 3 is already in place and the swap changes nothing.
:::

---
id: imperativo.arreglos.rotar
leccion: imperativo.arreglos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Rotate one place
---

::: enunciado
Read 5 numbers and show them rotated one place to the right: the last becomes the first and the others move one position along. One per line.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. By hand with 1, 2, 3, 4, 5: which position comes out first? And then?
2. Keep the five in an array, as in [the lesson](ruta:imperativo.arreglos).
3. The first one shown is the one in the last cell; then, the others in order.
4. Show `v[4]` and then walk from 0 to 3. Close with the variant.
:::

::: variante
Really rotate the array, moving the values inside it, and then show it from 0 to 4. (You need to keep the last one before moving the others.)
:::

::: explicacion
The shortest solution moves nothing: it only changes the order in which it shows. The variant forces moving the values, from back to front.
:::

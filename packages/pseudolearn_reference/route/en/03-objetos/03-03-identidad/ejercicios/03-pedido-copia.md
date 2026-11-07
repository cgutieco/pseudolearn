---
id: objetos.identidad.pedido-copia
leccion: objetos.identidad
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The order that was copied wrong
---

::: enunciado
The program reads two products for an order and a third one for a similar order. The receipt of the original order should show only its two products, but it also shows the third. Find the error and fix it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. How many orders are there in the program? Count the times `New` appears.
2. Look at the arrows figure in [the lesson](ruta:objetos.identidad).
3. The order already knows how to make a copy with its own list.
4. Build the copy with `pedido.Duplicar()` instead of assigning the order. Close with the variant.
:::

::: variante
What would happen if the copy were built with `copy(pedido)`? Try it and explain the result.
:::

::: docentes
`copia <- pedido` gives the same order another name. The fix uses `Duplicar`, which builds a new list. `copy` is not enough: it shares the list.
:::

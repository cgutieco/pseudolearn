---
id: inicio.nombres.figuritas
leccion: inicio.nombres
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: Swapping stickers
---

::: enunciado
Ana has 12 stickers and Beto has 7. They want to swap their piles: Ana keeps Beto's and Beto keeps Ana's. A classmate's program shows that both end up with 7. Fix it so that it shows `Ana: 7 Beto: 12`.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Draw both boxes and run each line by hand. What value does `ana` have right after the first assignment?
2. When you assign, the old value is lost. Look at the swap figure in [the Specification](especificacion:declaraciones.asignacion).
3. Before overwriting Ana's stickers, keep them in a third box.
4. Declare `guardado` with the value of `ana`, then `ana <- beto;` and `beto <- guardado;`. Close with the variant.
:::

::: variante
Now Carla plays too, with 3 stickers. Make Ana get Beto's, Beto get Carla's and Carla get Ana's. (Answer: `Ana: 7 Beto: 3 Carla: 12`.)
:::

::: docentes
The first assignment overwrites 12 before copying it. The solution uses an extra box. Frequent mistake: swapping the two lines, which leaves both with 12.
:::

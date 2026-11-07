---
id: funcional.tipos-dominio.avanzar
leccion: funcional.tipos-dominio
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Moving forward with its errors
---

::: enunciado
An order starts pending or cancelled: read `pendiente`, or `cancelado` followed by the reason. Then read how many times it has to move forward, with the courier `Sol` and the time 14. Show the final description, or the first reason why it could not move forward, such as «No se puede: está cancelado: lluvia».
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. From which states can it move forward? What happens with the others?
2. It is the `Avanzar` of [the lesson](ruta:funcional.tipos-dominio), repeated several times.
3. Move forward while it has not failed; the first error is kept and it does not move forward any more.
4. A loop that calls `Avanzar` and handles the `Result`; at the end, the description or the reason. Close with the variant.
:::

::: variante
Add `Cancelar(pedido, motivo)`, which only cancels orders that are pending or on their way.
:::

::: docentes
Hidden cases: zero moves, moving forward too many times, moving a cancelled one and a cancelled one without moves.
:::

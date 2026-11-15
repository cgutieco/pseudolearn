---
id: funcional.tipos-dominio.posible-o-no
leccion: funcional.tipos-dominio
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: Does it make sense?
---

::: enunciado
With the model of four loose values (state, courier, time and reason), all these orders can be written. Place each one according to whether it makes sense or is impossible in reality.
:::

```categorias
- Makes sense
- Is impossible
```

```elementos
- Delivered, with a time. | Makes sense
- Cancelled, with a reason. | Makes sense
- Pending, with no other value. | Makes sense
- Delivered, with no time. | Is impossible
- Cancelled, with a courier. | Is impossible
```

::: explicacion
With loose values, the last two can be written even though they make no sense. With a variant, they cannot: `Delivered` requires the time and `Cancelled` has no place for a courier.
:::

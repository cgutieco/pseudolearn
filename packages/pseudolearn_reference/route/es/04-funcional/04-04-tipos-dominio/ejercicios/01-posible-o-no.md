---
id: funcional.tipos-dominio.posible-o-no
leccion: funcional.tipos-dominio
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: ¿Tiene sentido?
---

::: enunciado
Con el modelo de cuatro datos sueltos (estado, repartidor, hora y motivo), todos estos pedidos se pueden escribir. Ubica cada uno según tenga sentido o sea imposible en la realidad.
:::

```categorias
- Tiene sentido
- Es imposible
```

```elementos
- Entregado, con hora. | Tiene sentido
- Cancelado, con motivo. | Tiene sentido
- Pendiente, sin ningún otro dato. | Tiene sentido
- Entregado, sin hora. | Es imposible
- Cancelado, con repartidor. | Es imposible
```

::: explicacion
Con datos sueltos, los dos últimos se pueden escribir aunque no tengan sentido. Con una variante, no: `Entregado` exige la hora y `Cancelado` no tiene lugar para un repartidor.
:::

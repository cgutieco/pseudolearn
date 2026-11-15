---
id: objetos.responsabilidades.colaboracion
leccion: objetos.responsabilidades
tipo: ordenar
nivel: brote
obligatorio: true
titulo: Una venta paso a paso
---

::: enunciado
Estos son los pedidos que se hacen las piezas del kiosco durante una venta, mezclados. Ordénalos.
:::

```pasos
- El principal le pide a la caja que venda tres jugos.
- La caja le pide al inventario que quite tres jugos.
- El inventario comprueba que alcanza y los quita.
- La caja le pide al jugo el importe de tres.
- La caja suma el importe a su total.
- La caja le pide al ticket que anote la línea.
```

::: explicacion
La caja coordina: primero se asegura de que haya stock, después calcula y suma, y al final deja constancia en el ticket. Si el inventario no alcanzara, la caja no seguiría con el resto.
:::

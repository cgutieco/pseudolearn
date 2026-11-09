---
id: concurrente.canales.pedidos-contar
leccion: concurrente.canales
tipo: resolver
nivel: brote
obligatorio: true
titulo: Count the orders
---

::: enunciado
Read how many orders the kitchen prepares. The kitchen numbers them from 1 and passes them to the window, which holds 2; the window shows «Entrego el pedido n» for each one and, at the end, «Entregados: n».
:::

::: restriccion
The kitchen is a task that sends the orders through a channel created with `Channel(2)` and closes it when it finishes; the window receives until the channel is closed.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Cocinar | 2 | The subprogram Cocinar, which receives the number of orders and the channel, is missing.
```

::: pistas
1. Who produces and who consumes?
2. It is the window program of the lesson, with the number of orders read at the start.
3. The kitchen sends from 1 to the number read and closes the channel; the window repeats `Receive` until `None` arrives.
4. The count is declared inside the scope, before the loop that receives. Close with the variant.
:::

::: variante
Make the window also show the number of the last order handed over.
:::

::: explicacion
With 0 orders the kitchen closes without sending anything and the first `Receive` gives `None`. With 7 orders the channel fills up several times and the kitchen waits: the output is the same.
:::

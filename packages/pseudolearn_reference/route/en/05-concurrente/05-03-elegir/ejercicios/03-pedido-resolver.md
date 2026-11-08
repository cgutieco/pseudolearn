---
id: concurrente.elegir.pedido-resolver
leccion: concurrente.elegir
tipo: resolver
nivel: brote
obligatorio: true
titulo: The fruit order
---

::: enunciado
Read the stock of North, of South and of West. If any of them has 0, show «Pedido suspendido: » and the reason, for example «Norte no tiene stock»; otherwise, show «Pedido confirmado: » and the sum of the three.
:::

::: restriccion
Each supplier is queried in its own task, which gives back a `Result`: `Success` with the stock or `Failure` with the reason. The first error suspends the order.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Consultar | 2 | The subprogram Consultar, which receives the name and the stock, is missing.
```

::: pistas
1. What does each query have to give back when there is stock, and what when there is not?
2. It is like the lesson program: three tasks in a `Tasks fallo` scope, and the one that gives back `Failure` cuts the others.
3. After `EndTasks`, `fallo` is `None` if all of them gave `Success`, or `Some` with a report whose `First` is the reason.
4. With a `Switch` on `fallo`, show the suspension with the reason or the confirmation with the sum. Close with the variant.
:::

::: variante
Also show how many suppliers had stock when the order is confirmed.
:::

::: docentes
The cases have at most one supplier without stock, so the reason does not depend on the turns of the schedule. When a supplier fails, the scope cancels the queries that are still alive; the exercise does not ask how many.
:::

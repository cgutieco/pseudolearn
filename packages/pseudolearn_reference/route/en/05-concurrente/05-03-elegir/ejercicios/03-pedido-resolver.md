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
Each supplier is checked in its own task, which gives back the reason if it has no stock or an empty text if it has.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | Revisar | 2 | The subprogram Revisar, which receives the name and the stock, is missing.
```

::: pistas
1. What does each check have to say when there is stock, and what when there is not?
2. It is like the tray of lesson 5.1: three tasks, and the algorithm awaits the three.
3. If each task gives back the reason or an empty text, joining the three texts gives the reason of the problem, or an empty text if there was none.
4. With an `If` on that text, show the confirmation with the sum or the suspension with the reason. Close with the variant.
:::

::: variante
Also show how many suppliers had stock when the order is confirmed.
:::

::: docentes
The cases have at most one supplier without stock. The tasks of this exercise do not end with `Failure`: in the app, the checker moves step by step and, with the current engine, cancelling sister tasks that are still alive stops the program. That is why cancellation is practised in the two prediction exercises and in the lesson program.
:::

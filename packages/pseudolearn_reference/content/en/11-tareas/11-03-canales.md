---
id: tareas.canales
numero: "11.3"
tipo: concepto
titulo: "Channels and `Select`"
anclas: [LANG.TASK.CHANNEL#R1, LANG.TASK.CHANNEL#R2, LANG.TASK.CHANNEL#R3, LANG.TASK.CHANNEL#R4, LANG.TASK.CHANNEL#R5, LANG.TASK.CHANNEL#R6, LANG.TASK.CHANNEL#R7, LANG.TASK.CHANNEL#R8]
diagnosticos: [channelElementNotTransferable, channelCapacityInvalid, channelCapacityExceeded, channelOperationWithoutAwait, pureFunctionTaskOperation, selectNeedsTwoBranches]
terminos: [channel, capacity, producer, consumer]
---

::: frase
A channel is a fixed-capacity queue through which some tasks send values and others receive them, in order and without sharing memory.
:::

## How it works {#funciona}

`Channel<T>` is the type and `Channel(n)` creates one with capacity `n`. Three operations:

| Operation | What it does |
|---|---|
| `Await c.send(v)` | queues `v`; if full, it waits. Returns `False` if the channel is closed |
| `Await c.receive()` | takes the first one as `Something(v)`; if empty, it waits. Closed and empty gives `Nothing` |
| `c.close()` | closes the channel without losing what is queued |

```figura id=canal-cola
pie: A channel of capacity 2. The producer waits when it is full; the consumer, when it is empty. Values come out in the order they went in.
```

```programa id=tuberia titulo="A producer and a consumer"
```

## Select {#elegir}

`Select` waits on **several** channels at once and serves the first one that has something. If several are ready, the first written branch wins: the result is always the same.

```programa id=elegir titulo="Serving whichever arrives first"
```

::: limite
- Capacity is at least 1; a smaller constant is `channelCapacityInvalid`.
- Only transferable values travel: no objects or records containing objects.
- `Select` needs at least two branches.
:::

::: resumen
- A channel is a bounded queue between tasks.
- `send` and `receive` are used with `Await`; `close`, without it.
- `Select` serves the first ready channel, ties broken by written order.
:::

::: vease
- [Task scopes](#tareas.ambitos)
- [Optional and Result](#tipos.opcional-resultado)
:::

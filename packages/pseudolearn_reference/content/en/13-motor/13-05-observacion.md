---
id: motor.observacion
numero: "13.5"
tipo: motor
titulo: Observing execution
anclas: [ENG.TRACE.STEP#R1, ENG.TRACE.STEP#R2, ENG.TRACE.STEP#R3, ENG.TRACE.STEP#R4, ENG.STATE.INCREMENTAL#R1, ENG.STATE.INCREMENTAL#R2, ENG.STATE.INCREMENTAL#R3]
terminos: [trace, step, event]
---

::: frase
Execution can be watched step by step: the engine emits a **trace** of events, and every event carries what changed in memory.
:::

## How it works {#funciona}

A **step** is the interval between two consecutive trace events: entering a statement, taking a decision, writing, calling, returning. Advancing one step delivers exactly the next event; there is nothing smaller.

The debugger's moves are built on events:

| Move | Until |
|---|---|
| next statement | the next statement of the same frame or an outer one |
| step into | the next statement, even inside a call |
| step out | the return that closes the current frame |

```figura id=traza-pasos
pie: Every trace event is a step. The memory state at any event is rebuilt by adding up the changes from the start.
```

```programa id=observar titulo="A program to watch"
```

```traza programa=observar
```

Every event can carry the **state change**: written variables, created objects, frames pushed or popped. Adding up the changes from the start gives the full state at any event, and asking about a past event again always gives the same answer. Events are delivered in batches of whatever size the host prefers, without losses or duplicates.

::: resumen
- The trace is the list of events; a step is an event.
- Next, step into and step out are defined on events.
- State changes rebuild memory at any point.
:::

::: vease
- [The engine's layers](#motor.capas)
- [Engine limits](#motor.limites)
:::

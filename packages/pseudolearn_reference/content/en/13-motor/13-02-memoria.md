---
id: motor.memoria
numero: "13.2"
tipo: motor
titulo: Memory and the collector
anclas: [MEM.MANAGED.UNOBSERVABLE#R1, MEM.MANAGED.UNOBSERVABLE#R2, MEM.MANAGED.UNOBSERVABLE#R3, ENG.TASK.MEMORY#R1, ENG.TASK.MEMORY#R2, ENG.TASK.MEMORY#R3]
terminos: [heap, collector, reachability]
---

::: frase
Objects, arrays and texts created while running live on the **heap**, and the collector recovers those nobody can reach without the program ever noticing.
:::

## How it works {#funciona}

A value is **alive** if it can be reached from a variable of some active frame. When it no longer can, its memory may be recovered. The program **cannot observe** when or whether that happens: there are no finalizers, no weak references and no free-memory queries.

```figura id=alcanzables
pie: From the frames' variables two objects can be reached; the third has no path left and the collector may reuse its memory.
```

The proof that it is unobservable is strong: running a program collecting on **every** value creation, or never collecting, gives exactly the same output, termination and trace.

A value reachable only from variables whose block has ended —a loop body, a branch— stops counting towards the [cell limit](#motor.limites) as soon as that block ends.

```programa id=basura titulo="Objects created and forgotten"
```

Every round creates a box that stops being reachable when the round ends. Suspended tasks are roots too: what their frames hold, their pending results and the channels' messages stay alive as long as needed.

::: resumen
- Values created while running live on the heap.
- What cannot be reached is recovered, with no observable effect.
- Collecting always or never gives the same run.
:::

::: vease
- [Copies, references and identity](#objetos.copia)
- [Engine limits](#motor.limites)
:::

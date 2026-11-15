---
id: vision.analizar-ejecutar
numero: "1.3"
tipo: concepto
titulo: Analysing, running and observing
anclas: [LANG.TYPES.CHECKING-LEVELS#R1, ENG.TRACE.EVENTS#R1, ENG.STATE.SNAPSHOT#R1]
terminos: [analysis, execution, observation]
---

::: frase
The engine does three different jobs with a program: analysing it without running it, running it, and letting you observe what happens inside.
:::

## How it works {#funciona}

**Analysing** means reading the program without running it. The editor does it every time you type: it colours the words, points out errors and offers help. Analysing never changes anything or writes to the output.

**Running** means really going through the instructions. The result is the output, the way the program ended and, if something failed, the runtime diagnostic.

**Observing** means running while leaving a trail. The engine records every important event (entering a statement, taking a decision, writing something) and keeps the state of memory. With that trail the editor draws the run step by step.

```figura id=tres-trabajos
pie: Three jobs with the same program. Each produces something different; only running and observing go through the instructions.
```

This program analyses without errors, runs and leaves a trace with one decision:

```programa id=par titulo="Even or odd?"
```

::: por-dentro
This is the trace the engine produced when observing `Paridad`. Each line is an event with the program line where it happened:

```traza programa=par
```
:::

::: resumen
- Analysing: reading without running; produces colours, errors and help.
- Running: going through the instructions; produces output and termination.
- Observing: running while leaving a trace and memory states.
:::

::: vease
- [The journey of a program](#vision.viaje)
- [Observation: trace, checkpoints and timeline](#motor.observacion)
:::

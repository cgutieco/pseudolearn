---
id: motor.efectos
numero: "13.4"
tipo: motor
titulo: Effect order and the tape
anclas: [ENG.EXEC.EFFECT-ORDER#R1, ENG.EXEC.EFFECT-ORDER#R2, ENG.EXEC.EFFECT-ORDER#R3, ENG.EXEC.EFFECT-ORDER#R4, ENG.EXEC.EFFECT-ORDER#R5, ENG.EXEC.EFFECT-COMMIT#R1, ENG.EXEC.EFFECT-COMMIT#R2, ENG.EXEC.EFFECT-COMMIT#R3, ENG.EXEC.EFFECT-COMMIT#R4, ENG.EXEC.EFFECT-COMMIT#R5, ENG.EFFECT.TAPE#R1, ENG.EFFECT.TAPE#R2, ENG.EFFECT.TAPE#R3, ENG.EFFECT.TAPE#R4, ENG.EFFECT.TAPE#R5, ENG.EFFECT.TAPE#R6]
diagnosticos: [divisionByZero]
terminos: [effect, tape, replay]
---

::: frase
Everything a program does towards the outside happens in program order and is noted on a **tape**, with which the run can be replayed without touching the world again.
:::

## How it works {#funciona}

The **observable effects** are output, input, capability operations, the failure and the termination. They happen exactly in the order the language's rules prescribe. Effect-free computations may be reordered internally, but never in a noticeable way.

A statement that fails **produces no partial effects**. `Write` computes all its expressions before writing anything:

```programa id=sin-parcial titulo="A Write that never gets to write"
```

```figura id=cinta-efectos
pie: Every effect is noted on the tape with its number, its task and its result. Replaying the tape gives the same run without asking the host.
```

Every effect goes through two phases: **requested**, when its arguments are computed and it gets a sequence number, and **resolved**, when the host answers. The result is *committed*, *failed* or *uncertain*; reads are never uncertain.

The **tape** keeps the run's identity —code, profile, seed, limits— and one entry per effect, chained with a cryptographic digest. On replay everything is checked to match; secret data is stored redacted.

::: resumen
- Effects happen in program order.
- A failing statement leaves no half-done effects.
- Every effect is requested, resolved and noted on the tape.
- The tape allows replaying the run exactly.
:::

::: vease
- [Effects and capabilities](#tareas.efectos)
- [Determinism](#vision.determinismo)
:::

---
id: tareas.suspendible
numero: "11.1"
tipo: concepto
titulo: "Suspendible units and `Await`"
anclas: [LANG.TASK.SUSPENSION#R1, LANG.TASK.SUSPENSION#R2, LANG.TASK.SUSPENSION#R3, LANG.TASK.SUSPENSION#R4, LANG.TASK.SUSPENSION#R5, LANG.TASK.SUSPENSION#R6, LANG.TASK.SUSPENSION#R7, LANG.TASK.SUSPENSION#R8]
diagnosticos: [suspendibleCallWithoutAwait, awaitOutsideSuspendible, awaitOperandInvalid, suspendibleModifierNotAllowed, suspendibleAsValue, awaitInsideDefer]
terminos: [suspension, wait]
---

::: frase
A `Suspendible` unit can pause half-way while it waits for something; `Await` marks in the code every point where that pause may happen.
:::

## How it works {#funciona}

`Subroutine Suspendible` declares a subprogram that **can suspend**: stop running for a moment while it waits for another task, a channel or a host effect. The main algorithm is suspendible without being marked.

Every call to a suspendible unit must be preceded by `Await`. That way, reading the code, you see exactly where the program can pause: nowhere else.

```figura id=aguardar-pausa
pie: The task runs up to `Await`, pauses while another one works and continues with the result. Outside the marked points it is never interrupted.
```

```programa id=sin-aguardar titulo="A suspendible call without Await"
```

`Await` can go in any position of an expression. What was computed before the wait is kept.

::: limite
- `Suspendible` is not allowed on `Function`, methods, constructors or function literals.
- A suspendible unit is not a value: it cannot be stored or passed as a function.
- `Await` only accepts a call to a suspendible unit or a capability operation; it is forbidden inside `Defer`.
:::

::: resumen
- `Suspendible` declares a unit that can pause.
- Every pause point is marked with `Await`.
- Between two `Await`s, a task is not interrupted.
:::

::: vease
- [Task scopes](#tareas.ambitos)
- [Channels](#tareas.canales)
- [The engine's schedule](#motor.agenda)
:::

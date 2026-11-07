---
id: motor.agenda
numero: "13.3"
tipo: motor
titulo: The task schedule
anclas: [ENG.TASK.AGENDA#R1, ENG.TASK.AGENDA#R2, ENG.TASK.AGENDA#R3, ENG.TASK.AGENDA#R4, ENG.TASK.AGENDA#R5, ENG.TASK.AGENDA#R6, ENG.TASK.AGENDA#R7]
diagnosticos: [taskDeadlock]
terminos: [schedule, ready queue, deadlock]
---

::: frase
Tasks do not really run at the same time: a deterministic **schedule** decides which one advances, and that is why every run always follows the same order.
:::

## How it works {#funciona}

Only one task runs at any moment. The others are **ready** (in a queue), **suspended** (waiting for something) or **finished**.

- The root task has identity 0; every `Spawn` assigns the next one: 1, 2, 3…
- The ready queue is FIFO: new tasks, woken tasks and tasks that yield go to the back.
- When the current task suspends or ends, the head of the queue resumes. `Spawn` does not displace the parent.
- So that none hogs the turn, a task that runs 1024 statements in a row inside a suspendible loop yields its place.

```figura id=agenda-cola
pie: The schedule with the running task, the ready queue and the suspended ones. When the current one suspends, the head of the queue comes in.
```

```programa id=turnos titulo="The order of turns"
```

The parent writes first because `Spawn` does not stop it. At `EndTasks` it suspends and A, the head of the queue, comes in. Since the channel has room, `send` does not suspend A, which finishes before B comes in.

## Deadlock {#bloqueo}

If no task is ready and no pending effect can wake any of them, the run ends with `taskDeadlock`:

```programa id=bloqueo titulo="Waiting for something that never comes"
```

::: resumen
- A single task advances; the others wait in a FIFO queue.
- Task identities grow from 0 and are never reused.
- With no ready tasks and no pending effects, the run ends with `taskDeadlock`.
:::

::: vease
- [Task scopes](#tareas.ambitos)
- [Channels](#tareas.canales)
- [Determinism](#vision.determinismo)
:::

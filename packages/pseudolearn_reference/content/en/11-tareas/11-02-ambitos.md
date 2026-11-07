---
id: tareas.ambitos
numero: "11.2"
tipo: construccion
titulo: "Task scopes with `Tasks` and `Spawn`"
anclas: [LANG.TASK.SCOPE#R1, LANG.TASK.SCOPE#R2, LANG.TASK.SCOPE#R3, LANG.TASK.SCOPE#R4, LANG.TASK.SCOPE#R5, LANG.TASK.SCOPE#R6, LANG.TASK.SCOPE#R7, LANG.TASK.SCOPE#R8, LANG.TASK.SCOPE#R9, LANG.TASK.SCOPE#R10, LANG.TASK.SCOPE#R11, LANG.TASK.SCOPE#R12, LANG.TASK.SCOPE#R13, LANG.TASK.SCOPE#R14, LANG.TASK.SCOPE#R15, LANG.TASK.SCOPE#R16]
fichas: [help.task-scope]
diagnosticos: [spawnOutsideTaskScope, spawnTargetNotSuspendible, taskArgumentNotTransferable, taskByReferenceArgument, taskHandleEscape, taskScopeInsideDefer, taskScopeErrorTypeMismatch, taskErrorNotTransferable, taskScopeFailureUnbound, taskScopeFailureUnused]
terminos: [task, task scope, handle]
---

::: frase
`Tasks` opens a space where tasks that progress together are spawned; `EndTasks` waits for **all** of them to finish, so none is left loose.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=taskScope
```

::: partes
- `Tasks` opens the scope. «failure» is an optional name that, after `EndTasks`, tells whether any task failed.
- `Spawn` creates a child task that runs a `Suspendible` unit. It is only written directly inside the scope.
- A **handle** `Task<T>` keeps the spawned task; its only use is `Await handle` to get the result.
- `EndTasks` joins all children: it waits for those still alive.
:::

## How it works {#funciona}

`Spawn` does not stop the parent: it creates the child and the parent goes on with the next statement. The children run when the parent pauses, at the latest at `EndTasks`.

```programa id=lanzar-dos titulo="Two tasks and their join"
```

```figura id=ambito-tareas
pie: The parent spawns two children and carries on. At `EndTasks` it waits for both to finish; afterwards none is alive.
```

A handle gets a child's value back:

```programa id=asas titulo="Waiting for results"
```

## Failures {#fallos}

If the children return `Result<T, E>`, the first `Error` to finish **cancels** the others and jumps to `EndTasks`. The scope's failure name is `Nothing` if all went well, or `Something` with the first error, the associated errors and how many children were cancelled.

```programa id=fallo-tareas titulo="The first error rules"
```

::: limite
- `Spawn` arguments must be **transferable** and cannot go by reference: tasks share no mutable memory.
- A handle cannot leave the scope: assigning, passing or returning it is `taskHandleEscape`.
- A trap in any task ends **the whole** run, without cleanups.
:::

::: errores
```programa id=lanzar-fuera titulo="Spawn outside Tasks"
```
:::

::: por-dentro
`Spawn` reserves a new task in the engine's schedule with its own frame; `EndTasks` is a join instruction that suspends the parent while any child is still alive.

```ri programa=lanzar-dos
```
:::

::: resumen
- `Tasks` opens a scope and `EndTasks` waits for all its children.
- `Spawn` creates a child without stopping the parent.
- A handle is only used with `Await`.
- The first error cancels the siblings and is kept in the failure name.
:::

::: vease
- [Suspendible units](#tareas.suspendible)
- [Channels](#tareas.canales)
- [Immutable and transferable](#tipos.inmutable)
:::

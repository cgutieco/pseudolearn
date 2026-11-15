---
id: declaraciones.sin-valor
numero: "5.5"
tipo: concepto
titulo: Variables without a value
anclas: [LANG.DECL.UNINITIALIZED#R1, LANG.DECL.UNINITIALIZED#R2, LANG.DECL.UNINITIALIZED#R3, LANG.DECL.UNINITIALIZED#R4, LANG.DECL.UNINITIALIZED#R5, LANG.DECL.UNINITIALIZED#R6]
diagnosticos: [variableUsedUninitialized, uninitializedVariableRead, bindingOutsideScope, bindingReadsOwnInitializer]
terminos: [initialization, execution path]
---

::: frase
Before running, the engine walks every possible path of the program and rejects reading a variable that some path has not given a value to.
:::

## How it works {#funciona}

A variable declared without an initial value is empty. It is not 0 or anything similar. Reading it at a point that some path reaches without having given it a value is the error `variableUsedUninitialized`, and it is detected **before running**.

```programa id=sin-rama titulo="A branch that gives no value"
```

It does not matter that `puntos` is 40: the engine does not run the program to decide, it looks at the paths. There is a path —the one where the condition is false— that reaches `Write` with `premio` empty.

```figura id=caminos-valor
pie: Both paths leaving the `If` reach `Write`. Along one of them `premio` is still empty.
paso: Before the `If`, `premio` is empty.
paso: Along the true branch, `premio` receives 10.
paso: Along the false branch there is no assignment: `premio` is still empty.
paso: The paths join. Since one arrives without a value, reading `premio` is an error.
```

It is enough to give a value on **every** path:

```programa id=con-rama titulo="Both branches give a value"
```

## The causes {#causas}

The error message says **why** the value is missing:

| Cause | Situation |
|---|---|
| no path assigns | the variable never received a value before |
| condition without `Else` | only the true branch assigns |
| branch without assignment | some branch of `If`, `Switch` or `Select` does not assign |
| the loop may not run | only the body of `While`, `For` or `For Each` assigns |
| `Switch` without `Otherwise` | a value of the selector enters no branch |

```programa id=bucle-sin-valor titulo="A loop that might not run"
```

`Repeat` is different: its body runs at least once, so what it assigns counts after the loop. And `Return` or `Exit` cut their path: that path no longer requires anything.

::: limite
The fields of a local record are tracked one by one. Array cells and object attributes are not tracked: reading an empty one is discovered when running, with the trap `uninitializedVariableRead`.
:::

::: resumen
- A variable without an initial value starts empty.
- Reading it where some path leaves it empty is an error before running.
- The message explains the cause: branch, loop or incomplete `Switch`.
- `Repeat` always runs its body once.
:::

::: vease
- [Declaring variables with Define](#declaraciones.definir)
- [The If decision](#control.si)
- [While](#control.mientras)
:::

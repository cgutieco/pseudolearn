---
id: subprogramas.llamada
numero: "7.4"
tipo: concepto
titulo: Calls
anclas: [LANG.SUBPROGRAM.CALL#R1]
fichas: [help.subprogram-call]
diagnosticos: [argumentCountMismatch, discardedReturnValue, callAsExpressionWithoutReturnType]
terminos: [call, frame]
---

::: frase
Calling a subprogram means pausing what you are doing, running the subprogram with its arguments and coming back exactly to where you paused.
:::

## How it works {#funciona}

A call writes the name and, inside required parentheses, the arguments. The arguments are computed **from left to right and only once**, and must match the parameters in number and type.

Every call creates a **frame**: a space of its own for its parameters and local variables. When it ends, the frame disappears and control goes back to the caller.

```figura id=llamada-marcos
pie: Frames are stacked when calling and removed when returning. Only the top one is running.
paso: `Principal` is running with its frame.
paso: `Doble(21)` pushes a new frame with `n` = 21. `Principal` waits.
paso: `Doble` returns 42: its frame disappears and `Principal` carries on with the value.
```

A subprogram that returns a value is used **as an expression**, where a value is needed. One that returns nothing is used **as a statement**. Mixing them up has different consequences:

| Situation | Result |
|---|---|
| using as a value something that returns nothing | error |
| calling as a statement something that returns a value | warning: the value is lost |

```programa id=llamadas-mal titulo="A discarded value and one argument too many"
```

::: resumen
- Parentheses are required; arguments are computed from left to right.
- Number and types must match the signature.
- Every call has its own frame, which disappears on return.
- Discarding a returned value is a warning.
:::

::: vease
- [Declaring subprograms](#subprogramas.declaracion)
- [Return](#subprogramas.retornar)
- [Recursion](#subprogramas.recursion)
:::

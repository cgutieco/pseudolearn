---
id: control.diferir
numero: "6.8"
tipo: construccion
titulo: "Cleanups with `Defer`"
anclas: [LANG.CONTROL.CLEANUP#R1, LANG.CONTROL.CLEANUP#R2]
fichas: [construction.defer]
diagnosticos: [controlTransferInsideCleanup]
terminos: [cleanup, scope]
---

::: frase
`Defer` notes down something to do when leaving the current block, whatever happens: closing a file, switching off a light, leaving things as they were.
:::

## How to write it {#escribe}

```forma
```

::: partes
- `Defer` opens the cleanup.
- «statements» is what will be done on leaving. It does not run now.
- `EndDefer` closes the cleanup.
:::

## How it works {#funciona}

When execution reaches `Defer`, the body **does not run**: it is pushed onto a stack. When leaving the block that holds the `Defer` —through the end, `Exit`, `Return` or a propagated error— the noted cleanups run, **from the last to the first**.

```programa id=puerta-luz titulo="The last thing opened is the first one closed"
```

```figura id=diferir-pila
pie: Cleanups are stacked when reached and run in reverse when leaving the block.
paso: The first `Defer` is reached: "cierro la puerta" goes onto the stack.
paso: The second one is reached: "apago la luz" sits on top.
paso: When the block ends the top one comes off first, "apago la luz", and then "cierro la puerta".
```

Only what is **reached** counts: a `Defer` in a branch not taken notes nothing. Inside a loop, every round notes its own cleanups and runs them when that round ends:

```programa id=vueltas-diferir titulo="Cleanups per round"
```

::: limite
- Inside a cleanup, `Return`, `Exit`, `Propagate` and another `Defer` are not allowed.
- If the program fails with a trap, it ends at once **without** running the pending cleanups.
- `Return` computes its result before the cleanups: a cleanup cannot hide the value or the error being returned.
:::

::: errores
```programa id=diferir-salir titulo="Exit inside a cleanup"
```
:::

::: por-dentro
The engine copies the body of every cleanup into every exit of the block, in reverse order. That is why the intermediate representation of `puerta-luz` has the two final writes after "leo un rato".

```ri programa=puerta-luz
```
:::

::: nota
A stack of plates helps: the last one put down is the first one taken off. Predict the output of `vueltas-diferir` before running it: round 2 cleans up even though it leaves with `Exit`.
:::

::: resumen
- `Defer` notes a cleanup for when the block is left.
- Cleanups run in the reverse of the order they were reached.
- They run when leaving through the end, `Exit`, `Return` or a propagated error.
- A trap ends the program without running them.
:::

::: vease
- [Leaving a loop](#control.salir)
- [Files](#biblioteca.archivos)
- [Return](#subprogramas.retornar)
:::

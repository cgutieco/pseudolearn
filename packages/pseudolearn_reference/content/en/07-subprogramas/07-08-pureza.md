---
id: subprogramas.pureza
numero: "7.8"
tipo: concepto
titulo: "Purity: `Function` versus `Subroutine`"
anclas: [LANG.CAPABILITY.PURITY#R1, LANG.CAPABILITY.PURITY#R2, LANG.CAPABILITY.PURITY#R3, LANG.CAPABILITY.PURITY#R4, LANG.CAPABILITY.PURITY#R5, LANG.CAPABILITY.PURITY#R6]
diagnosticos: [pureFunctionSideEffect, pureFunctionTransitiveSideEffect, pureFunctionInterfaceImpurity, awaitOutsideSuspendible]
terminos: [pure function, effect]
---

::: frase
A `Function` only computes: it does not write, read, or touch files or the network. Whatever has effects is declared with `Subroutine`.
:::

## How it works {#funciona}

An **effect** is anything the program does towards the outside: writing to the console, reading from the keyboard, opening a file, asking for the time. PseudoLearn separates two kinds of subprograms:

| Unit | Can it have effects? |
|---|---|
| `Subroutine` and the main algorithm | yes |
| `Function` | no: it is **pure** |

A pure function always returns the same result for the same arguments. That makes it easy to test and to understand.

```programa id=funcion-impura titulo="A function that writes"
```

The check is **transitive**: a function cannot call a subprogram with effects either, nor one that calls another that has them.

```figura id=pureza-grafo
pie: The effect of `Avisar` climbs up the calls to `Triple`, which is a `Function` and gets rejected.
```

```programa id=funcion-transitiva titulo="An effect hidden in a call"
```

The diagnostic points, in order, to every unit in the chain from the first call with an effect to the one that produces it.

::: limite
- Where a pure function is expected, a subprogram or closure with effects cannot be passed.
- If an interface declares a method as `Function`, all its implementations must be pure.
- A `Function` cannot contain `Await`.
:::

::: resumen
- `Function` is pure: no input, output or capabilities.
- Purity is checked through every call.
- Effects go in `Subroutine` or in the algorithm.
:::

::: vease
- [Declaring subprograms](#subprogramas.declaracion)
- [Effects and capabilities](#tareas.efectos)
- [Interfaces](#objetos.interfaces)
:::

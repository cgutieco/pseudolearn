---
id: subprogramas.recursion
numero: "7.7"
tipo: concepto
titulo: Recursion
anclas: [LANG.SUBPROGRAM.RECURSION#R1]
diagnosticos: [recursionDepthExceeded]
terminos: [recursion, base case]
---

::: frase
A recursive subprogram calls itself with a smaller problem, until it reaches a case so simple that it is solved without calling itself.
:::

## How it works {#funciona}

Every recursion has two parts:

- the **base case**, which answers without calling itself;
- the **recursive case**, which calls itself with a smaller problem and uses its answer.

```programa id=factorial titulo="The factorial"
```

Every call has **its own frame**, with its own `n`. Calls pile up until the base case and are then resolved from the top down.

```figura id=recursion-pila
pie: `Factorial(4)` stacks four frames, each with its own `n`. The top one resolves first and hands its value to the one below.
paso: `Factorial(4)` is called, and it needs `Factorial(3)`.
paso: Frames pile up until `Factorial(1)`, the base case.
paso: The base case returns 1 and its frame disappears.
paso: Every frame multiplies and returns: 2, 6 and finally 24.
```

Nothing needs to be declared in advance, and two subprograms can call each other:

```programa id=par-impar titulo="Mutual recursion"
```

::: limite
A recursion without a base case does not hang or break anything: the engine stops it with `recursionDepthExceeded` when it reaches its [depth limit](#motor.limites). The app allows at least 1000 frames.
:::

::: errores
```programa id=sin-caso-base titulo="No base case"
```
:::

::: resumen
- A recursive subprogram calls itself with a smaller problem.
- It needs a base case that answers without calling itself.
- Every call has its own frame.
- Without a base case, the engine stops it when depth runs out.
:::

::: vease
- [Calls](#subprogramas.llamada)
- [Engine limits](#motor.limites)
:::

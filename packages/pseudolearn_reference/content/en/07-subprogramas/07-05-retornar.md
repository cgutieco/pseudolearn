---
id: subprogramas.retornar
numero: "7.5"
tipo: construccion
titulo: "Returning a value with `Return`"
anclas: [LANG.SUBPROGRAM.RETURN#R1]
fichas: [help.return]
diagnosticos: [subroutineEndedWithoutReturn, subroutineWithoutReturn, returnValueInReturnVariableFunction, returnOutsideSubroutine]
terminos: [return]
---

::: frase
`Return` ends the subprogram on the spot and, if it has a return type, hands the value to the caller.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=returnStatement
```

::: partes
- `Return` ends the call.
- «expression» is required if the subprogram declares `As` type, and forbidden otherwise.
- In a `Function` with a result variable, `Return` goes **without** an expression: it returns the variable.
:::

## How it works {#funciona}

`Return` cuts everything: it leaves open loops and blocks and abandons the whole call. Whatever comes after does not run. That is why it is useful for leaving as soon as the answer is known:

```programa id=primer-negativo titulo="Leaving as soon as you know"
```

```figura id=retornar-salidas
pie: Three possible exits. With 4, -2 and -7 the second one is taken, and the third is never reached.
```

Every path of a typed subprogram must end in a `Return`. If the engine finds none at all, it is an error before running. If there is one, but a particular path reaches the end without going through it, the failure is discovered **when running** that path.

::: errores
```programa id=signo-incompleto titulo="A path without Return"
```

The first call works; the second reaches `EndSubroutine` with no value to return.
:::

::: por-dentro
Every `Return` is a `return` instruction that ends the block. A path without `Return` ends in a trap instruction with the position of the closing word.

```ri programa=signo-incompleto
```
:::

::: resumen
- `Return` ends the call on the spot, also from inside loops.
- It takes an expression if and only if the subprogram has a return type.
- A path that reaches the end without returning fails when running.
:::

::: vease
- [Declaring subprograms](#subprogramas.declaracion)
- [Leaving a loop](#control.salir)
- [Defer](#control.diferir)
:::

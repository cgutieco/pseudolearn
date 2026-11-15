---
id: declaraciones.constante
numero: "5.2"
tipo: construccion
titulo: "Fixed values with `Constant`"
anclas: [LANG.DECL.CONSTANT#R1, LANG.DECL.CONSTANT#R2, LANG.DECL.CONSTANT#R3, LANG.DECL.CONSTANT#R4]
fichas: [help.constant]
diagnosticos: [constantReassigned, constantNotEvaluable, constantDivisionByZero, constantArithmeticOverflow, circularConstantDefinition, constantBudgetExceeded, expectedConstantInitializer, expectedConstantName]
terminos: [constant]
---

::: frase
A `Constant` names a value that never changes, and the engine computes it before running.
:::

## How to write it {#escribe}

```forma
```

::: partes
- `Constant` opens the declaration. It can go outside every algorithm, in the module, or inside a body.
- «NAME» is an identifier. Writing it in upper case is a habit, not a rule.
- «type» is `Integer`, `Real`, `Boolean`, `Character`, `String` or an enumeration.
- `<-` and the «value» are required.
:::

## How it works {#funciona}

The engine computes the value of every constant **while analysing the program**. Using it is the same as writing its value: it takes no box in memory and cannot be changed.

```programa id=factura titulo="Constants of an invoice"
```

```figura id=constante-sustituye
pie: The engine replaces each constant with its value before running. Only variables remain in memory.
paso: The program as written.
paso: During analysis, `SEMANA` is computed once: `7 * 24` = 168.
paso: Each use of the constant becomes its value. The variable `base` does take memory.
```

The value is computed with a subset of expressions: literals, other constants, enumeration members, parentheses, signs, `Not`, `+ - * / div mod`, comparisons, `And`, `Or` and concatenation. Variables, function calls and power are not allowed.

::: limite
- Integer computation is checked in 64 bits: overflowing is `constantArithmeticOverflow` and dividing by zero is `constantDivisionByZero`, both before running.
- The computation has a budget of 10000 steps and of 65536 bytes per text. A text of exactly 65536 bytes fits.
- A constant that depends on itself, directly or indirectly, is `circularConstantDefinition`.
:::

::: errores
A constant cannot be assigned:

```programa id=cambiar-constante titulo="Trying to change a constant"
```

And its value must be computable without running anything:

```programa id=constante-potencia titulo="A power in a constant"
```
:::

::: por-dentro
In the intermediate representation there is no trace of `SEMANA` or `IVA`: 168 and 0.21 appear directly as instruction constants instead.

```ri programa=factura
```
:::

::: resumen
- `Constant` names a fixed value with a required initializer.
- It is computed during analysis, with a subset of operations.
- It takes no memory and cannot be assigned.
- It can be declared in the module or inside a body.
:::

::: vease
- [Declaring variables with Define](#declaraciones.definir)
- [Modules](#programas.modulos)
- [Enumerations](#tipos.enumerados)
:::

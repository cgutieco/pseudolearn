---
id: expresiones.aritmeticos
numero: "4.1"
tipo: concepto
titulo: Arithmetic operators
anclas: [LANG.OPS.ARITHMETIC#R1]
fichas: [help.arithmetic]
diagnosticos: [integerOverflow, incompatibleOperandTypes]
terminos: [expression, operator, operand]
---

::: frase
`+`, `-` and `*` compute with numbers: between two integers they give an exact integer and, if either is real, they give a real.
:::

## How it works {#funciona}

An **expression** combines values with **operators** to compute another value. The basic arithmetic operators are addition `+`, subtraction `-` and multiplication `*`, plus the minus sign in front of a number.

The type of the result depends on the operands:

| Operands | Result |
|---|---|
| `Integer` and `Integer` | exact `Integer` |
| at least one `Real` | `Real` |

```figura id=tipo-resultado
pie: Two integers give an integer; a single real is enough for the result to be real.
```

```programa id=aritmetica titulo="The basic sums"
```

Arithmetic operators only accept numbers. Adding a number and a boolean, or a number and a text, is detected before running.

::: limite
Integer operations are checked in 64 signed bits: if the result does not fit, the program stops with `integerOverflow`. There is no silent wrap-around. The minus sign applied to the smallest integer also overflows, because its opposite does not fit.
:::

::: resumen
- `+`, `-` and `*` operate on numbers.
- Two integers give an exact integer; if there is a real, the result is real.
- Going outside the integer range stops the program.
:::

::: vease
- [Division, div and mod](#expresiones.division)
- [Precedence and associativity](#expresiones.precedencia)
- [Primitive types](#tipos.primitivos)
:::

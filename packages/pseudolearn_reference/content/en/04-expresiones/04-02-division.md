---
id: expresiones.division
numero: "4.2"
tipo: concepto
titulo: "Division, `Div` and `Mod`"
anclas: [LANG.OPS.DIVISION#R1]
diagnosticos: [divisionByZero]
terminos: [division, quotient, remainder]
---

::: frase
There are three ways of dividing: `/` always gives a real, `Div` gives the integer quotient and `Mod` gives what is left over.
:::

## How it works {#funciona}

Sharing 7 sweets between 2 people allows three different questions, and each has its operator:

| Question | Operator | 7 by 2 |
|---|---|---|
| How much does each get exactly? | `/` | 3.5 |
| How many whole ones does each get? | `Div` | 3 |
| How many are left over? | `Mod` | 1 |

```figura id=reparto
pie: Seven sweets between two people: three each and one left over.
```

```programa id=dividir titulo="Three ways of dividing"
```

`Div` cuts **towards zero**: `-7 div 2` is -3, not -4. And `Mod` adjusts so that this always holds: dividend = quotient × divisor + remainder. That is why `-7 mod 2` is -1.

`/` always returns a `Real`, even when both numbers are integers. `Div` and `Mod` only accept integers.

::: limite
- Any zero divisor stops the program with `divisionByZero`, also in `/` with reals.
- The smallest integer divided by -1 overflows (`integerOverflow`).
- The sign of the remainder matches that of the dividend.
:::

::: errores
```programa id=entre-cero titulo="Dividing by zero"
```
:::

::: resumen
- `/` really divides and gives a real.
- `Div` gives the integer quotient, cut towards zero.
- `Mod` gives the remainder, with the sign of the dividend.
- Dividing by zero stops the program.
:::

::: vease
- [Arithmetic operators](#expresiones.aritmeticos)
- [Mathematics and rounding](#biblioteca.matematicas)
:::

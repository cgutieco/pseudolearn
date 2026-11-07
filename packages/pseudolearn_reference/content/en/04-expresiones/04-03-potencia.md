---
id: expresiones.potencia
numero: "4.3"
tipo: concepto
titulo: Power
anclas: [LANG.OPS.POWER#R1]
diagnosticos: [negativeIntegerExponent, integerOverflow, nonFiniteRealResult]
terminos: [power, exponent]
---

::: frase
`^` raises one number to another: `2 ^ 10` is 1024; between integers the result is exact, and with a real it is real.
:::

## How it works {#funciona}

The **power** `a ^ b` multiplies `a` by itself `b` times. As with the other operators, the type of the result depends on the operands: two integers give an exact integer; if either is real, the result is real.

```programa id=potencias titulo="Integer and real powers"
```

Two details worth knowing:

- Power **associates to the right**: `2 ^ 3 ^ 2` is `2 ^ (3 ^ 2)`, that is, 2 to the 9th.
- The sign binds **more** than the power: `-2 ^ 2` is `(-2) ^ 2`, which is 4.

```figura id=potencia-derecha
pie: Power groups from right to left. First 3 ^ 2 is computed and then 2 ^ 9.
```

::: limite
- With two integers, the exponent cannot be negative: `negativeIntegerExponent`. Use a real for that: `2.0 ^ -1` is 0.5.
- Any number to the power 0 is 1, including 0 ^ 0.
- An integer result that does not fit produces `integerOverflow`; an infinite real one, `nonFiniteRealResult`.
:::

::: errores
```programa id=exponente-negativo titulo="Negative exponent between integers"
```
:::

::: resumen
- `a ^ b` is the power; between integers it is exact.
- It associates to the right: `2 ^ 3 ^ 2` is 512.
- The sign applies first: `-2 ^ 2` is 4.
- Between integers the exponent cannot be negative.
:::

::: vease
- [Precedence and associativity](#expresiones.precedencia)
- [Mathematics and rounding](#biblioteca.matematicas)
:::

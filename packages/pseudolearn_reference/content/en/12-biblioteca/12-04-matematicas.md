---
id: biblioteca.matematicas
numero: "12.4"
tipo: concepto
titulo: Mathematics and rounding
anclas: [LIB.CORE.MATH#R1, LIB.CORE.MATH#R2, LIB.CORE.MATH#R3, LIB.CORE.ROUNDING#R1, LIB.CORE.ROUNDING#R2]
fichas: [help.builtin-math, help.builtin-rounding]
diagnosticos: [nonFiniteRealResult, integerOverflow]
terminos: [rounding, truncation]
---

::: frase
Mathematical functions compute roots, logarithms and trigonometry with results exact to the last bit, and rounding functions go from real to integer in four different ways.
:::

## How it works {#funciona}

Mathematical functions accept integers or reals and return reals: `sqrt`, `abs`, `ln`, `exp`, `log10`, `log2`, and the trigonometry in radians `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`. `min` and `max` return an integer if both arguments are integers.

The result is always the real closest to the exact value, on any machine: it does not depend on the system's maths library.

To go from real to integer there are four functions, which only differ on numbers with decimals:

| Function | Rule | 2.5 | -2.5 |
|---|---|---|---|
| `trunc` | towards zero | 2 | -2 |
| `round` | to the nearest; ties away from zero | 3 | -3 |
| `floor` | downwards | 2 | -3 |
| `ceil` | upwards | 3 | -2 |

```figura id=redondeos
pie: The four ways of taking -2.5 to an integer on the number line.
```

```programa id=mates titulo="Functions and rounding"
```

::: limite
- An argument outside the domain —the root of a negative, the logarithm of zero— produces `nonFiniteRealResult`.
- Rounding returns 64-bit integers: a real that is too large produces `integerOverflow`.
:::

::: errores
```programa id=raiz-negativa titulo="The root of a negative"
```
:::

::: resumen
- Mathematical functions return exact reals on any machine.
- `trunc`, `round`, `floor` and `ceil` go from real to integer.
- Outside the domain, the program stops.
:::

::: vease
- [Power](#expresiones.potencia)
- [Division](#expresiones.division)
:::

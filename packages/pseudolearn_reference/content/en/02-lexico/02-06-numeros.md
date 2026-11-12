---
id: lexico.numeros
numero: "2.6"
tipo: concepto
titulo: Numeric literals
anclas: [LANG.LEXICAL.NUMBER-LITERAL#R1]
diagnosticos: [integerLiteralOutOfRange]
terminos: [literal, integer, real]
---

::: frase
A number written in the program is an integer if it has only digits and a real if it has a point with digits on both sides.
:::

## How it works {#funciona}

A **literal** is a value written as it is in the program. Numeric literals come in two kinds:

- **Integers**: only digits, such as `0`, `42` or `2026`.
- **Reals**: digits, a point and more digits, such as `3.14` or `0.5`. The separator is always the point, not the comma, and there must be at least one digit on each side.

```figura id=literales-numericos
pie: What is read as an integer, what as a real and what is not a number.
```

The minus sign is not part of the literal: `-5` is the minus operator applied to `5`.

```programa id=numeros titulo="Integers and reals written as they are"
```

::: limite
An integer literal must fit in 64 signed bits: the largest is 9223372036854775807. The literal 9223372036854775808 is an error even when preceded by a minus; the smallest integer is obtained as `-9223372036854775807 - 1`. There is no scientific notation (`1e3` is not a number) and no thousands separators.
:::

::: errores
An integer that is too large is detected before running:

```programa id=enorme titulo="An integer that does not fit"
```
:::

::: resumen
- Integer: only digits. Real: digits, point and digits.
- The decimal separator is the point.
- The sign is a separate operator.
- An integer literal must fit in 64 signed bits.
:::

::: vease
- [Primitive types](#tipos.primitivos)
- [Arithmetic operators](#expresiones.aritmeticos)
:::

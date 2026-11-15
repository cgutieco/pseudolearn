---
id: biblioteca.conversion
numero: "12.3"
tipo: concepto
titulo: Conversions
anclas: [LIB.CORE.CONVERSION#R1, LIB.CORE.CONVERSION#R2]
fichas: [help.builtin-conversion, help.pgs08.text_decimals]
diagnosticos: [stringToNumberConversionFailed, decimalPlacesOutOfRange]
terminos: [conversion]
---

::: frase
Conversions change a value's type explicitly: from number to text, from text to number, or from real to text with a fixed number of decimals.
:::

## How it works {#funciona}

PseudoLearn never converts on its own. When needed, you ask:

| Function | Converts |
|---|---|
| `toText(v)` | any primitive to `String`, with the same format as `Write` |
| `toInteger(t)` | a decimal string to `Integer` |
| `toReal(t)` | a decimal string to `Real` |
| `decimals(x, n)` | a number to text with exactly `n` decimals |

```figura id=conversiones
pie: Conversions go back and forth between text and numbers. If the text is not a number, the conversion fails instead of making up a zero.
```

```programa id=conversiones titulo="Converting both ways"
```

`decimals` rounds ties away from zero, keeps the sign —that is why `-0.001` with one decimal is `-0.0`— and uses no thousands separators.

::: errores
```programa id=convertir-mal titulo="A text that is not a number"
```
:::

::: resumen
- Every conversion is explicit.
- `toText`, `toInteger` and `toReal` go between text and numbers.
- A text that is not a number fails; it does not become zero.
- `decimals` fixes a number's decimals.
:::

::: vease
- [Concatenation](#expresiones.concatenacion)
- [Value format](#tipos.primitivos)
:::

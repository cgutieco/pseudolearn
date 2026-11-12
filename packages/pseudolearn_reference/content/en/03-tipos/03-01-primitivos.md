---
id: tipos.primitivos
numero: "3.1"
tipo: tipo
titulo: Primitive types
anclas: [LANG.TYPES.INTEGER, LANG.TYPES.REAL#R1, LANG.TYPES.BOOLEAN#R1, LANG.TYPES.CHARACTER#R1, LANG.TYPES.TEXT#R1, LANG.IO.VALUE-FORMAT#R1]
diagnosticos: [integerOverflow, realEqualityComparison, noOrderBetweenBooleans, incompatibleTypesInAssignment, cannotConcatenateNumberWithText, nonFiniteRealResult, invalidCharacterCode]
terminos: [type, Integer, Real, Boolean, Character, String]
---

::: frase
Every piece of data has a type that says which values it can hold and what can be done with it; PseudoLearn has five primitive types and every other type is built from them.
:::

## How to write it {#escribe}

```forma
Define «name» As Integer
Define «name» As Real
Define «name» As Boolean
Define «name» As Character
Define «name» As String
```

```figura id=tipos-cajas
pie: The five primitive types. Two hold numbers, one a yes-or-no answer and two hold text: a single symbol or a row of symbols.
```

## How it works {#funciona}

A variable is declared with `Define`, its name, the word `As` and its type. From that moment it only accepts values of that type, and its type does not change while the program runs.

```programa id=ficha titulo="Lucía's card"
```

| Type | What it holds | Example values |
|---|---|---|
| `Integer` | A number without decimals | `0`, `42`, `-7` |
| `Real` | A number with a decimal part | `3.14`, `0.5`, `-2.0` |
| `Boolean` | The answer to a yes-or-no question | `True`, `False` |
| `Character` | A single symbol | `'A'`, `"7"` |
| `String` | A row of symbols, even an empty one | `"Hola"`, `""` |

::: analogia
Think of the type as the shape of a container: an egg box holds eggs and a bottle holds liquid. You cannot keep soup in the egg box even though both are "for keeping". The analogy stops working at one point: some values do move by themselves from one container to another, as long as nothing is lost.
:::

## `Integer` {#entero}

An `Integer` is a number without a decimal part. Integer operations give the **exact** result as long as it fits in the range. Going outside the range does not wrap around silently: the program stops.

## `Real` {#real}

A `Real` is a number with a decimal part. When written it always shows at least one decimal, so it can be told apart from an integer at a glance.

```programa id=precios titulo="Reals show their point"
```

The second line surprises almost everyone. It is not an engine bug: that is how reals work on any computer. A `Real` cannot hold just any number; it holds the nearest mark on a very fine ruler that still has gaps.

```figura id=regla-reales
pie: The ruler with gaps. 0.3 and 0.1 + 0.2 fall on neighbouring marks of the ruler, so they are not the same number.
```

## `Boolean` {#logico}

A `Boolean` has exactly two values, `True` and `False`. It is the type of every question: `edad >= 18` is not a number, it is a `Boolean`. It is not a number, it has no order and it does not turn into text by itself. When written it appears with the profile's word: `Verdadero` in Spanish and `true` in English.

## `Character` and `String` {#texto}

A `Character` is a single symbol: a letter, a digit, a sign, a space or an emoji. A `String` is a row of characters that may be empty. Positions inside a string count from zero.

```programa id=textos titulo="Measuring and looking inside a text"
```

## Moving from one type to another {#conversiones}

The language only converts a value on its own when no information can be lost: from `Integer` to `Real` and from `Character` to `String`. Everything else is requested with a function, because how to convert is the decision of whoever writes the program.

```programa id=conversiones titulo="Requested conversions"
```

`trunc` cuts the decimals towards zero and `round` rounds to the nearest integer. With `-8.7` they give different results, which is why the language does not choose for you.

::: limite
- `Integer`: 64 signed bits, from -9223372036854775808 to 9223372036854775807, both included. Going outside produces `integerOverflow`.
- `Real`: 64-bit binary floating point (IEEE 754 binary64), always finite. Every operation rounds to the nearest representable value and, on a tie, to the one with an even mantissa. An infinity or a "not a number" stops the program with `nonFiniteRealResult`. Both 0.0 and -0.0 exist.
- `Character`: a Unicode code point between 0 and 1114111, except the surrogates from 55296 to 57343.
- `String`: no maximum length fixed by the language; it counts code points, not visible letters.
:::

::: errores
Going past the maximum of an integer stops the program without writing anything:

```programa id=desborde titulo="Going past the maximum"
```

Comparing reals with `=` works, but the engine warns, because two calculations that should match may fall on neighbouring marks:

```programa id=comparar titulo="Comparing reals with ="
```

A number does not stick to a text with `+`; it has to be converted or separated with commas:

```programa id=mezcla titulo="A number does not stick to a text"
```

And a real does not fit into an integer on its own:

```programa id=sin-perder titulo="A real does not fit into an integer"
```
:::

::: por-dentro
Before running, the engine translates the program into its intermediate representation. Each constant says what kind of value it produces: `i64` (64-bit integer), `f64` (real), `char`, `str` and `bool`. Since the type of every value is known when compiling, the virtual machine never asks "what are you?" at each step.

```ri programa=ficha
```

The four fixed-size types fit in one machine slot; a string can be any length, so it lives on the heap and the slot only holds a reference.
:::

::: nota
- "A number in quotes is a number": `"7"` is a `Character` and `"75"` a `String`. Predict the type before running.
- "`/` between integers gives an integer": in PseudoLearn it always gives a real.
- "0.1 + 0.2 = 0.3": it is not a quirk of the language; the ruler figure shows why it happens.
:::

::: resumen
- There are five primitive types: `Integer`, `Real`, `Boolean`, `Character` and `String`.
- The type of a variable never changes.
- An `Integer` is exact within its range; going outside stops the program.
- A `Real` holds the nearest mark on a finite ruler and always shows a decimal.
- A `Boolean` is not a number and has no order.
- Only `Integer` to `Real` and `Character` to `String` happen by themselves.
:::

::: vease
- [Numeric literals](#lexico.numeros)
- [Relations between types](#tipos.relaciones)
- [Division, div and mod](#expresiones.division)
- [Conversion](#biblioteca.conversion)
:::

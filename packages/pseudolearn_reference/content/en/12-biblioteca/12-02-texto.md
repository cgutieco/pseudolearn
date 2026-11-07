---
id: biblioteca.texto
numero: "12.2"
tipo: concepto
titulo: Text functions
anclas: [LIB.CORE.TEXT#R1, LIB.CORE.TEXT#T1, LIB.CORE.TEXT#T2, LIB.CORE.TEXT#T3, LIB.CORE.TEXT#T4, LIB.CORE.TEXT#T5]
fichas: [help.builtin-text]
diagnosticos: [stringPositionOutOfRange, invalidCharacterCode, invalidPaddingText, paddingWidthOutOfRange]
terminos: [code point, substring]
---

::: frase
Text functions measure, trim, search and transform strings without ever modifying the original: they always return a new one.
:::

## How it works {#funciona}

They all work by **code points**: every Unicode character counts as one, accented or not. Positions start at **zero**.

| Function | What it returns |
|---|---|
| `length(t)` | how many characters it has |
| `substring(t, from, to)` | the piece between two positions, both included |
| `trim(t)` | without spaces at the start or end |
| `toUpper(t)`, `toLower(t)` | with every letter changed |
| `contains`, `startsWith`, `endsWith` | a `Boolean` |
| `indexOf(t, part)` | `Something(position)` or `Nothing` |
| `replace(t, find, put)` | with every occurrence changed |
| `split(t, separator)`, `join(v, separator)` | a vector of pieces, or the joined text |
| `charAt`, `charCode`, `charFromCode` | a character or its Unicode code |
| `padLeft`, `padRight` | the text filled up to a width |

```figura id=subcadena-posiciones
pie: Positions start at zero and `substring` includes both positions it receives: `substring(t, 0, 3)` is the first four characters.
```

```programa id=textos titulo="A tour of the text functions"
```

::: limite
- A position outside the text stops the program with `stringPositionOutOfRange`.
- `charFromCode` only accepts valid Unicode codes: from 0 to 1114111, without the range 55296 to 57343.
- Case changes follow full Unicode: `ß` becomes `SS`.
:::

::: resumen
- Text functions return new strings.
- They count Unicode characters and number from zero.
- `substring` includes both positions.
:::

::: vease
- [Concatenation](#expresiones.concatenacion)
- [Conversion](#biblioteca.conversion)
:::

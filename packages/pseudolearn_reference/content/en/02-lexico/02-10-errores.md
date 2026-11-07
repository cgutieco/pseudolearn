---
id: lexico.errores
numero: "2.10"
tipo: concepto
titulo: Lexical errors
anclas: [LANG.LEXICAL.ERRORS#R1, LANG.SYNTAX.ANALYSIS-LIMITS#R1, DIAG.CLASSES#R1]
diagnosticos: [unrecognizedCharacter, analysisNestingLimitExceeded]
terminos: [lexical error, recovery]
---

::: frase
A lexical error appears when a piece of the text does not form any valid token: a character the language does not know, an invented escape or unclosed quotes.
:::

## How it works {#funciona}

Lexical analysis splits the text into pieces. If it finds something that cannot be any piece, it emits a **lexical error** pointing at exactly that fragment. There are three situations:

| Situation | Diagnostic |
|---|---|
| A character that does not belong to the language, such as `@` | `unrecognizedCharacter` |
| An unknown escape inside a text | `invalidEscapeSequence` |
| Quotes that are never closed | `unterminatedString` |

When it can delimit the guilty fragment, the engine keeps reading to find more errors in the same pass. What it never does is invent a value or run a program with lexical errors.

```figura id=error-lexico
pie: The engine points at the guilty fragment and keeps reading. Semantic phases do not run while there are lexical errors.
```

```programa id=arroba titulo="A character that does not exist in the language"
```

There is a single diagnostic: the engine discards the `@` and does not report errors caused by the gap it leaves, such as a missing semicolon.

::: limite
Analysis accepts up to 256 constructs nested at once: parentheses, unary operators, chained powers and compound statements inside others. The next one produces `analysisNestingLimitExceeded`. The limit protects the engine; no reasonable program gets close to it.
:::

::: resumen
- Three lexical errors: unknown character, invalid escape and unclosed text.
- The diagnostic points at the exact fragment.
- With lexical errors there is no semantic analysis or execution.
:::

::: vease
- [Text and character literals](#lexico.textos)
- [Severity and classes](#diagnosticos.severidad)
:::

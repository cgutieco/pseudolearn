---
id: lexico.textos
numero: "2.7"
tipo: concepto
titulo: Text and character literals
anclas: [LANG.LEXICAL.TEXT-LITERAL#R1, LANG.LEXICAL.CHARACTER-LITERAL#R1]
diagnosticos: [invalidEscapeSequence, unterminatedString]
terminos: [string, character, escape]
---

::: frase
A text goes between double or single quotes; if it contains exactly one character it is a `Character`, and in any other case it is a `String`.
:::

## How it works {#funciona}

Texts are written between quotes. Double quotes `"…"` and single quotes `'…'` mean the same. What decides the type is how many characters are inside:

- Exactly one: it is a **character** (`Character`).
- None, or more than one: it is a **string** (`String`).

```figura id=cadena-caracter
pie: The number of characters between the quotes decides the type, not the kind of quotes.
```

Inside a text, the backslash starts an **escape sequence** to write special characters:

| Escape | Meaning |
|---|---|
| `\n` | line break |
| `\t` | tab |
| `\r` | carriage return |
| `\\` | one backslash |
| `\"` | double quote |
| `\'` | single quote |

```programa id=escapes titulo="Quotes and escapes"
```

::: limite
A character is a single Unicode code point, including those outside the basic plane such as a simple emoji. A grapheme made of several code points is a string. The text is kept as it is, without normalising. A text cannot span several lines: a line break is written with `\n`.
:::

::: errores
An escape that does not exist and unclosed quotes are detected before running:

```programa id=mal-escape titulo="An invented escape"
```

```programa id=sin-cerrar titulo="Unclosed quotes"
```
:::

::: resumen
- Double or single quotes: they mean the same.
- One character inside: `Character`. Zero or several: `String`.
- Escapes: `\n`, `\t`, `\r`, `\\`, `\"` and `\'`.
:::

::: vease
- [Primitive types](#tipos.primitivos)
- [Text](#biblioteca.texto)
:::

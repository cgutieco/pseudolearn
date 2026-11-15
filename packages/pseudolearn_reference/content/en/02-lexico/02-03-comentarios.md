---
id: lexico.comentarios
numero: "2.3"
tipo: concepto
titulo: Comments
anclas: [LANG.LEXICAL.COMMENT#R1]
terminos: [comment]
---

::: frase
A comment starts with `//` and runs to the end of the line; the engine keeps it but does not run it.
:::

## How it works {#funciona}

A **comment** is a note for the people reading the program. It starts with two slashes, `//`, and ends where the line ends. It can take a whole line or go at the end of an instruction.

```figura id=comentario
pie: Whatever is to the right of the two slashes is a comment up to the end of the line. Inside a quoted text, the slashes are just characters.
```

```programa id=comentarios titulo="Comments in their place"
```

The engine does not run comments, but it does not throw them away either: it keeps them so that the editor, the formatter and the profile translator leave them intact.

::: nota
PseudoLearn only has line comments. There is no comment that opens on one line and closes on another: to comment several lines, each one gets its own `//`.
:::

::: resumen
- `//` opens a comment up to the end of the line.
- Inside a quoted text, `//` is ordinary text.
- Comments are kept when formatting and translating.
:::

::: vease
- [Spaces and line breaks](#lexico.espacios)
- [Syntax profiles](#lectura.perfiles)
:::

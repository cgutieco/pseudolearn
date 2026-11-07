---
id: lexico.espacios
numero: "2.2"
tipo: concepto
titulo: Spaces and line breaks
anclas: [LANG.LEXICAL.WHITESPACE#R1]
terminos: [whitespace, indentation]
---

::: frase
Spaces, tabs and line breaks only separate pieces: indentation does not change the meaning and a line break does not end a statement.
:::

## How it works {#funciona}

Between two words of a program there may be one space, many, or a line break: it makes no difference to the engine. **Indentation** (the spaces at the start of a line) has no meaning either. It is used so that people can see what is inside what, but the engine follows the opening and closing words, such as `If` and `EndIf`.

```figura id=espacios
pie: Two ways of writing the same program. The spaces change the shape, not the content.
```

This program has careless indentation and extra spaces; even so it runs exactly like a well-written one:

```programa id=desordenado titulo="Careless indentation"
```

## A line break ends nothing {#salto}

A line break does **not** replace the semicolon. If you forget the `;`, the engine points it out even if the next statement starts on another line. Multi-word reserved words, such as `Step` or `Until`, cannot be split across two lines either.

::: docentes
Ask the class to write the same program with two different indentations and run it: the result does not change. Then explain why indentation is still essential for reading it. It is a good way of separating "what the machine understands" from "what a person needs".
:::

::: resumen
- Spaces, tabs and line breaks only separate pieces.
- Indentation means nothing to the engine, but a lot to people.
- A line break does not replace the semicolon.
:::

::: vease
- [Statement end](#lexico.fin-de-sentencia)
- [Comments](#lexico.comentarios)
:::

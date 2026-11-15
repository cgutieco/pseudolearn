---
id: lexico.texto-fuente
numero: "2.1"
tipo: concepto
titulo: Source text and encoding
anclas: [LANG.SOURCE.ENCODING#R1, LANG.SOURCE.ENCODING#R2, LANG.SOURCE.POSITION#R1]
terminos: [source text, UTF-8, position]
---

::: frase
A program is UTF-8 text; the engine reads it character by character and remembers the line and column of each one to point at errors precisely.
:::

## How it works {#funciona}

The **source text** is what you write. PseudoLearn reads it as **UTF-8** text, the encoding that lets you write ñ, accents and any other Unicode symbol inside texts and comments.

Every character has a **position**: its line and its column, counting from 1. When the engine finds a problem, it uses those positions to point at the exact place. Lines can be separated with any of the three usual operating-system conventions; the engine treats them the same.

```figura id=posiciones
pie: Every character has a line and a column. A diagnostic points at a span that starts at one position and ends just before another.
```

Texts keep exactly what you wrote, including characters outside the Latin alphabet:

```programa id=unicode titulo="Unicode inside a text"
```

## Normalisation {#normalizacion}

In Unicode, some accented letters can be written in two ways: as a single character or as a letter followed by an accent. To compare names, the engine first converts them to the same form, called **NFC**. That way `año` is always the same name, however you type it. Quoted texts are not touched.

::: limite
A position counts lines and columns from 1 and characters from 0. A span includes its start and excludes its end. A text that is not valid UTF-8 is not analysed: it is reported as an input failure.
:::

::: resumen
- Source text is UTF-8.
- Every character has a line and a column from 1.
- Names are compared after normalising to NFC; texts are not modified.
:::

::: vease
- [Spaces and line breaks](#lexico.espacios)
- [Identifiers](#lexico.identificadores)
:::

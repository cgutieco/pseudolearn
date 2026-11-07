---
id: lexico.fin-de-sentencia
numero: "2.9"
tipo: concepto
titulo: Statement end
anclas: [LANG.STMT.TERMINATION#R1, LANG.LEXICAL.WHITESPACE#R1]
diagnosticos: [missingStatementTerminator]
terminos: [statement, semicolon]
---

::: frase
Every simple statement ends with a semicolon; the words that open and close blocks, such as `If` or `EndWhile`, do not.
:::

## How it works {#funciona}

A **simple statement** is an instruction that contains no others: defining, assigning, writing, reading, calling or returning. Each one ends with `;`, including the last one before a closing word.

**Compound statements** contain others inside: `If`, `Switch`, `While`, `Repeat`, `For`. Their opening and closing lines have no semicolon; the simple statements inside do.

```figura id=punto-y-coma
pie: A semicolon at the end of every simple statement; none on the opening and closing lines of a block.
```

```programa id=terminacion titulo="Where the semicolon goes"
```

Several statements can share a line if each has its semicolon. Empty lines produce no statement.

::: errores
A forgotten semicolon is detected before running and the message points to where it should be:

```programa id=olvido titulo="A forgotten semicolon"
```
:::

::: resumen
- Simple statements end with `;`.
- Block openings and closings do not.
- Several statements are allowed on one line.
:::

::: vease
- [Spaces and line breaks](#lexico.espacios)
- [Statement termination](#declaraciones.terminacion)
:::

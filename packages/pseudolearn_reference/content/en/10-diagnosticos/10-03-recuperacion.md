---
id: diagnosticos.recuperacion
numero: "10.3"
tipo: concepto
titulo: Recovery and order
anclas: [LANG.SYNTAX.RECOVERY#R1, LANG.SYNTAX.RECOVERY#R2, LANG.SYNTAX.RECOVERY#R3, LANG.SYNTAX.RECOVERY#R4, LANG.SYNTAX.RECOVERY#R5, DIAG.ORDERING#R1]
diagnosticos: [missingStatementTerminator, expectedExpression, unclosedIfStatement, maxDiagnosticsExceeded]
terminos: [recovery, synchronization]
---

::: frase
After a syntax error, the engine looks for a safe point to keep reading: that way it reports every independent error at once, each one only once.
:::

## How it works {#funciona}

When a statement is badly written, analysis does not stop. It discards what it does not understand up to a **synchronization** point —the end of the line, a `;` or the edge of a block— and continues from there. Every broken statement produces **at most one** main diagnostic, and errors that fall on discarded text are not reported.

```programa id=dos-errores titulo="Two independent errors"
```

```figura id=sincronizacion
pie: Each error discards up to the next safe point and analysis continues. Correct lines are recognised as usual.
```

A block left unclosed produces **a single** diagnostic, with a related span pointing to where it opens, even if other outer blocks are pending:

```programa id=bloques-abiertos titulo="Two unclosed blocks"
```

## Order {#orden}

Diagnostics are published in a fixed order that does not depend on the language or on when they were found: first by phase (lexical, syntactic, semantic), then by position, length and code.

::: limite
- At most one hundred main syntax diagnostics are reported. When the cap is reached, `maxDiagnosticsExceeded` is added as a summary.
- Even an empty or completely invalid text produces a tree: the editor always has something to work with.
:::

::: resumen
- After an error, analysis synchronizes and continues.
- A broken statement gives at most one main diagnostic.
- An unclosed block gives a single diagnostic.
- The order is fixed: phase, position, length and code.
:::

::: vease
- [Severity and classes](#diagnosticos.severidad)
- [End of statement](#lexico.fin-de-sentencia)
:::

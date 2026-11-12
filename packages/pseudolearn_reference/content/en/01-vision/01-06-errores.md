---
id: vision.errores
numero: "1.6"
tipo: concepto
titulo: Errors, warnings and failures
anclas: [DIAG.CLASSES#R1, DIAG.SEVERITY.POLICY#R1, DIAG.MODEL#R1, LANG.TYPES.CHECKING-LEVELS#R1]
diagnosticos: [missingStatementTerminator, undeclaredVariable, variableDeclaredNeverUsed, arrayIndexOutOfRange]
terminos: [diagnostic, error, warning, failure]
---

::: frase
The engine warns with diagnostics: errors prevent running, warnings do not, and failures happen while the program runs.
:::

## How it works {#funciona}

Every notice from the engine is a **diagnostic**. They all have the same shape: a stable code, a severity, the exact position in the text and a message in the interface language. The code does not change with the language; that is why you can look it up in the catalogue.

Diagnostics are classified by **when** they are discovered:

| Class | When it appears | Example |
|---|---|---|
| lexical | when the text is split into pieces | a character that does not exist in the language |
| syntax | when the pieces are grouped | a missing semicolon |
| semantic | when names and types are checked | a variable nobody defined |
| runtime | while the program runs | an index outside the array |

And by **severity**: an **error** prevents the program from running; a **warning** points out something suspicious but lets it run; an **information** only informs.

```figura id=clases-diagnostico
pie: The diagnostic classes along the journey of the program. The first three are discovered before running.
```

A syntax error:

```programa id=sin-punto titulo="The semicolon is missing"
```

A semantic error:

```programa id=sin-definir titulo="A variable that does not exist"
```

A warning: the program runs anyway.

```programa id=sin-uso titulo="A variable too many"
```

A runtime failure: the analysis could not know that index 3 does not exist.

```programa id=fuera titulo="An index outside the array"
```

## No cascades {#cascadas}

If lexical or syntax analysis finds an error, the semantic checks do not run on the broken tree. That way a single slip does not multiply into dozens of messages that explain nothing.

::: resumen
- A diagnostic has a code, a severity, a position and a translated message.
- Classes: lexical, syntax, semantic and runtime.
- Errors prevent running; warnings do not.
- Runtime failures depend on concrete values.
:::

::: vease
- [Anatomy of a diagnostic](#diagnosticos.anatomia)
- [Diagnostic catalogue](#apendice.diagnosticos)
- [How a program ends](#vision.terminacion)
:::

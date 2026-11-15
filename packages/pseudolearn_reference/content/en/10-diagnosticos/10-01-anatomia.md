---
id: diagnosticos.anatomia
numero: "10.1"
tipo: concepto
titulo: Anatomy of a diagnostic
anclas: [DIAG.MODEL#R1, DIAG.MESSAGES#R1, DIAG.CATALOG#R1, DIAG.CATALOG#R2]
diagnosticos: [incompatibleTypesInAssignment]
terminos: [code, span, argument]
---

::: frase
A diagnostic is not a sentence: it is a piece of data with a stable code, a class, a severity and a position. The message you read is built afterwards, in your language.
:::

## How it works {#funciona}

Every diagnostic has these parts:

| Part | What it is |
|---|---|
| code | a stable name, the same in every language |
| class | lexical, syntactic, semantic or runtime |
| severity | error, warning or information |
| span | where it starts and ends in the text |
| related | other spans that help understand it |
| arguments | the concrete data: a name, a type, a number |

```figura id=anatomia-diagnostico
pie: The same diagnostic seen as data and as a message. The message is built with a template in the interface language and the arguments.
```

```programa id=texto-en-entero titulo="A diagnostic with arguments"
```

The data carries no text. To show it, the interface looks up the code's template in its language and fills in the arguments. That is why the message prose can be in English while the program uses the Spanish profile: user names are never translated, and the language's words appear in the active profile.

[Appendix C](#apendice.diagnosticos) lists every code with its class, severity and message.

::: resumen
- A diagnostic is data: code, class, severity, span and arguments.
- The message is built afterwards, with the language's template.
- The code does not change with the language.
:::

::: vease
- [Severity](#diagnosticos.severidad)
- [Errors, warnings and failures](#vision.errores)
- [Diagnostic catalogue](#apendice.diagnosticos)
:::

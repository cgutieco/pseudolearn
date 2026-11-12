---
id: diagnosticos.severidad
numero: "10.2"
tipo: concepto
titulo: Severity and classes
anclas: [DIAG.SEVERITY.POLICY#R1, DIAG.CLASSES#R1, DIAG.CLASSES#R2, DIAG.ENGINE.INTERNAL-FAULT#R1]
diagnosticos: [variableDeclaredNeverUsed, readValueTypeMismatch]
terminos: [severity, error, warning]
---

::: frase
Severity says what to do with a diagnostic: an error prevents running, a warning tells you and lets you continue.
:::

## How it works {#funciona}

Every code has **a single severity**, fixed in the catalogue and independent of its class. They are grouped by a letter:

| Letter | Severity | Examples |
|---|---|---|
| A | structural error or runtime failure | `missingStatementTerminator`, `divisionByZero` |
| C | hygiene warning | `variableDeclaredNeverUsed` |
| D | information | suggestions without consequence |
| E | recoverable reading warning | `readValueTypeMismatch` |

The letter B is not assigned.

```figura id=severidad-clases
pie: Classes say in which phase the problem is detected; severity, what consequence it has.
```

Classes follow the program's journey: **lexical** and **syntactic** while reading the text, **semantic** while checking types and names, and **runtime** while it runs. If there are lexical or syntactic errors, the semantic phase does not run: that way no errors derived from a broken tree appear.

A warning stops nothing. When reading a value that does not fit the type, the engine warns and **asks again**, without changing the variable:

```programa id=leer-mal titulo="A read that is repeated"
```

::: limite
A defect in the engine itself is never shown as a program error. It is caught at the boundary and produces an **internal failure** distinct from any diagnostic. No program, valid or not, should cause it.
:::

::: resumen
- Every code has a fixed severity: A error, C hygiene, D information, E reading.
- Classes give the phase: lexical, syntactic, semantic or runtime.
- With syntax errors no semantic analysis is done.
:::

::: vease
- [Anatomy of a diagnostic](#diagnosticos.anatomia)
- [Recovery and order](#diagnosticos.recuperacion)
- [Unused variables](#declaraciones.sin-usar)
:::

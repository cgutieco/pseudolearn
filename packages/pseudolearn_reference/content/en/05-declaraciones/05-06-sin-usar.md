---
id: declaraciones.sin-usar
numero: "5.6"
tipo: concepto
titulo: Unused variables
anclas: [LANG.DECL.UNUSED#R1]
diagnosticos: [variableDeclaredNeverUsed, variableAssignedNeverRead]
terminos: [warning]
---

::: frase
A variable that is declared and never used, or written and never read, produces a warning: the program works, but something is left over.
:::

## How it works {#funciona}

The engine tells two oversights apart:

| Situation | Warning |
|---|---|
| declared and never used | `variableDeclaredNeverUsed` |
| assigned but never read | `variableAssignedNeverRead` |

Both are **warnings**: they do not prevent running. They usually point to a misspelt name, a result someone forgot to show or a leftover from an earlier version.

```programa id=limpieza titulo="Two variables too many"
```

```figura id=higiene
pie: Three variables and their use. Only the first is written and read.
```

Parameters and subprograms nobody uses have their own warnings, with the same idea.

::: resumen
- Declaring and not using, or writing and not reading, produces a warning.
- Warnings do not prevent running.
- They usually point to a name mistake or a forgotten result.
:::

::: vease
- [Severity](#diagnosticos.severidad)
- [Declaring variables with Define](#declaraciones.definir)
:::

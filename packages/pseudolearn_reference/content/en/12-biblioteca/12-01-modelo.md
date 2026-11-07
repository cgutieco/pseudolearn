---
id: biblioteca.modelo
numero: "12.1"
tipo: concepto
titulo: How the library is organised
anclas: [LIB.MODEL#R1, LIB.MODEL#M1, LIB.MODEL#M2, LIB.MODEL#M3, LIB.MODEL#M4, LIB.SCENARIO.BILINGUAL#R1]
diagnosticos: [undeclaredSubroutine]
terminos: [built-in function, operation, family]
---

::: frase
The library is the set of functions the language brings: each has a fixed identity, a name in each profile and a signature that does not change with the language.
:::

## How it works {#funciona}

There are two kinds of symbols:

- **built-in functions**, called by name: `length(t)`, `sqrt(x)`, `parseJson(text)`;
- **operations**, called on a receiver with a dot: `console.writeError(text)`, `date.isoFormat()`.

Every symbol belongs to a **family**: text, bytes, numbers, collections, input and output, time, JSON, network or tasks. [Appendix D](#apendice.funciones) lists them all.

```figura id=familias-biblioteca
pie: The library families. Those on the left compute; those on the right need a host capability.
```

A symbol has **a single identity**: its Spanish name, its English name and its aliases name the same thing with the same signature. `ConvertirANumero` is an alias of `AReal`:

```programa id=alias-biblioteca titulo="Two names, one function"
```

No library name matches a reserved word, and library names are **not** reserved: a subprogram of your own with the same name hides the built-in one throughout the text.

Since every symbol has its own identity, a project can mix modules written in different profiles: an English module calling `length` and a Spanish one calling `Longitud` use the same function.

::: resumen
- Built-in functions by name; operations on a receiver.
- Every symbol has an identity, names in both profiles and aliases.
- The input, output, time and network families need capabilities.
:::

::: vease
- [Function catalogue](#apendice.funciones)
- [Effects and capabilities](#tareas.efectos)
:::

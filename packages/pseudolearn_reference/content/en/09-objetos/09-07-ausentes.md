---
id: objetos.ausentes
numero: "9.7"
tipo: concepto
titulo: What classes do not have
anclas: [LANG.CLASS.OUT-OF-SCOPE#R1]
diagnosticos: [unsupportedAbstractConstruct, unsupportedStaticConstruct, unsupportedProtectedConstruct, unsupportedExceptionConstruct]
terminos: [absent construct]
---

::: frase
PseudoLearn deliberately leaves out some pieces of other object languages, and when it recognises them it explains so with a message of its own.
:::

## How it works {#funciona}

These constructs are **not part** of the current edition:

| Construct | Diagnostic |
|---|---|
| abstract classes and methods | `unsupportedAbstractConstruct` |
| static members | `unsupportedStaticConstruct` |
| protected visibility | `unsupportedProtectedConstruct` |
| exception handling with blocks | `unsupportedExceptionConstruct` |

```figura id=ausentes
pie: The four constructs that are recognised to explain that they do not exist, and what PseudoLearn offers instead.
```

The engine recognises their typical forms **only in a structural position** —for example, one more word in a class header— and gives a teaching message instead of a generic error. Those words **are not reserved**: they can be used as names anywhere else.

```programa id=estatico titulo="A static member"
```

For expected errors, the language uses values: [Optional and Result](#tipos.opcional-resultado). To share data between objects, it is passed as parameters.

::: resumen
- There are no abstract classes, static members, protected or exceptions.
- Their typical forms produce a message of their own.
- Those words remain valid names.
:::

::: vease
- [Classes and attributes](#objetos.clase)
- [Optional and Result](#tipos.opcional-resultado)
:::

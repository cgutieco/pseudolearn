---
id: vision.que-es
numero: "1.1"
tipo: concepto
titulo: What PseudoLearn is
anclas: [LANG.PROGRAM.STRUCTURE#R1, LANG.PROGRAM.CLASSIC#R1, LANG.PROFILE.MODEL#R1]
terminos: [pseudocode, algorithm, engine]
---

::: frase
PseudoLearn is a pseudocode language that really runs: what you write is analysed, run and can be watched step by step.
:::

## How it works {#funciona}

**Pseudocode** is a way of writing algorithms with words close to everyday language. Many books use it to explain ideas without depending on a particular language. PseudoLearn takes that tradition and gives it exact rules, so that a machine can check every program and run it.

A PseudoLearn program always has a named **algorithm**: it starts with `Algorithm` and ends with `EndAlgorithm`. The instructions go inside, one below the other.

```programa id=media titulo="The average of two grades"
```

```figura id=ecosistema
pie: One language and one engine behind the editor, the command line and the web.
```

## Classic pseudocode, unchanged {#clasico}

If you have written pseudocode in class, almost everything you know works the same: algorithm, define, read, write, if, switch, while, repeat and for. PseudoLearn adds three requirements that avoid hard-to-see mistakes: every simple statement ends with a semicolon, indices start at zero and no variable has an invented initial value.

::: analogia
PseudoLearn is like a recipe written by a very careful person: it says exactly which ingredients to use and in what order. The analogy stops working in that a person reads a recipe with common sense, and the engine does not: if something is not written precisely, it points it out.
:::

::: resumen
- PseudoLearn is pseudocode with exact rules.
- Every program has a named `Algorithm` and its `EndAlgorithm`.
- The same engine is behind the editor, the command line and the web.
- Classic pseudocode works with semicolons, indices from zero and no invented values.
:::

::: vease
- [The journey of a program](#vision.viaje)
- [Structure of a program](#programas.estructura)
- [Structure of a program](#programas.estructura)
:::

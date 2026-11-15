---
id: vision.viaje
numero: "1.2"
tipo: concepto
titulo: "The journey of a program: from text to execution"
anclas: [ENG.EXEC.MODEL#R1, IR.LOWERING#R2, LANG.TYPES.CHECKING-LEVELS#R1]
terminos: [token, syntax tree, intermediate representation, bytecode, virtual machine]
---

::: frase
Before running a program, the engine breaks it into pieces, checks that it makes sense and translates it into simple instructions for its virtual machine.
:::

## How it works {#funciona}

When you press "Run", the program text travels along a path of five stages. Each stage produces something new from the previous one. Step through the figure to follow the program `Doble` on its journey.

```programa id=doble titulo="The travelling program"
```

```figura id=viaje
pie: The five stages of the engine. The first three happen before anything runs; if any of them finds errors, the program never runs.
paso: **Lexical analysis.** The text is split into pieces called tokens: `Algorithm`, `Doble`, `Define`, `n`, `As`, `Integer`… Spaces and comments are kept aside.
paso: **Syntax analysis.** The tokens are grouped into a tree: an algorithm containing a definition and a write.
paso: **Semantic analysis.** The engine checks names and types: `n` exists, it is an `Integer` and so is `n * 2`.
paso: **Translation.** The tree becomes an intermediate representation and then simple instructions for the virtual machine.
paso: **Execution.** The virtual machine runs the instructions one by one and writes 42.
panel Stage 1: tokens
panel Stage 2: tree
panel Stage 3: checked types
panel Stage 4: instructions
panel Output 5: 42
```

## Check first, run afterwards {#comprobar}

The first three stages form the **analysis**. If they find an error, the program does not run: it would make no sense to run something that is not understood. That is why a typing mistake shows up immediately, without waiting for the program to reach that line.

Some errors cannot be seen by the analysis because they depend on real values: dividing by zero, going outside an array or reading a variable without a value. Those are detected when running, at the exact moment they happen.

::: por-dentro
This is the real intermediate representation of the program `Doble`. Each line is a simple instruction; `stmt.enter` and `stmt.exit` mark where each statement starts and ends, which is what makes step-by-step execution possible.

```ri programa=doble
```
:::

::: resumen
- The engine works in five stages: lexical, syntax, semantics, translation and execution.
- If the analysis finds errors, the program does not run.
- Errors that depend on concrete values appear when running.
:::

::: vease
- [Analysing, running and observing](#vision.analizar-ejecutar)
- [Map of the engine layers](#motor.capas)
- [The engine's layers](#motor.capas)
:::

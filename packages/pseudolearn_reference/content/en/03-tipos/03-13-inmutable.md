---
id: tipos.inmutable
numero: "3.13"
tipo: concepto
titulo: "`immutable` and `snapshot`"
anclas: [LANG.TASK.ISOLATION#R4, LANG.TASK.ISOLATION#R5, LANG.TASK.ISOLATION#R7, LANG.TASK.ISOLATION#R6]
fichas: [help.snapshot_builtin, help.immutable_type]
diagnosticos: [immutableValueWrite, snapshotNotSupported]
terminos: [immutable, snapshot, deep copy]
---

::: frase
`snapshot` takes a complete picture of a value and returns it as `immutable`: everything can be read, but nobody can change it.
:::

## How it works {#funciona}

Vectors, dictionaries and arrays are shared: if someone modifies them, everyone sees it. Sometimes the opposite is needed, a value that **cannot** change. `snapshot(x)` copies `x` whole, with everything it contains, and returns an `immutable` of that type.

```programa id=congelar titulo="A picture that does not change"
```

```figura id=instantanea
pie: The snapshot copies the whole content. Whatever happens to the original afterwards does not affect the picture.
```

An `immutable` allows every read, but no write and no modifying method:

```programa id=escribir-foto titulo="Trying to change the picture"
```

## Why it exists {#por-que}

Concurrent tasks cannot share vectors or dictionaries, because two tasks could change them at the same time. An `immutable` can cross between tasks: since nobody modifies it, sharing it is safe.

::: limite
- `snapshot` accepts primitives, enumerations, records, variants, vectors, dictionaries and arrays, and copies deeply keeping internal aliases.
- It does not accept class objects or functions: `snapshotNotSupported`.
- The copy counts towards the engine's memory limit.
- `copy` makes a shallow copy and gives no immutability.
:::

::: resumen
- `snapshot(x)` copies everything and returns an `immutable`.
- An `immutable` is read but not modified.
- Whatever the original changes afterwards does not affect the snapshot.
- Immutables can move from one task to another.
:::

::: vease
- [Isolation between tasks](#tareas.aislamiento)
- [Copy](#biblioteca.copia)
:::

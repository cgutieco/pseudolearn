---
id: objetos.copia
numero: "9.6"
tipo: concepto
titulo: Copies, references and identity
anclas: [LANG.CLASS.COPY#R1, LIB.CORE.COPY#R1, MEM.IDENTITY#R1, MEM.IDENTITY#R2, MEM.IDENTITY#R3, MEM.IDENTITY#R4, MEM.VALUE.COPY#R1, MEM.VALUE.COPY#R2, MEM.VALUE.COPY#R3, MEM.VALUE.COPY#R4]
fichas: [help.builtin-copy]
diagnosticos: [incompatibleArgumentType]
terminos: [reference, identity, shallow copy]
---

::: frase
Assigning an object does not duplicate it: it gives another name to the same object. To get a new object with the same data you need `Copiar`.
:::

## How it works {#funciona}

Not all values behave the same when assigned:

| Value | When assigned or passed by value |
|---|---|
| numbers, booleans, characters and texts | **copied**: changing the source does not affect the copy |
| objects | **shared**: both names see the same object |
| arrays | passed by reference |

`Copiar(object)` creates a **new** object of the same class without running the constructor, and copies **a single level**: primitive attributes are copied, and those that are references stay shared with the original.

```programa id=copias titulo="An alias and a copy"
```

```figura id=alias-copia
pie: `a` and `alias` point to the same object; `copia` points to another one with the same data at first.
paso: `alias <- a` creates nothing: two arrows to the same object.
paso: `Copiar(a)` creates a second object with the same values.
paso: Changing `alias.libros` is visible through `a`; changing `copia.libros` is not.
```

## Identity {#identidad}

Every object or array has an **identity**: the order number in which it was created during the run. The first is 1, the next 2, and so on. Identity never changes and is never reused, even after the object is no longer used. `=` between objects compares identities: that is why `a = copia` is `False` even though they hold the same data.

Reference cycles —an object pointing to another that points back to the first— are valid.

::: resumen
- Primitives and texts are copied; objects are shared.
- `Copiar` creates a new object and copies a single level.
- Identity is the creation order and is never reused.
- `=` between objects compares identity, not contents.
:::

::: vease
- [Classes and attributes](#objetos.clase)
- [Parameters](#subprogramas.parametros)
- [Memory](#motor.memoria)
:::

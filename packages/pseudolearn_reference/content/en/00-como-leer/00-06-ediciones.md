---
id: lectura.ediciones
numero: "0.6"
tipo: concepto
titulo: Editions
anclas: [LANG.EDITION.MODEL#R1, LANG.EDITION.MODEL#R2, LANG.PROFILE.STRICTNESS#R1]
terminos: [edition, prelude]
---

::: frase
An edition is a closed version of the language; this specification describes the 2026 edition.
:::

## How it works {#funciona}

The language changes over time, but each **edition** fixes a set of rules that does not move. The current edition is called **2026**. A program written for 2026 is always analysed and run the same way.

The edition is not written inside the program and does not depend on the profile. Switching from Spanish to English does not enable constructs from other editions.

```figura id=edicion
pie: The 2026 edition brings together a single grammar, a single type policy and a fixed prelude of built-in symbols.
```

## The prelude {#preludio}

Every program of the 2026 edition sees a **prelude** from the start: a fixed set of built-in functions and types, such as `length` or `Optional`. It does not need importing and is not read from any file on the computer. If you declare a subroutine with the same name as a built-in function, yours hides it.

```programa id=preludio titulo="Using the prelude without importing anything"
```

The prelude declares names, never permissions. Reading a file or using the network requires asking the environment for a capability, as explained in Part XII.

## Common rules of the edition {#reglas}

The 2026 edition applies a single grammar: every simple statement ends with a semicolon, every parameter declares its type and indices start at zero. There is no "flexible mode" and no option that changes the meaning of a program.

::: resumen
- The current edition is 2026.
- An edition is not written in the program and does not depend on the profile.
- The prelude gives functions and types without importing anything, but not permissions.
- A single grammar and a single type policy for everyone.
:::

::: vease
- [Strictness](#programas.estrictez)
- [Permissions and capabilities](#biblioteca.permisos)
- [Built-in functions](#apendice.funciones)
:::

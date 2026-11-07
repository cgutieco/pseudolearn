---
id: tipos.enumerados
numero: "3.8"
tipo: tipo
titulo: Enumerations
anclas: [LANG.TYPES.ENUM]
fichas: [help.enum]
diagnosticos: [undefinedEnumMember, duplicateEnumMember, incompatibleOperandTypes]
terminos: [enumeration, member]
---

::: frase
An enumeration is a type with a closed list of named values, like the colours of a traffic light.
:::

## How to write it {#escribe}

```forma
Enum «Name»
  «member», «member», …
EndEnum
```

```railes produccion=enumUnit
```

## How it works {#funciona}

An **enumeration** declares a new type whose only values are the **members** of the list. Each member is written with the type's name, a dot and its name. A variable of that type can only hold one of those members, so there are no invented values and no typos that go unnoticed.

```programa id=semaforo titulo="A named traffic light"
```

```figura id=enumerado
pie: An enumeration is a closed list. A variable of the type can only point to one of its members.
```

Enumerations go very well with `Switch`, which can have one case per member:

```programa id=segun-enumerado titulo="One case per colour"
```

::: limite
- Each member has an internal 32-bit ordinal from 0, in declaration order, but the program cannot convert it to a number.
- An enumeration may be empty or have a single member.
- It only accepts `=` and `<>`; it has no order and no arithmetic.
- `Write` shows the member's name exactly as declared.
:::

::: errores
A member that does not exist is detected before running:

```programa id=azul titulo="A colour that does not exist"
```

And members are not ordered:

```programa id=orden-enum titulo="Comparing with less than"
```
:::

::: por-dentro
When running, a member is just its ordinal: a small integer in a slot. The name is recovered from the declaration when it needs to be written. Comparing two members means comparing two integers.

```ri programa=semaforo
```
:::

::: resumen
- An enumeration is a type with a closed list of members.
- Members are written `Type.member`.
- They only accept equality and inequality.
- They work very well with `Switch`.
:::

::: vease
- [Variants](#tipos.variantes)
- [Switch](#control.segun)
:::

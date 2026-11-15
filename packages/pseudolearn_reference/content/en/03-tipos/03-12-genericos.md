---
id: tipos.genericos
numero: "3.12"
tipo: concepto
titulo: Generics
anclas: [LANG.TYPES.GENERIC#R1, LANG.TYPES.GENERIC#R2]
fichas: [help.pgl04.type_parameter, help.pgl04.generic_class]
diagnosticos: [typeArgumentCountMismatch, incompatibleOperandTypes]
terminos: [generic, type parameter]
---

::: frase
A generic is a subroutine or a type written once for any type: the concrete type is filled in when it is used.
:::

## How it works {#funciona}

Sometimes the same idea works for many types: a box that holds a value, a subroutine that returns what it receives. With a **type parameter**, written between `<` and `>` after the name, a single version is written.

```programa id=identidad titulo="A subroutine for any type"
```

The engine **infers** the type `T` in each call from the arguments. Records, classes, interfaces and variants can also be generic:

```programa id=caja titulo="A generic box"
```

```figura id=generico
pie: A template with a type slot. Each use fills it with a concrete type and gets its own version.
```

## What can be done with a value of type T {#opaco}

Inside the generic, `T` is **opaque**: the engine does not know what type it will be, so it only allows copying, passing, returning and storing the value. Adding it, comparing it or writing it is an error in the definition itself, even if every call used numbers.

```programa id=mayor titulo="Comparing two values of type T"
```

::: resumen
- A type parameter `<T>` lets you write a single version for many types.
- The concrete type is inferred in each call or written between `<` and `>`.
- Inside the generic, `T` is only copied, passed, returned and stored.
- Records, subroutines, classes, interfaces and variants can be generic.
:::

::: vease
- [Functions as values](#tipos.funciones)
- [Interfaces](#objetos.interfaces)
:::

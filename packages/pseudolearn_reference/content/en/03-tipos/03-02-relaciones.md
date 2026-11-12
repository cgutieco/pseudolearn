---
id: tipos.relaciones
numero: "3.2"
tipo: concepto
titulo: Relations between types and widening
anclas: [LANG.TYPES.RELATIONS#R1]
diagnosticos: [incompatibleTypesInAssignment]
terminos: [widening, assignability]
---

::: frase
A value only moves by itself from one type to another when the target type contains it whole: from `Integer` to `Real`, from `Character` to `String` and from a subclass to its superclass.
:::

## How it works {#funciona}

Two types can be related in three different ways, and they should not be mixed up:

- **Equality**: they are the same type.
- **Widening**: a value of one fits into the other without losing anything.
- **Assignability**: a value can be stored in a variable of the other, either because they are equal or because it widens.

There are three widenings, and no more:

```figura id=ampliaciones
pie: The only three arrows the engine follows on its own. The crossed-out arrows require a conversion function.
```

Widening applies when initialising, assigning, passing an argument by value, returning a result and storing in a collection. Also when comparing: a character compared with a string is widened to a string before comparing.

```programa id=amplia titulo="Automatic widenings"
```

In the opposite direction there is no widening: a `Real` does not become an `Integer` by itself, a `Boolean` is not a number and a number does not turn into text by itself.

```programa id=no-amplia titulo="An integer is not a text"
```

::: nota
By-reference parameters are the exception: they require exactly the same type, without widening, because the subroutine will write to the original variable.
:::

::: resumen
- Equality, widening and assignability are different relations.
- There are only three widenings: `Integer` to `Real`, `Character` to `String` and subclass to superclass.
- Everything else is requested with a conversion function.
- By reference requires the exact type.
:::

::: vease
- [Primitive types](#tipos.primitivos)
- [Passing by value and by reference](#subprogramas.referencia)
- [Inherits From](#objetos.herencia)
:::

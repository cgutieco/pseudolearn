---
id: declaraciones.asignacion
numero: "5.3"
tipo: construccion
titulo: Assignment
anclas: [LANG.STMT.ASSIGNMENT#R1]
fichas: [help.assignment]
diagnosticos: [incompatibleTypesInAssignment, invalidAssignmentTarget, arrayIndexOutOfRange]
terminos: [assignment, target]
---

::: frase
`x <- value` stores a new value in a variable and forgets the one it had.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=assignmentStatement
```

::: partes
- «target» is a [designator](#declaraciones.designadores): a variable, an array cell or an attribute.
- `<-` is the assignment arrow. It reads "receives".
- «expression» computes the new value. Its type must fit that of the target.
- `;` ends the statement.
:::

## How it works {#funciona}

Assignment happens in three stages, always in this order:

1. The target is evaluated: the variable and, if any, its indices.
2. The right-hand expression is evaluated, with the values that exist **before** assigning.
3. The result is stored in the target.

That is why `contador <- contador + 1` works: the right side reads the old value and the result replaces the old one.

The classic example is swapping two values. A third variable is needed, because assigning loses what was there:

```programa id=intercambio titulo="Swapping two variables"
```

```figura id=intercambio
pie: Swapping two values needs an auxiliary box that keeps the first one before it is overwritten.
paso: Starting point: `a` is 1 and `b` is 2.
paso: `auxiliar <- a;` copies the 1 into the auxiliary box.
paso: `a <- b;` overwrites the 1 in `a` with a 2. The 1 is still safe in `auxiliar`.
paso: `b <- auxiliar;` gets the 1 back. The values are swapped.
```

Assigning an object copies the **reference**, not the object: afterwards both variables name the same object. A whole array is not assigned in one go.

::: errores
The type on the right must fit the target:

```programa id=asignar-tipo titulo="A text in an integer variable"
```

An index out of range is only discovered when running:

```programa id=asignar-fuera titulo="Assigning outside the array"
```
:::

::: por-dentro
Every assignment to a local variable is a `store` in its slot. Notice that `auxiliar <- a` is a `load` from the slot of `a` followed by a `store` in that of `auxiliar`.

```ri programa=intercambio
```
:::

::: nota
It is easy to read `a <- b` as a mathematical equality. Draw the boxes and explain why `a <- b; b <- a;` swaps nothing.
:::

::: resumen
- `<-` stores a new value and forgets the previous one.
- First the target, then the right side, finally the store.
- The type must fit; indices are checked when running.
:::

::: vease
- [Designators](#declaraciones.designadores)
- [Declaring variables with Define](#declaraciones.definir)
- [Copies and references](#objetos.copia)
:::

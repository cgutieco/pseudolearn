---
id: control.para-cada
numero: "6.6"
tipo: construccion
titulo: "Walking collections with `For Each`"
anclas: [LANG.CONTROL.FOR-EACH#R1, LANG.CONTROL.FOR-EACH#R2]
fichas: [construction.for_each]
diagnosticos: [collectionModifiedDuringIteration, immutableBindingAssignment]
terminos: [traversal, element]
---

::: frase
`For Each` visits the elements of a vector, an array or a dictionary one by one, without indices.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=forEachLoop contextuales=Cada,En
```

::: partes
- `For Each` opens the traversal.
- «element» is a new name that, on every round, holds the visited element. It cannot be assigned.
- `In` separates the names from the collection.
- «collection» is a `Vector`, a one-dimensional array or, with two names, a `Dictionary`.
- `EndFor` closes the traversal.
:::

## How it works {#funciona}

The collection is computed once. Then every element is visited in order: from position 0 onwards for vectors and arrays, and in insertion order for dictionaries. An empty collection does not run the body.

```programa id=lista-compra titulo="Walking a vector"
```

```figura id=para-cada-recorrido
pie: The traversal moves through the cells in order. On every round, `producto` holds a copy of the visited element.
paso: First round: `producto` is `"pan"`.
paso: Second round: `producto` is `"leche"`.
paso: Third round: `producto` is `"huevos"`. There are no more and the traversal ends.
```

With a dictionary two names are needed, the key and the value:

```programa id=recorrer-edades titulo="Walking a dictionary"
```

::: limite
During the traversal the collection cannot change its **structure**: adding or removing elements stops the program with `collectionModifiedDuringIteration`, even when done through another name. Replacing the value of an existing element is allowed.
:::

::: errores
```programa id=modificar-recorrido titulo="Adding while walking"
```
:::

::: por-dentro
The traversal keeps the version of the collection when it starts and compares it before every step. If it does not match, the trap is raised.

```ri programa=lista-compra
```
:::

::: resumen
- `For Each` visits every element in order, without indices.
- With dictionaries two names are written: key and value.
- The element name cannot be assigned.
- Changing the structure of the collection during the traversal is a failure.
:::

::: vease
- [For](#control.para)
- [Vectors](#tipos.vectores)
- [Dictionaries](#tipos.diccionarios)
:::

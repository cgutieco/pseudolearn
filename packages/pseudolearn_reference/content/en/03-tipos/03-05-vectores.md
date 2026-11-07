---
id: tipos.vectores
numero: "3.5"
tipo: tipo
titulo: Vectors
anclas: [LANG.TYPES.VECTOR]
fichas: [construction.vector, help.pgs02.vector_sort, help.pgs02.vector_contains]
diagnosticos: [arrayIndexOutOfRange, collectionCannotBeWritten, collectionLimitExceeded]
terminos: [vector, collection, shared reference]
---

::: frase
A vector is a list that grows and shrinks while the program runs; all its elements have the same type.
:::

## How to write it {#escribe}

```forma
Define «name» As vector<«type»> <- vector();
«name».append(«value»);
«name».insert(«position», «value»);
«name».remove(«position»);
«name»[«position»]
```

## How it works {#funciona}

Unlike an array, a **vector** has no fixed size. It starts empty and grows with `append` (at the end) or `insert` (at a position); it shrinks with `remove`. Positions count from zero and `length` says how many elements it has.

```programa id=compra titulo="The shopping list"
```

```figura id=vector-crece
pie: A vector grows and shrinks. Inserting shifts what was already there to the right; removing closes the gap.
paso: The vector starts empty.
paso: `append` puts "pan" at the end and then "leche".
paso: `insert(0, …)` puts "fruta" at the start and shifts the rest.
paso: `remove(1)` takes out position 1 and the rest moves left.
```

## A shared reference {#referencia}

A vector is a **reference**: two variables can point to the same vector. If it is changed through one of them, the other sees the change, because there are not two vectors but one.

```programa id=compartido titulo="Two names, a single vector"
```

To get an independent copy, use `copy`.

## Methods {#metodos}

| Method | What it does |
|---|---|
| `append(x)` | Adds at the end |
| `insert(i, x)` | Adds at position `i` (from 0 to the length) |
| `remove(i)` | Takes out position `i` |
| `length()` | How many elements there are |
| `sort()` | Sorts from smallest to largest; accepts a comparator |
| `reverse()` | Turns the order around |
| `contains(x)` | `True` if `x` is there |
| `indexOf(x)` | `Some(position)` or `None` |

::: limite
- Positions: from 0 to `length() - 1`. `insert` also accepts `length()` (at the end).
- The natural order of `sort` works for `Integer`, `Real`, `Character`, `String` and `Boolean` (`False` before `True`); it is stable.
- The maximum size is set by the engine's memory budget; exceeding it produces `collectionLimitExceeded`.
- `Write` shows the elements between brackets separated by comma and space, with strings in quotes.
:::

::: errores
Reading or removing a position that does not exist stops the program:

```programa id=vacio titulo="Removing from an empty vector"
```

And a vector whose elements cannot be written does not accept `Write`:

```programa id=no-imprimible titulo="A vector of records"
```
:::

::: por-dentro
A vector lives on the heap: the variable holds a reference. Its capacity starts at zero, becomes one and then doubles each time it fills up, so appending at the end is cheap almost always. Every structural change increments an internal version that makes it possible to detect whether someone modifies it while it is being iterated.

```ri programa=compartido
```
:::

::: resumen
- A vector grows and shrinks; all its elements have the same type.
- Positions from zero; going outside is a failure.
- It is a reference: assigning it shares the same vector.
- `copy` creates an independent one.
:::

::: vease
- [Arrays](#tipos.arreglos)
- [For Each](#control.para-cada)
- [Copies, references and identity](#objetos.copia)
:::

---
id: tipos.arreglos
numero: "3.4"
tipo: tipo
titulo: Arrays
anclas: [LANG.TYPES.ARRAY#R1, LANG.ARRAY.DIMENSION#R1, LANG.ARRAY.ACCESS#R1]
fichas: [help.arrays, help.array-access]
diagnosticos: [arrayIndexOutOfRange, arrayDimensionCountMismatch, negativeArraySize, arrayCannotBeUsedAsValue, dimensionWithoutType]
terminos: [array, index, dimension]
---

::: frase
An array is a row (or a table) of boxes of the same type, with a fixed size and numbered from zero.
:::

## How to write it {#escribe}

```forma
Dimension «name»[«size»] As «type»
Dimension «name»[«rows», «columns»] As «type»
«name»[«index»] <- «value»
```

```railes produccion=dimensionDeclaration
```

## How it works {#funciona}

`Dimension` creates the array and its boxes at once. Each box is used like a variable: it is assigned a value and read with the name and the index in brackets. Indices start at **zero**: an array of size 3 has boxes 0, 1 and 2.

```figura id=arreglo-casillas
pie: An array of size 4 has boxes 0 to 3. Box 4 does not exist.
```

```programa id=notas titulo="The week's grades"
```

An array can have several **dimensions**. A table with 2 rows and 3 columns is declared with two sizes and each box is named with two indices inside the same brackets:

```programa id=tabla titulo="A small multiplication table"
```

## Dimensioning in two steps {#dos-pasos}

Classic pseudocode first declares the variable with `Define` and then dimensions it with `Dimension` without repeating the type. PseudoLearn accepts this if the variable is not used between the two statements.

## An array is not a value {#no-valor}

A whole array cannot be assigned, compared, written or returned. Only its boxes are values. To pass it whole to a subroutine an array parameter is used, which shares the boxes.

::: limite
- Indices: integers from 0 to size − 1 in each dimension.
- Size 0: valid (an array with no boxes). Negative size: `negativeArraySize`.
- Sizes are computed when running, so they can be expressions.
- There is no maximum fixed by the language; the limit is the memory available to the engine.
:::

::: errores
Going outside the array stops the program at that access:

```programa id=fuera titulo="The box that does not exist"
```

Using a number of indices different from the number of dimensions is detected before running:

```programa id=indices titulo="One index short"
```

And a whole array cannot be written:

```programa id=escribir-arreglo titulo="Writing the whole array"
```
:::

::: por-dentro
In the intermediate representation, accessing a box is an instruction that checks the index before reading or writing. If the index is out of range, the instruction produces the trap `arrayIndexOutOfRange` with the exact position of the access.

```ri programa=tabla
```
:::

::: nota
The classic mistake is going from 1 to N instead of 0 to N − 1. Write the `notas` loop with `For i <- 1 To 4` and look at the failure it produces: the message says which index and which size.
:::

::: resumen
- `Dimension` creates a fixed-size array of boxes of the same type.
- Indices go from 0 to size − 1; several indices go inside the same brackets.
- Going out of range is a runtime failure.
- A whole array is not a value: it is not assigned, compared or written.
:::

::: vease
- [Vectors](#tipos.vectores)
- [For](#control.para)
- [Parameters](#subprogramas.parametros)
:::

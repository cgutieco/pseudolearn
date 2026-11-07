---
id: declaraciones.definir
numero: "5.1"
tipo: construccion
titulo: "Declaring variables with `Define`"
anclas: [LANG.DECL.VARIABLE#R1]
fichas: [help.variables]
diagnosticos: [initializerWithMultipleNames, duplicateVariableDeclaration, bindingReadsOwnInitializer]
terminos: [variable, declaration, initial value]
---

::: frase
`Define` creates variables: named, typed boxes where the program keeps a value that can change.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=declaration
```

::: partes
- `Define` opens the declaration.
- «name» is an identifier. A single letter is valid too.
- `As` separates the names from the type.
- «type» says what kind of values it can hold: `Integer`, `Real`, `String`…
- `<-` and the «initial value» are optional, and only allowed with a single name.
- `;` ends the declaration.
:::

## How it works {#funciona}

A **variable** is a name bound to a place in memory. `Define` creates that place with the given type. With an initial value, the value is stored at once; without one, the box stays empty until the first assignment.

```programa id=mochila titulo="Variables in a backpack"
```

```figura id=cajas-variables
pie: Every `Define` creates a box with a name and a type. Those without an initial value start empty.
paso: `Define libros, cuadernos As Integer;` creates two empty boxes.
paso: `Define nombre As String <- "Leo";` creates a box that already has a value.
paso: `libros <- 3;` fills the first box.
paso: `cuadernos <- libros * 2;` reads `libros` and stores 6.
```

An empty box **has no default value**: it is not 0 nor `""`. Before running, the engine checks that a variable that may be empty is never read.

Every variable declared with `Define` can be changed later. For a value that never changes there is [`Constant`](#declaraciones.constante).

::: errores
The initial value is only valid with one name. With several, it is unclear which one it refers to:

```programa id=varios-nombres titulo="Initial value with two names"
```

A name can only be declared once in the same scope:

```programa id=repetido titulo="A name declared twice"
```
:::

::: por-dentro
Every local variable takes a numbered slot in the frame of its subprogram. In the intermediate representation, the declaration produces no instruction by itself: only the initial value produces a `store`.

```ri programa=mochila
```
:::

::: docentes
Ask the class to draw the boxes of `mochila` before running it. Whoever draws `cuadernos` with a 0 from the start is assuming a default value that does not exist.
:::

::: resumen
- `Define` creates one or more variables of a type.
- The initial value is optional and only valid with one name.
- Without an initial value, the variable starts empty, not at zero.
- A name is not repeated in the same scope.
:::

::: vease
- [Constants](#declaraciones.constante)
- [Assignment](#declaraciones.asignacion)
- [Variables without a value](#declaraciones.sin-valor)
:::

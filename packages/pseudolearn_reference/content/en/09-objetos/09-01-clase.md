---
id: objetos.clase
numero: "9.1"
tipo: construccion
titulo: "Classes and attributes"
anclas: [LANG.CLASS.DECLARATION#R1, LANG.CLASS.FIELDS#R1, LANG.TYPES.CLASS#R1]
fichas: [help.class]
diagnosticos: [duplicateMember, privateMemberAccess]
terminos: [class, object, attribute]
---

::: frase
A class is a mould: it describes what data every object keeps (its **attributes**) and what it can do (its **methods**).
:::

## How to write it {#escribe}

```forma
```

```railes produccion=classUnit
```

::: partes
- `Class` opens the declaration and «Name» is the name of the new type.
- `Inherits From` is optional and names a single [superclass](#objetos.herencia).
- Every attribute is declared with `Define`, without an initial value. It may be preceded by `Public` (the default) or `Private`.
- Then come the [methods](#objetos.metodos) and, at most, one [constructor](#objetos.constructor).
- `EndClass` closes the class.
:::

## How it works {#funciona}

A class is a sibling unit of the algorithm: it does not go inside it or inside another class. Its name is a new **type**, and every value of that type is an **object** created with [`New`](#objetos.constructor).

```programa id=puntos titulo="A class with two attributes"
```

```figura id=clase-objetos
pie: A class and two objects created from it. Each object has its own attributes.
```

Attributes start **without a value**: they accept no initializer. A `Private` attribute can only be used from the code of its own class.

Class-typed variables hold a **reference** to the object, not the object: assigning or passing by value copies the reference and both variables name the same object. Equality `=` between objects compares **identity**. There is no null value you can write.

::: errores
```programa id=espiar titulo="Reading a private attribute from outside"
```
:::

::: por-dentro
An object is a heap block with one cell per attribute. The access `p.x` becomes, in the intermediate representation, a field read or write by position.

```ri programa=puntos
```
:::

::: docentes
The "cookie cutter and cookie" pair works: one cutter, many cookies, each with its own decoration. It stops working when two variables share an object: they are not two cookies, they are two names for the same one.
:::

::: resumen
- A class declares attributes and methods; its name is a type.
- Attributes are declared with `Define` and start without a value.
- `Private` limits access to the class's code.
- Variables hold references; `=` compares identity.
:::

::: vease
- [Methods](#objetos.metodos)
- [Constructors and New](#objetos.constructor)
- [Copies and identity](#objetos.copia)
:::

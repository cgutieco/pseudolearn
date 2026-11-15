---
id: objetos.constructor
numero: "9.3"
tipo: construccion
titulo: "Constructors and `New`"
anclas: [LANG.CLASS.CONSTRUCTOR#R1, LANG.CLASS.INSTANTIATION#R1]
fichas: [help.constructor, help.instantiation]
diagnosticos: [variableUsedUninitialized, argumentCountMismatch]
terminos: [constructor, instance]
---

::: frase
`New` creates an object and runs its constructor, which prepares the attributes before anyone uses it.
:::

## How to write it {#escribe}

```forma
```

::: partes
- `Method Constructor` declares the constructor. It has no visibility or return type.
- Every class has **at most one**. If none is written, there is an implicit one without parameters that sets nothing.
- `New` followed by the class name and the arguments creates the object. The parentheses are required.
:::

## How it works {#funciona}

Declaring a class-typed variable **creates no object**: the variable stays without a value until it is assigned one created with `New`.

```figura id=nuevo-pasos
pie: What happens when `New Contador(10)` is evaluated.
paso: A new object is reserved with its attributes without a value.
paso: The constructor runs with `inicial` = 10, and `This.valor` receives 10.
paso: The reference to the object is stored in the variable.
```

```programa id=con-constructor titulo="A constructor that prepares the object"
```

If the class inherits, the superclass part is built before the constructor body. When the superclass constructor needs arguments, the first statement must be `Super.Constructor(…)`.

::: errores
A class variable without `New` has no object:

```programa id=sin-nuevo titulo="Using an object that was never created"
```
:::

::: por-dentro
`New` is a reservation instruction followed by a call to the constructor with the freshly created object as receiver.

```ri programa=con-constructor
```
:::

::: resumen
- `New Class(…)` creates an object and runs its constructor.
- There is at most one constructor; without it, an implicit one that initializes nothing.
- Declaring a class variable does not create the object.
- The superclass is built first.
:::

::: vease
- [Classes and attributes](#objetos.clase)
- [Inheritance and overriding](#objetos.herencia)
:::

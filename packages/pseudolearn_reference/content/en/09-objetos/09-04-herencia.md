---
id: objetos.herencia
numero: "9.4"
tipo: concepto
titulo: Inheritance and overriding
anclas: [LANG.CLASS.INHERITANCE#R1, LANG.CLASS.OVERRIDE#R1, LANG.CLASS.SELF-AND-SUPER#R1]
fichas: [help.inheritance]
diagnosticos: [incompatibleMethodOverride, circularInheritance, multipleInheritanceNotSupported, undeclaredSuperclass, inheritedAttributeShadowed, superInClassWithoutSuperclass]
terminos: [inheritance, superclass, subclass, dispatch]
---

::: frase
With `Inherits From`, a class receives the attributes and methods of another and can change how some of them behave.
:::

## How it works {#funciona}

A **subclass** inherits from **a single** superclass. Everything the superclass has, the subclass has too, and an object of the subclass works wherever one of the superclass is expected: a `Perro` is an `Animal`.

If the subclass declares a method with the same name and signature, it **overrides** it. Every call uses the method of the object's **real** class, not that of the variable's type. This is called **dispatch**.

```programa id=granja titulo="A method that changes in the subclass"
```

```figura id=herencia-despacho
pie: `Presentarse` lives in `Animal`, but `This.Sonido()` looks first in the object's real class: for Toby it finds the one in `Perro`.
```

`Super` calls the superclass version on the same object. It is only used inside a subclass, followed by a call.

::: limite
- Only single inheritance exists: one superclass per class.
- An override keeps the number and types of parameters, passing modes and return type. If anything changes, it is `incompatibleMethodOverride`, not overloading.
- A subclass cannot declare an attribute with the name of an inherited one.
:::

::: errores
```programa id=firma-distinta titulo="An override with a different signature"
```
:::

::: resumen
- `Inherits From` gives a class everything its superclass has.
- A method with the same signature overrides; every call uses the real class.
- `Super` calls the superclass version.
- Single inheritance and no signature changes.
:::

::: vease
- [Methods and This](#objetos.metodos)
- [Interfaces](#objetos.interfaces)
- [Relations between types](#tipos.relaciones)
:::

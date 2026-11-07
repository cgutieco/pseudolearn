---
id: objetos.metodos
numero: "9.2"
tipo: construccion
titulo: "Methods and `This`"
anclas: [LANG.CLASS.METHODS#R1, LANG.CLASS.SELF-AND-SUPER#R1, LANG.CLASS.MEMBER-ACCESS#R1]
fichas: [help.method, help.member-access, help.object-context]
diagnosticos: [identifierMatchesFieldWithoutThis, undeclaredVariable, privateMemberAccess]
terminos: [method, receiver, current object]
---

::: frase
A method is a subprogram that lives inside a class and works on a particular object: the one named before the dot.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=methodMember
```

::: partes
- `Method` opens the method. It may be preceded by `Public` (the default) or `Private`.
- «parameters» and `As` «type» follow the same rules as in a [subprogram](#subprogramas.declaracion).
- `EndMethod` closes the method.
:::

## How it works {#funciona}

A method is called on an object: `pasos.Sumar()`. That object is the **receiver**, and inside the method it is named with `This`. To use an attribute or method of the current object, `This.` is **required**: a bare name can only be a local variable or a parameter.

```programa id=contador titulo="A counter with state"
```

```figura id=receptor-este
pie: When calling `pasos.Sumar()`, `This` inside the method is the same object as `pasos`.
```

The dot can be chained: `New Contador(1).Actual()`. An attribute after the dot is a [designator](#declaraciones.designadores); a method call is not. The receiver is computed only once.

There is no overloading: two members of a class cannot share a name, even if one is an attribute and the other a method.

::: errores
```programa id=sin-este titulo="An attribute without This"
```
:::

::: por-dentro
A method is one more function of the intermediate representation with a hidden first parameter: the receiver. `pasos.Sumar()` becomes a call that passes `pasos` as that first argument.

```ri programa=contador
```
:::

::: resumen
- A method works on its receiver, the object before the dot.
- Inside, `This.` is required for the object's members.
- Methods can be public or private; there is no overloading.
:::

::: vease
- [Classes and attributes](#objetos.clase)
- [Inheritance and overriding](#objetos.herencia)
:::

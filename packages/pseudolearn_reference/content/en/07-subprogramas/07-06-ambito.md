---
id: subprogramas.ambito
numero: "7.6"
tipo: concepto
titulo: Scopes and names
anclas: [LANG.SUBPROGRAM.SCOPE#R1]
diagnosticos: [undeclaredVariable, bindingOutsideScope, bindingShadowsOuter]
terminos: [scope, binding, shadowing]
---

::: frase
Every name exists only inside its **scope**: from where it is declared to the end of the block that contains it.
:::

## How it works {#funciona}

PseudoLearn has no global variables. Every algorithm, subprogram and method has its own scope, and inside it every branch of `If` or `Switch` and every loop body opens a smaller scope.

```figura id=ambitos-anidados
pie: Scopes nest like boxes. From inside you can see what is outside; from outside you cannot see what is inside.
```

A subprogram does not see the variables of the algorithm that calls it. If it needs them, they must be passed as [parameters](#subprogramas.parametros):

```programa id=sin-globales titulo="A subprogram does not see another one's variables"
```

A variable declared inside a block stops existing when the block closes:

```programa id=fuera-ambito titulo="Using a variable outside its block"
```

Declaring inside a name that already exists outside is valid, but it **shadows** the outer one while the block lasts, and produces a warning:

```programa id=ocultar titulo="A name that shadows another"
```

::: nota
The names of subprograms and classes are registered before their bodies. That is why a subprogram can call another one declared further down, and two subprograms can call each other.
:::

::: resumen
- There are no global variables.
- A name lives from its declaration to the end of its block.
- Shadowing an outer name is valid, with a warning.
- Subprograms can be called in any order.
:::

::: vease
- [Parameters](#subprogramas.parametros)
- [Declaring variables with Define](#declaraciones.definir)
:::

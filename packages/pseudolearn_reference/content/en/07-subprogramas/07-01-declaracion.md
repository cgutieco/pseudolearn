---
id: subprogramas.declaracion
numero: "7.1"
tipo: construccion
titulo: "Declaring subprograms"
anclas: [LANG.SUBPROGRAM.DECLARATION#R1, LANG.SUBPROGRAM.INTERACTIONS#R1]
fichas: [help.subprogram]
diagnosticos: [subroutineWithoutReturn, returnVariableNotDeclared, duplicateSubroutine]
terminos: [subprogram, procedure, function]
---

::: frase
A subprogram is a named piece of program: it is written once and used as many times as needed.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=subprogram
```

::: partes
- `Subroutine` opens a subprogram. The parentheses are required even with no parameters.
- `As` «type» is optional: with it, the subprogram **returns** a value; without it, it only does things.
- `Function` declares a function with a **result variable**: the value «result» holds at the end is what is returned.
- `EndSubroutine` and `EndFunction` close each form.
:::

## How it works {#funciona}

Subprograms are declared **next to** the main algorithm, never inside it nor inside another subprogram. Order does not matter: you can call one that is written further down.

```programa id=saludar-doble titulo="A procedure and a function"
```

```figura id=subprograma-caja
pie: A subprogram seen from outside: the arguments go in, the result comes out. What happens inside is hidden.
```

The `Function` form is handy when the result is built up little by little. It has no `Return` with a value: it returns whatever its result variable holds.

```programa id=area titulo="Function with a result variable"
```

Inside a subprogram everything that works in the algorithm works too: declarations, `Read`, `Write`, decisions and loops. The variables it declares are **local**: nobody else sees them.

::: limite
- The return type can be a primitive or a class, never an array.
- A `Function` is [pure](#subprogramas.pureza): it cannot write, read or call anything that does.
:::

::: errores
A subprogram with a return type needs at least one `Return`:

```programa id=sin-retornar titulo="A return type without Return"
```
:::

::: por-dentro
Every subprogram is a function of the intermediate representation with its own blocks. A call is a `call` instruction that names the target function.

```ri programa=saludar-doble
```
:::

::: docentes
Before writing subprograms, ask the class to find two almost identical pieces in a long program. That is the first candidate for a subprogram.
:::

::: resumen
- `Subroutine` declares a subprogram; with `As` type it returns a value.
- `Function` returns what its result variable holds and is pure.
- They are declared next to the algorithm, in any order.
- Their variables are local.
:::

::: vease
- [Parameters](#subprogramas.parametros)
- [Calls](#subprogramas.llamada)
- [Return](#subprogramas.retornar)
:::

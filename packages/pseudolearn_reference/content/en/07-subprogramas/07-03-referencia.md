---
id: subprogramas.referencia
numero: "7.3"
tipo: concepto
titulo: Parameters by reference
anclas: [LANG.SUBPROGRAM.BY-REFERENCE#R1]
fichas: [help.parameter-mode]
diagnosticos: [byReferenceArgumentRequiresDesignator, variableUsedUninitialized]
terminos: [pass by reference, output parameter, alias]
---

::: frase
A `By Reference` parameter is another name for the caller's variable: whatever the subprogram does to it, it does to that variable.
:::

## How it works {#funciona}

Since the subprogram receives a variable and not a value, the argument must be a [designator](#declaraciones.designadores) of the **exact type**: a variable, a cell or an attribute. A literal or an operation will not do.

The typical use is returning **more than one result**:

```programa id=dividir-dos titulo="Two results by reference"
```

```figura id=referencia-salida
pie: `cociente` and `resto` have no box of their own: they are arrows to `c` and `r`. Assigning to them fills the caller's boxes.
```

`c` and `r` had no value before the call, and that is not an error: the engine sees that `Dividir` gives them a value **before reading them** on every path. Those parameters are **output** parameters. If the subprogram read the parameter before assigning it, the argument would have to arrive with a value.

::: limite
- The index of a cell passed by reference is computed only once, at the call. An invalid index fails before entering the subprogram.
- Two parameters may refer to the same variable; it is not forbidden.
- In recursive subprograms no parameter counts as an output parameter.
:::

::: errores
```programa id=referencia-literal titulo="A literal by reference"
```
:::

::: resumen
- `By Reference` shares the caller's variable.
- The argument must be a designator of the exact type.
- It is used to return several results.
- If the subprogram assigns before reading, the argument may arrive without a value.
:::

::: vease
- [Parameters](#subprogramas.parametros)
- [Designators](#declaraciones.designadores)
- [Variables without a value](#declaraciones.sin-valor)
:::

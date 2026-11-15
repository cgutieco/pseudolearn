---
id: subprogramas.parametros
numero: "7.2"
tipo: concepto
titulo: Parameters
anclas: [LANG.SUBPROGRAM.PARAMETERS#R1]
fichas: [help.parameter-mode, help.argument-list]
diagnosticos: [duplicateParameterName]
terminos: [parameter, argument, pass by value]
---

::: frase
Parameters are the input variables of a subprogram: on every call they receive a **copy** of the values passed to it.
:::

## How it works {#funciona}

Every parameter has a name and a required type. In the call, the **arguments** are assigned to the parameters in order. Without any mark, passing is **by value**: the parameter is a new variable with a copy of the argument, and changing it does not affect the caller.

```programa id=copia-parametro titulo="The parameter is a copy"
```

```figura id=paso-valor
pie: By value, the subprogram gets its own box with a copy. By reference, its parameter is another name for the caller's box.
paso: `Copia(x)` creates a new box `n` with a copied 5. Changing it leaves `x` as it was.
paso: `Incrementar(x)` creates no box: `n` points to the box of `x`, and adding 1 changes `x`.
```

| Mark | What the subprogram receives |
|---|---|
| none or `By Value` | a copy of the value |
| `By Reference` | the variable itself |

The mark goes **after the type** and only affects that parameter. Arrays are always passed by reference: marking them `By Value` is an error.

::: resumen
- Every parameter has a name and a type.
- By default a copy is passed: changing it does not affect the outside.
- `By Reference` shares the caller's variable.
- Arrays always go by reference.
:::

::: vease
- [Parameters by reference](#subprogramas.referencia)
- [Calls](#subprogramas.llamada)
:::

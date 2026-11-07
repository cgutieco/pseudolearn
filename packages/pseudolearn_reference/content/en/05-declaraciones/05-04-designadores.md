---
id: declaraciones.designadores
numero: "5.4"
tipo: concepto
titulo: Designators
anclas: [LANG.DECL.DESIGNATOR#R1]
diagnosticos: [invalidAssignmentTarget, invalidReadTarget]
terminos: [designator]
---

::: frase
A designator is something that names a place where a value can be stored: a variable, an array cell or an attribute of an object.
:::

## How it works {#funciona}

Not everything that can be read can be written. `x + 1` has a value, but it is not a place: there is nowhere to store anything. Statements that store values —assignment, `Read` and passing by reference— require a **designator**.

```figura id=designadores
pie: On the left, designators: they name a place. On the right, expressions that only have a value.
```

| Is a designator | Is not a designator |
|---|---|
| `x` | `5` |
| `notas[i]` | `x + 1` |
| `persona.nombre` | `Longitud(t)` |
| `tabla[i, j]` | `(x)` |

The indices and the receiver of a designator are evaluated **only once**, before storing:

```programa id=designadores titulo="Cells as targets"
```

In `notas[i + 1]` the index is any expression, but `notas[…]` as a whole still names a place.

::: errores
```programa id=leer-literal titulo="Reading into a number"
```
:::

::: resumen
- A designator names a place: variable, cell or attribute.
- Assigning, `Read` and passing by reference require a designator.
- Literals, operations, calls and parentheses are not designators.
:::

::: vease
- [Assignment](#declaraciones.asignacion)
- [Arrays](#tipos.arreglos)
- [Parameters by reference](#subprogramas.referencia)
:::

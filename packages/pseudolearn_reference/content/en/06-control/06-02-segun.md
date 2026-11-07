---
id: control.segun
numero: "6.2"
tipo: construccion
titulo: "Multiple selection with `Switch`"
anclas: [LANG.CONTROL.SWITCH#R1, LANG.CONTROL.SWITCH#R2]
fichas: [help.switch]
diagnosticos: [nonExhaustiveSwitch, duplicateSwitchCaseLabel, incompatibleSwitchCaseType, unreachableSwitchPattern]
terminos: [selector, label, exhaustiveness]
---

::: frase
`Switch` looks at a value only once and jumps straight to the branch whose label matches.
:::

## How to write it {#escribe}

```forma
```

```railes produccion=switch
```

::: partes
- `Switch` opens the selection and «selector» is the value being looked at: an integer, an enumeration or a variant.
- `Do` separates the selector from the branches.
- Each branch starts with one or more «labels» separated by commas and ends its header with `:`.
- `Otherwise:` is optional, unique and goes last. It collects whatever matches no label.
- `EndSwitch` closes the selection.
:::

## How it works {#funciona}

The selector is computed **once**. Then the branch with that label is found, run, and the selection ends: there is no "fall-through" to the next branch. If none matches and there is no `Otherwise`, nothing is done.

```programa id=dia-semana titulo="Is there school today?"
```

```figura id=segun-ramas
pie: The selector is 6, so the engine jumps to the branch holding that label. The others are not even looked at.
paso: The selector is computed only once: `dia` is 6.
paso: 6 is in the second branch: its `Write` runs.
paso: When the branch ends the `Switch` is left, without going through the others.
```

Labels are **integer literals** (signed if needed) or **members of an enumeration**. Reals, characters, texts and booleans are not valid selectors. A label cannot be repeated.

## With enumerations {#enumerados}

If the selector is an enumeration, the branches must cover **all** its members, or include `Otherwise`. That way the engine warns you when a new member is added and nobody handles it.

```programa id=cruce titulo="An incomplete traffic light"
```

The message names the missing members, in the order they were declared. `Switch` also opens variants such as `Optional` and `Result`: that is explained in [Optional and Result](#tipos.opcional-resultado).

::: errores
```programa id=etiqueta-repetida titulo="A repeated label"
```

```programa id=segun-texto titulo="A text selector"
```
:::

::: por-dentro
The selector is kept in a temporary and every branch is a comparison with a jump. Since there is no fall-through, each branch ends with a direct jump to the block after `EndSwitch`.

```ri programa=dia-semana
```
:::

::: docentes
`Switch` and a chain of nested `If`s do the same with concrete values. Ask the class to rewrite `dia-semana` with `If` and compare which reads better and which catches an omission sooner.
:::

::: resumen
- `Switch` computes the selector once and runs a single branch.
- Labels: integers or enumeration members, never repeated.
- No fall-through between branches; `Otherwise` is optional.
- With enumerations, the branches must cover every member.
:::

::: vease
- [The If decision](#control.si)
- [Enumerations](#tipos.enumerados)
- [Optional and Result](#tipos.opcional-resultado)
:::

---
id: tipos.variantes
numero: "3.9"
tipo: tipo
titulo: Variants
anclas: [LANG.TYPES.VARIANT]
fichas: [help.pgl04.variant, help.pgl04.variant_alternative]
diagnosticos: [nonExhaustiveSwitch, variantWithoutAlternatives, duplicateMember]
terminos: [variant, alternative, pattern]
---

::: frase
A variant is a type whose values can take several different shapes, each with its own data, like a figure that can be a circle or a rectangle.
:::

## How to write it {#escribe}

```forma
variant «Name»
  case «shape»(«field» As «type», …)
  case «shape»
endVariant
```

## How it works {#funciona}

Each **alternative** is one possible shape of the value. An alternative may carry fields or none. A value is built with the variant's name, a dot and the alternative: `Forma.Circulo(2)`.

To find out which shape a value has, `Switch` is used with **patterns**: each branch names an alternative and gives names to its fields, which only exist inside that branch.

```programa id=areas titulo="The area of each figure"
```

```figura id=variante-formas
pie: A variant is a box with several possible shapes. `Switch` looks at which shape it has and unpacks its fields.
```

`Switch` must cover **all** the alternatives or have `Otherwise`. That way, if a new alternative is added tomorrow, the engine points out every `Switch` that falls short.

```programa id=incompleto titulo="A shape is forgotten"
```

::: limite
- A variant needs at least one alternative.
- Alternative names are unique within the variant, and field names within each alternative.
- A variant is a value: it is copied like a record.
:::

::: errores
A variant without alternatives has no possible value:

```programa id=sin-alternativas titulo="An empty variant"
```
:::

::: por-dentro
A variant value stores a tag with the alternative followed by that alternative's fields. `Switch` reads the tag and jumps straight to the matching branch.

```ri programa=areas
```
:::

::: resumen
- A variant has several alternatives, each with its fields.
- It is built with `Variant.Alternative(…)`.
- It is queried with `Switch` and patterns that unpack the fields.
- `Switch` must cover every alternative.
:::

::: vease
- [Optional and Result](#tipos.opcional-resultado)
- [Enumerations](#tipos.enumerados)
- [Switch](#control.segun)
:::

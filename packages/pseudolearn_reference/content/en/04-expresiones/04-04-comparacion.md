---
id: expresiones.comparacion
numero: "4.4"
tipo: concepto
titulo: Comparison
anclas: [LANG.OPS.COMPARISON#R1]
fichas: [help.comparison]
diagnosticos: [realEqualityComparison, noOrderBetweenBooleans]
terminos: [comparison, equality, order]
---

::: frase
Comparison operators ask something about two values and answer with a `Boolean`: `True` or `False`.
:::

## How it works {#funciona}

| Operator | Question |
|---|---|
| `=` | are they equal? |
| `<>` | are they different? |
| `<` `<=` | is it less? less or equal? |
| `>` `>=` | is it greater? greater or equal? |

What can be compared:

- **Numbers**: equality and order. An integer is widened to real when compared with a real.
- **Texts and characters**: equality and order, character by character by their Unicode code.
- **Booleans**: only equality, no order.
- **Enumerations and records of the same type**: only equality.
- **Objects**: identity equality (whether they are the same object).

```programa id=comparar titulo="Comparing different types"
```

```figura id=orden-texto
pie: Texts are compared character by character by their code. All upper-case letters have a lower code than lower-case ones.
```

The result of `"Zeta" < "alfa"` is surprising: upper-case Z has a lower code than lower-case a. The order of texts is not dictionary order.

::: nota
Comparing two reals with `=` works, but produces the warning `realEqualityComparison`: two calculations that should match may differ in the last decimal.
:::

::: resumen
- Comparisons return a `Boolean`.
- Numbers and texts allow equality and order; booleans, enumerations and records only equality.
- Texts are ordered by Unicode code, not like in a dictionary.
:::

::: vease
- [Logical operators](#expresiones.logicos)
- [Primitive types](#tipos.primitivos)
:::

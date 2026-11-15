---
id: expresiones.precedencia
numero: "4.7"
tipo: concepto
titulo: Precedence and associativity
anclas: [LANG.OPS.PRECEDENCE#R1]
diagnosticos: [incompatibleOperandTypes]
terminos: [precedence, associativity, parentheses]
---

::: frase
When an expression has several operators, precedence decides which applies first: `2 + 3 * 4` is 14, not 20.
:::

## How it works {#funciona}

Every operator has a **level**. Higher levels grab their operands first. From strongest to weakest:

```figura id=escalera-precedencia
pie: The precedence levels, from the one that binds tightest (top) to the one that binds loosest (bottom).
```

When two operators of the same level follow each other, **associativity** decides. Almost all associate to the left: `10 - 4 - 3` is `(10 - 4) - 3`, which is 3. Unary operators and power associate to the right.

```programa id=precedencia titulo="Who goes first"
```

In the second line, the arithmetic is computed first, then the comparisons and finally `And` and `Or`. That is why conditions read naturally without parentheses.

```figura id=arbol-precedencia
pie: How `2 + 3 * 4` is grouped. The product sits lower in the tree because it is computed first.
paso: The expression as written.
paso: `*` has a higher level than `+`, so `3 * 4` is grouped first.
paso: The product is computed: 12.
paso: The addition remains: 2 + 12 = 14.
```

::: nota
Parentheses always win. If in doubt, add them: `(a + b) / 2` makes your intent clear and costs nothing.
:::

::: limite
Two places where precedence surprises:

- The sign binds tighter than power: `-2 ^ 2` is 4.
- `Not` binds tighter than comparisons: write `Not (a = b)` or, better, `a <> b`.
:::

::: resumen
- First postfix, then unary, power, product, sum, order, equality, `And` and `Or`.
- At the same level grouping is to the left, except unary and power.
- Parentheses change the order.
:::

::: vease
- [Arithmetic operators](#expresiones.aritmeticos)
- [Power](#expresiones.potencia)
- [Logical operators](#expresiones.logicos)
:::

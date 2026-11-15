---
id: expresiones.logicos
numero: "4.5"
tipo: concepto
titulo: Logical operators
anclas: [LANG.OPS.LOGICAL#R1]
fichas: [help.logical]
diagnosticos: [incompatibleOperandTypes]
terminos: [short circuit, conjunction, disjunction, negation]
---

::: frase
`And`, `Or` and `Not` combine boolean answers: `And` needs both to be true, `Or` is happy with one and `Not` turns the answer around.
:::

## How it works {#funciona}

The three operators only accept `Boolean` values and return a `Boolean`.

| `a` | `b` | `a And b` | `a Or b` | `Not a` |
|---|---|---|---|---|
| `True` | `True` | `True` | `True` | `False` |
| `True` | `False` | `False` | `True` | `False` |
| `False` | `True` | `False` | `True` | `True` |
| `False` | `False` | `False` | `False` | `True` |

```programa id=logica titulo="Combining conditions"
```

## Short circuit {#cortocircuito}

`And` and `Or` evaluate the left part first. If that is enough to know the answer, **the right part is not computed**:

- `False And …` is always `False`.
- `True Or …` is always `True`.

```figura id=cortocircuito
pie: With `And`, a false left side decides without looking at the right. With `Or`, a true left side does.
```

```programa id=cortocircuito titulo="The right side that is never computed"
```

The division by zero is there, but it never runs, so it does not stop the program. The short circuit suppresses the effects and failures of the right side; what it does not suppress is type checking: the right side must be a valid `Boolean` even when it is not computed.

::: limite
- `1 And True` is rejected before running: numbers are not boolean answers.
- `Not` binds tighter than comparisons: `Not 1 = 2` tries to negate the 1. Write `Not (1 = 2)`.
:::

::: resumen
- `And` needs both true; `Or`, at least one; `Not` inverts.
- They only accept `Boolean`.
- The right side of `And` and `Or` is only computed when needed.
:::

::: vease
- [Comparison](#expresiones.comparacion)
- [Precedence and associativity](#expresiones.precedencia)
- [The If decision](#control.si)
:::

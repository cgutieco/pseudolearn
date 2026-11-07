---
id: tipos.opcional-resultado
numero: "3.10"
tipo: tipo
titulo: "`Optional` and `Result`"
anclas: [LANG.TYPES.RELATIONS#R2, LANG.TYPES.RELATIONS#R3, LANG.TYPES.RELATIONS#R4, LANG.TYPES.RELATIONS#R5]
fichas: [help.variants]
diagnosticos: [resultNotHandled, incompatiblePropagationType, incompatibleVariantConstructor, ambiguousVariantType]
terminos: [Optional, Result, propagate, discard]
---

::: frase
`Optional` represents a value that may be missing and `Result` an operation that may go well or badly; both force you to look at the bad case before using the value.
:::

## How to write it {#escribe}

```forma
Define «name» As Optional<«type»> <- Some(«value»);
Define «name» As Optional<«type»> <- None;
Define «name» As Result<«type», «error type»> <- Success(«value»);
Define «name» As Result<«type», «error type»> <- Failure(«error»);
```

## How it works {#funciona}

They are two built-in variants:

- `Optional<T>` has two shapes: `Some(value)` when there is a value and `None` when it is missing.
- `Result<T, E>` has two shapes: `Success(value)` when the operation went well and `Failure(error)` when it did not.

Like any variant, they are queried with `Switch`. There is no way to "take the value out and hope it is there": the program has to decide what to do in both cases.

```programa id=dividir titulo="A division that may fail"
```

```figura id=opcional-resultado
pie: Two boxes that may or may not be full. To open them, both possibilities must be considered.
```

## Propagate {#propagar}

Inside a subroutine that also returns `Result` (or `Optional`), `Propagate` avoids writing a `Switch` for every call: if the value is `Success`, it gives its content; if it is `Failure`, it ends the subroutine returning that same error.

```programa id=propagar titulo="Passing the error upwards"
```

`Discard` makes it clear that you ignore a `Result` on purpose: `Discard dividir(4, 2);`.

::: limite
- `Optional<Optional<T>>` tells `None` apart from `Some(None)`.
- `Propagate` only works inside a subroutine whose return type matches (`Optional`, or `Result` with the same error type).
- A `Result` ignored without `Discard` is an error: `resultNotHandled`.
- A `Result` is not written, compared or passed by reference.
:::

::: errores
Calling a function that returns `Result` and doing nothing with it is detected before running:

```programa id=sin-tratar titulo="A forgotten result"
```
:::

::: por-dentro
`Propagate` becomes a tag check followed by an early return. Before leaving, the engine runs any pending `defer` clean-ups, in reverse order.

```ri programa=propagar
```
:::

::: resumen
- `Optional<T>`: `Some(value)` or `None`.
- `Result<T, E>`: `Success(value)` or `Failure(error)`.
- They are queried with `Switch`; there is no shortcut that ignores the bad case.
- `Propagate` returns the error upwards; `Discard` ignores it on purpose.
:::

::: vease
- [Variants](#tipos.variantes)
- [Defer](#control.diferir)
- [Effect order and the tape](#motor.efectos)
:::

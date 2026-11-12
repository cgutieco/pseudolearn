---
id: control.salir
numero: "6.7"
tipo: construccion
titulo: "Leaving a loop"
anclas: [LANG.CONTROL.EXIT#R1]
fichas: [construction.break]
diagnosticos: [breakOutsideLoop]
terminos: [early exit]
---

::: frase
`Exit` ends the loop that contains it on the spot, even if its condition would still allow it to go on.
:::

## How to write it {#escribe}

```forma
```

::: partes
- `Exit` is a simple statement and ends with `;`.
- It is only valid inside `While`, `Repeat`, `For` or `For Each`.
:::

## How it works {#funciona}

`Exit` leaves the **innermost** loop that contains it and the program continues after its closing word. It is useful when searching: as soon as the thing appears, there is no need to keep looking.

```programa id=primero-mayor titulo="Finding the first one that fits"
```

```figura id=salir-corte
pie: `Exit` cuts the loop on the third round. Cells 28 and 35 are never visited.
```

If the loop has cleanups registered with [`Defer`](#control.diferir), they run on exit. There is no word for "skip to the next round".

::: errores
```programa id=salir-fuera titulo="Exit outside a loop"
```
:::

::: por-dentro
`Exit` is a direct jump to the block after the loop. In the intermediate representation it shows up as a `jump` inside the block of the true branch.

```ri programa=primero-mayor
```
:::

::: resumen
- `Exit` ends the innermost loop.
- It is only valid inside a loop.
- It runs the pending cleanups of the loop.
:::

::: vease
- [For Each](#control.para-cada)
- [Defer](#control.diferir)
- [Return](#subprogramas.retornar)
:::

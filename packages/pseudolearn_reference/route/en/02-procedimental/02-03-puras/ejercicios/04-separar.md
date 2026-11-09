---
id: procedimental.puras.separar
leccion: procedimental.puras
tipo: modificar
nivel: brote
obligatorio: true
titulo: Separating the calculation
---

::: enunciado
This program asks for a price and shows the price with 21 % VAT, all inside the same piece. Rewrite it so that the calculation goes in a piece that only computes, without changing what it shows.
:::

::: restriccion
The calculation goes in a `Function ConIva` that receives the price; the main algorithm reads and shows.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | ConIva | 1 | The piece ConIva, which receives the price and returns the price with VAT, is missing.
```

::: pistas
1. Mark which lines ask, which ones show and which ones compute.
2. It is the same fix as the discounted price in [the lesson](ruta:procedimental.puras).
3. The new piece receives the price and returns the result; the main algorithm does the reading and the writing.
4. `Function total <- ConIva(precio As Integer)` with the calculation inside, and the main algorithm reads, calls and shows. Close with the variant.
:::

::: variante
Use `ConIva` to show the total with VAT of two products read.
:::

::: explicacion
The assertion checks that `ConIva` exists with one parameter; that it is a `Function`, and therefore pure, is checked by the engine itself when compiling it. The cases are those of the initial program: what is shown does not change.
:::

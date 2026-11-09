---
id: objetos.contratos.figuras-area
leccion: objetos.contratos
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The area of any figure
---

::: enunciado
Read the type of figure (`rectangulo`, `cuadrado` or `triangulo`) and its measurements: length and width, side, or base and height of a right-angled triangle. Show the area.
:::

::: restriccion
A contract `Figura` with a method `Area()`, one class per figure that meets it and a single piece that computes the area of any of them.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | AreaDe | 1 | The piece AreaDe, which receives any figure, is missing.
```

::: pistas
1. What do the three figures have in common? What changes between them?
2. It is the till of [the lesson](ruta:objetos.contratos): the contract is `Figura` and the shared piece is like `CobrarCon`.
3. An interface with `Area()`, three classes that implement it and `AreaDe<T: Figura>` that calls `Area()`.
4. The main algorithm reads the type, creates the matching figure and shows its `AreaDe`. Close with the variant.
:::

::: variante
Add the circle, with area 3.14 times the radius squared. Which pieces change?
:::

::: explicacion
Hidden cases: a triangle with a non-whole area, measurements of 0 and a triangle with a whole area. Frequent mistake: computing the area in the main algorithm with a decision per figure, which does not use the contract.
:::

---
id: procedimental.dividir.area
leccion: procedimental.dividir
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The area of the rectangle
---

::: enunciado
Read the length and the width of a rectangle and show its area. The program shows only the number.
:::

::: restriccion
The calculation goes in a subprogram `AreaRectangulo` that receives the length and the width.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | AreaRectangulo | 2 | The calculation goes in a subprogram AreaRectangulo with two parameters.
```

::: pistas
1. Which data does the calculation need? Those are the parameters.
2. Look at how `Doble` is written in [the lesson](ruta:procedimental.dividir).
3. The subprogram returns the area; the main algorithm reads and shows.
4. `SubProcess AreaRectangulo(largo As Integer, ancho As Integer) As Integer` with `Return largo * ancho;`. Close with the variant.
:::

::: variante
Add a subprogram `PerimetroRectangulo` and also show the perimeter.
:::

::: docentes
The assertion checks that `AreaRectangulo` exists with two parameters. Frequent mistake: reading the data inside the subprogram, which then receives nothing.
:::

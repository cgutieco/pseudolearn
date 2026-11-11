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
The calculation goes in a subprogram `RectangleArea` that receives the length and the width.
:::

```programa rol=referencia
SubProceso RectangleArea(rectLength Como Entero, width Como Entero) Como Entero
  Retornar rectLength * width;
FinSubProceso

Algoritmo Area
  Definir rectLength, width Como Entero;
  Leer rectLength;
  Leer width;
  Escribir RectangleArea(rectLength, width);
FinAlgoritmo
```

```casos
visible | 3 ; 4 | 12
visible | 5 ; 5 | 25
oculto | 0 ; 9 | 0
oculto | 1 ; 1 | 1
oculto | 10 ; 7 | 70
```

```aserciones
- declara-subprograma | RectangleArea | 2 | The calculation goes in a subprogram RectangleArea with two parameters.
```

::: pistas
1. Which data does the calculation need? Those are the parameters.
2. Look at how `Double` is written in [the lesson](ruta:procedimental.dividir).
3. The subprogram returns the area; the main algorithm reads and shows.
4. `SubProcess RectangleArea(rectLength As Integer, width As Integer) As Integer` with `Return rectLength * width;`. Close with the variant.
:::

::: variante
Add a subprogram `RectanglePerimeter` and also show the perimeter.
:::

::: explicacion
The assertion checks that `RectangleArea` exists with two parameters. Common mistake: reading the data inside the subprogram, which then receives nothing.
:::

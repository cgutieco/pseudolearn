---
id: objetos.contratos.figuras-area
leccion: objetos.contratos
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The area of any figure
---

::: enunciado
Read the type of figure (`rectangle`, `square` or `triangle`) and its measurements: length and width, side, or base and height of a right-angled triangle. Show the area.
:::

::: restriccion
A contract `Shape` with a method `Area()`, one class per figure that meets it and a single piece that computes the area of any of them.
:::

```programa rol=referencia
Interfaz Shape
  Metodo Area() Como Real;
FinInterfaz

Clase Rectangle Realiza Shape
  Definir rectLength, width Como Real;
  Metodo Constructor(l Como Real, a Como Real)
    Este.rectLength <- l;
    Este.width <- a;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.rectLength * Este.width;
  FinMetodo
FinClase

Clase Square Realiza Shape
  Definir side Como Real;
  Metodo Constructor(l Como Real)
    Este.side <- l;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.side * Este.side;
  FinMetodo
FinClase

Clase Triangle Realiza Shape
  Definir base, height Como Real;
  Metodo Constructor(b Como Real, a Como Real)
    Este.base <- b;
    Este.height <- a;
  FinMetodo
  Metodo Area() Como Real
    Retornar Este.base * Este.height / 2;
  FinMetodo
FinClase

SubProceso AreaOf<T: Shape>(shape Como T) Como Real
  Retornar shape.Area();
FinSubProceso

Algoritmo Shapes
  Definir tipo Como Cadena;
  Definir sizeOne, sizeTwo Como Real;
  Leer tipo;
  Si tipo = "square" Entonces
    Leer sizeOne;
    Escribir AreaOf(Nuevo Square(sizeOne));
  Sino
    Leer sizeOne;
    Leer sizeTwo;
    Si tipo = "rectangle" Entonces
      Escribir AreaOf(Nuevo Rectangle(sizeOne, sizeTwo));
    Sino
      Escribir AreaOf(Nuevo Triangle(sizeOne, sizeTwo));
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | rectangle ; 3 ; 4 | 12.0
visible | square ; 5 | 25.0
oculto | triangle ; 3 ; 5 | 7.5
oculto | rectangle ; 0 ; 9 | 0.0
oculto | square ; 0 | 0.0
oculto | triangle ; 4 ; 4 | 8.0
```

```aserciones
- declara-subprograma | AreaOf | 1 | The piece AreaOf, which receives any figure, is missing.
```

::: pistas
1. What do the three figures have in common? What changes between them?
2. It is the till of [the lesson](ruta:objetos.contratos): the contract is `Shape` and the shared piece is like `ChargeWith`.
3. An interface with `Area()`, three classes that implement it and `AreaOf<T: Shape>` that calls `Area()`.
4. The main algorithm reads the type, creates the matching figure and shows its `AreaOf`. Close with the variant.
:::

::: variante
Add the circle, with area 3.14 times the radius squared. Which pieces change?
:::

::: explicacion
Hidden cases: a triangle with a non-whole area, measurements of 0 and a triangle with a whole area. Frequent mistake: computing the area in the main algorithm with a decision per figure, which does not use the contract.
:::

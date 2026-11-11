---
id: procedimental.puras.es-bisiesto
leccion: procedimental.puras
tipo: resolver
nivel: brote
obligatorio: false
titulo: Leap year, as a function
---

::: enunciado
Read a year and show «Leap year» or «Not a leap year». The rule is the one from [lesson 1.2](ruta:imperativo.caminos).
:::

::: restriccion
The decision goes in a `Function IsLeapYear` that receives the year and returns a boolean value.
:::

```programa rol=referencia
Funcion leap <- IsLeapYear(year Como Entero)
  Definir leap Como Logico;
  leap <- (year mod 4 = 0 Y year mod 100 <> 0) O year mod 400 = 0;
FinFuncion

Algoritmo Main
  Definir year Como Entero;
  Leer year;
  Si IsLeapYear(year) Entonces
    Escribir "Leap year";
  Sino
    Escribir "Not a leap year";
  FinSi
FinAlgoritmo
```

```casos
visible | 2024 | Leap year
visible | 2023 | Not a leap year
oculto | 1900 | Not a leap year
oculto | 2000 | Leap year
oculto | 2100 | Not a leap year
```

```aserciones
- declara-subprograma | IsLeapYear | 1 | The function IsLeapYear, which receives the year, is missing.
```

::: pistas
1. What goes into the piece and what comes out? What type does what comes out have?
2. The condition is the one from [lesson 1.2](ruta:imperativo.caminos); here it goes inside a function.
3. The function returns true or false; the main algorithm decides what to show.
4. The result box is `Boolean` and keeps the compound condition. Close with the variant.
:::

::: variante
Write `DaysInYear(year)`, which returns 366 or 365 using `IsLeapYear`.
:::

::: explicacion
Hidden cases: the two exceptions and 2100. Common mistake: showing the text inside the function, which the engine rejects.
:::

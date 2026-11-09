---
id: procedimental.puras.es-bisiesto
leccion: procedimental.puras
tipo: resolver
nivel: brote
obligatorio: false
titulo: Leap year, as a function
---

::: enunciado
Read a year and show «Es bisiesto» or «No es bisiesto». The rule is the one from [lesson 1.2](ruta:imperativo.caminos).
:::

::: restriccion
The decision goes in a `Function EsBisiesto` that receives the year and returns a boolean value.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | EsBisiesto | 1 | The function EsBisiesto, which receives the year, is missing.
```

::: pistas
1. What goes into the piece and what comes out? What type does what comes out have?
2. The condition is the one from [lesson 1.2](ruta:imperativo.caminos); here it goes inside a function.
3. The function returns true or false; the main algorithm decides what to show.
4. The result box is `Boolean` and keeps the compound condition. Close with the variant.
:::

::: variante
Write `DiasDelAnio(anio)`, which returns 366 or 365 using `EsBisiesto`.
:::

::: explicacion
Hidden cases: the two exceptions and 2100. Frequent mistake: showing the text inside the function, which the engine rejects.
:::

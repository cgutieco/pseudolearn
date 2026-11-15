---
id: funcional.clausuras.multiplicador
leccion: funcional.clausuras
tipo: resolver
nivel: brote
obligatorio: true
titulo: A manufactured multiplier
---

::: enunciado
Read a factor and then numbers until a 0. Show each number multiplied by the factor, one per line.
:::

::: restriccion
A factory `MakeMultiplier(factor)` that gives back the function that multiplies.
:::

```programa rol=referencia
Funcion made <- MakeMultiplier(factor Como Entero)
  Definir made Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x * factor;
  FinFuncion;
FinFuncion

Algoritmo Multiply
  Definir factor, number Como Entero;
  Leer factor;
  Definir multiply Como Funcion(Entero) Como Entero <- MakeMultiplier(factor);
  Leer number;
  Mientras number <> 0 Hacer
    Escribir multiply(number);
    Leer number;
  FinMientras
FinAlgoritmo
```

```casos
```

```aserciones
- declara-subprograma | MakeMultiplier | 1 | The factory MakeMultiplier, which receives the factor, is missing.
```

::: pistas
1. Which value does the multiplying function have to remember?
2. It is the adder of [the lesson](ruta:funcional.clausuras), with another operation.
3. The factory receives the factor and gives back a one-number function that uses it.
4. Make the function once, before the loop, and apply it to each number read. Close with the variant.
:::

::: variante
Make two multipliers and show each number times both.
:::

::: explicacion
Hidden cases: factor 0 and factor -1. Frequent mistake: making the function inside the loop, which works but repeats work.
:::

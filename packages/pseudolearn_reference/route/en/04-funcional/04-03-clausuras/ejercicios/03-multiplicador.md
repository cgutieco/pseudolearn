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
A factory `CrearMultiplicador(factor)` that gives back the function that multiplies.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | CrearMultiplicador | 1 | The factory CrearMultiplicador, which receives the factor, is missing.
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

::: docentes
Hidden cases: factor 0 and factor -1. Frequent mistake: making the function inside the loop, which works but repeats work.
:::

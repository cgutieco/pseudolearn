---
id: inicio.nombres.cronometro
leccion: inicio.nombres
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The stopwatch
---

::: enunciado
The race stopwatch shows 3725 seconds. Show it as `1 h 2 min 5 s`, computing each number from the seconds.
:::

```programa rol=inicial
Algoritmo Stopwatch
  Definir seconds Como Entero <- 3725;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Stopwatch
  Definir seconds Como Entero <- 3725;
  Definir hours Como Entero <- seconds div 3600;
  Definir minutes Como Entero <- seconds mod 3600 div 60;
  Escribir hours, " h ", minutes, " min ", seconds mod 60, " s";
FinAlgoritmo
```

```casos
visible | — | 1 h 2 min 5 s
```

::: pistas
1. By hand: how many seconds are there in an hour? And in a minute? How many full hours fit in 3725 seconds?
2. It is sharing out in two stages, like the sweets in [the lesson](ruta:inicio.nombres): first into hours, and what is left, into minutes.
3. Keep the hours and the minutes in boxes with a name before showing them.
4. `hours <- seconds div 3600`, `minutes <- seconds mod 3600 div 60` and the seconds are `seconds mod 60`. Close with the variant.
:::

::: variante
With 90061 seconds you also have to count the days: `1 d 1 h 1 min 1 s`.
:::

::: explicacion
Solution: 3725 seconds hold 1 hour with 125 left over; 125 hold 2 minutes with 5 seconds left over. Frequent mistake: computing the minutes as `seconds div 60`, which gives 62.
:::

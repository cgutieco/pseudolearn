---
id: inicio.preguntar.bici
leccion: inicio.preguntar
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Cycling to school
---

::: enunciado
Read the distance in kilometres and the speed in kilometres per hour, in that order, and show how many minutes the trip takes, rounding up. The program shows only the number.
:::

```programa rol=referencia
Algoritmo Bike
  Definir distance Como Entero;
  Definir speed Como Entero;
  Leer distance;
  Leer speed;
  Escribir techo(distance * 60 / speed);
FinAlgoritmo
```

```casos
visible | 10 ; 15 | 40
visible | 7 ; 20 | 21
oculto | 3 ; 9 | 20
oculto | 1 ; 7 | 9
oculto | 5 ; 12 | 25
```

::: pistas
1. By hand: 10 kilometres at 15 per hour, how many hours is that? And how many minutes?
2. An hour has 60 minutes. Fill in the card with that relation.
3. Convert to minutes before dividing and round at the end, with the built-in function from [the first lesson](ruta:inicio.primer-problema).
4. `Write ceil(distance * 60 / speed);`. Close with the variant.
:::

::: variante
Show the result as hours and minutes: with 25 kilometres at 15 per hour, `1 h 40 min`.
:::

::: explicacion
Frequent mistake: dividing first and multiplying by 60 afterwards, which gives the same here but piles up decimals. Another: rounding the hours before converting to minutes.
:::

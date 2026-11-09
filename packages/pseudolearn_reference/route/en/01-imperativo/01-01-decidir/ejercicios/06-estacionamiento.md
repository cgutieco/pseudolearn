---
id: imperativo.decidir.estacionamiento
leccion: imperativo.decidir
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The car park
---

::: enunciado
The car park charges 3 pesos for the first hour and 2 pesos for each extra hour or part of an hour. Less than an hour is charged as one. Read the minutes and show the price. The program shows only the number.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Build the partition: where does the way of charging change? Do worked examples on both sides of that edge.
2. 150 minutes are one hour and 90 minutes more. How many hours or parts of an hour are those 90?
3. First decide whether the first hour has passed. If it has, round up the hours that follow.
4. If the minutes are not over 60, charge 3; otherwise, `3 + ceil((minutos - 60) / 60) * 2`. Close with the variant.
:::

::: variante
On Sundays the first hour is free. Add a second value, the day, and charge accordingly.
:::

::: explicacion
Edges: 60 and 61 minutes. Frequent mistake: using `div` instead of rounding up, which charges 61 minutes as 60.
:::

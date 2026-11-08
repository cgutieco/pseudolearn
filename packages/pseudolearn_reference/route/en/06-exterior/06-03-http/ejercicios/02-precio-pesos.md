---
id: exterior.http.precio-pesos
leccion: exterior.http
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The price in pesos
---

::: enunciado
Read a price in dollars and the exchange rate, and show the price in pesos.
:::

::: restriccion
The calculation is done by a pure function, `PrecioEnPesos`, which receives the dollars and the rate.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | PrecioEnPesos | 2 | The function PrecioEnPesos, which receives the dollars and the rate, is missing.
```

::: pistas
1. Which sum turns dollars into pesos?
2. It is the function of the lesson: it knows nothing about networks.
3. The pesos are the dollars times the rate.
4. The algorithm reads the two numbers, calls the function and shows what it gives back. Close with the variant.
:::

::: variante
Add a function that rounds the price up to the nearest ten.
:::

::: docentes
The function is tested without a network: it is the part of the program that the app can check. A rate of 0 gives 0 pesos; it makes no real sense, but the sum handles it.
:::

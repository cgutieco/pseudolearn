---
id: inicio.nombres.reparto-caramelos
leccion: inicio.nombres
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Sharing sweets
---

::: enunciado
There are 47 sweets for 6 friends. Everyone gets the same amount, and the sweets that are not enough for a full round stay in the bag. Show exactly the sentence «Cada amigo recibe 7 y sobran 5», computing both numbers.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. By hand: how many full rounds of 6 sweets come out of 47? How many are left?
2. There are two operations that share out: one says how much each one gets and the other how much is left. They are in [the lesson](ruta:inicio.nombres).
3. `Write` can show texts and sums separated by commas, in any order you like.
4. `Write "Cada amigo recibe ", caramelos div amigos, " y sobran ", caramelos mod amigos;`. Close with the variant.
:::

::: variante
One more friend arrives. What does the program show now? (Answer: `Cada amigo recibe 6 y sobran 5`.)
:::

::: docentes
Solution with `div` and `mod` on the variables. Frequent mistake: writing `7` and `5` by hand, which passes the case but not the variant.
:::

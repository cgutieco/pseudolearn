---
id: inicio.nombres.reparto-caramelos
leccion: inicio.nombres
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Sharing sweets
---

::: enunciado
There are 47 sweets for 6 friends. Everyone gets the same amount, and the sweets that are not enough for a full round stay in the bag. Show exactly the sentence «Each friend gets 7 and the leftover is 5», computing both numbers.
:::

```programa rol=inicial
Algoritmo Sweets
  Definir sweets Como Entero <- 47;
  Definir friends Como Entero <- 6;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Sweets
  Definir sweets Como Entero <- 47;
  Definir friends Como Entero <- 6;
  Escribir "Each friend gets ", sweets div friends, " and the leftover is ", sweets mod friends;
FinAlgoritmo
```

```casos
visible | — | Each friend gets 7 and the leftover is 5
```

::: pistas
1. By hand: how many full rounds of 6 sweets come out of 47? How many are left?
2. There are two operations that share out: one says how much each one gets and the other how much is left. They are in [the lesson](ruta:inicio.nombres).
3. `Write` can show texts and sums separated by commas, in any order you like.
4. `Write "Each friend gets ", sweets div friends, " and the leftover is ", sweets mod friends;`. Close with the variant.
:::

::: variante
One more friend arrives. What does the program show now? (Answer: `Each friend gets 6 and the leftover is 5`.)
:::

::: explicacion
Solution with `div` and `mod` on the variables. Frequent mistake: writing `7` and `5` by hand, which passes the case but not the variant.
:::

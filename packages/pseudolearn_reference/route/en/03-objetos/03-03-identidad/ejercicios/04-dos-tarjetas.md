---
id: objetos.identidad.dos-tarjetas
leccion: objetos.identidad
tipo: resolver
nivel: brote
obligatorio: true
titulo: Two cards with the same balance
---

::: enunciado
Read an initial balance and create two canteen cards with that balance. Charge 5 pesos to the first and show both balances, separated by a space. If the first one does not have enough, nothing is charged.
:::

::: restriccion
Use the class `Tarjeta` from the previous lesson, with its private balance.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many cards have to exist at the end? How many times do you have to create one?
2. Look at the alias in [the lesson](ruta:objetos.identidad): assigning does not create a new card.
3. Create each card with its own `New`.
4. Two `New Tarjeta(inicial)`, a `Cobrar(5)` on the first and both `Saldo()`. Close with the variant.
:::

::: variante
Make the second card an alias of the first. What does it show now with 20?
:::

::: docentes
Frequent mistake: creating one card and assigning it to both variables, which shows 15 15. Hidden cases: charging exactly the balance, a balance that is not enough and an empty one.
:::

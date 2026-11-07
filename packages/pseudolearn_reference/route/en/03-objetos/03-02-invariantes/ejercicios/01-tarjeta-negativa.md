---
id: objetos.invariantes.tarjeta-negativa
leccion: objetos.invariantes
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The card that goes negative
---

::: enunciado
This program reads the initial balance of a card and an amount to charge, and shows whether it could charge and the balance left. With balance 30 and a charge of 50 it leaves the card at -20. Find the error and fix it so that the card never goes negative.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. What always has to be true of a card? Which method breaks it?
2. Compare `Cobrar` with the one of the card in [the lesson](ruta:objetos.invariantes).
3. Before subtracting, the method has to decide whether the charge is possible; if not, it returns false without touching anything.
4. Add at the start of `Cobrar` the check that the amount is positive and not over the balance. Close with the variant.
:::

::: variante
Add a method `Transferir(otra, monto)` that moves balance from one card to another without breaking the invariant in either.
:::

::: docentes
The method subtracts without asking. Hidden cases: charging exactly the balance, one more, charging an empty card and a charge of 0.
:::

---
id: procedimental.ambito.cambiar-figuritas
leccion: procedimental.ambito
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The swap that does not swap
---

::: enunciado
The program reads two numbers and should show them the other way round, using `Intercambiar` (swap). But it shows them in the same order. Find the error and fix it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Which boxes does `Intercambiar` change? Are they the same ones the main algorithm reads?
2. Look at the balance that did not double in [the lesson](ruta:procedimental.ambito).
3. Returning is not enough here: you have to give back two values.
4. Mark both parameters with `By Reference`. Close with the variant.
:::

::: variante
Write `OrdenarTres`, which leaves three numbers from smallest to largest using `Intercambiar`.
:::

::: docentes
The subprogram swaps its copies. Since two values have to come back, the solution lends both boxes. The 1 and 1 case does not uncover the error: that is why more cases are needed.
:::

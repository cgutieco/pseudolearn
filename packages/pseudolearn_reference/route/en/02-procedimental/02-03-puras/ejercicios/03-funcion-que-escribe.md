---
id: procedimental.puras.funcion-que-escribe
leccion: procedimental.puras
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The function that talks
---

::: enunciado
This program reads a price and should show `IVA: ` followed by 21 % of the price, rounded down. But it does not even start. Find the error and fix it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Is it a compile error, a runtime error or a logic error? Read the diagnostic.
2. Look at the function that shows in [the lesson](ruta:procedimental.puras).
3. The message is not part of the calculation: it can go outside or disappear.
4. Remove the `Write` from the function; if you want the message, put it in the main algorithm. Close with the variant.
:::

::: variante
Add a function `ConIva` that uses `Iva` and returns the price with the tax included.
:::

::: explicacion
The engine rejects the program because a `Function` cannot show anything. The fix leaves the function pure and, if needed, moves the message to the main algorithm.
:::

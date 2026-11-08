---
id: exterior.http.que-hacer
leccion: exterior.http
tipo: resolver
nivel: brote
obligatorio: true
titulo: What to show
---

::: enunciado
Read a status code and an exchange rate. If the code is 200, show «Precio: » and the price in pesos of a fruit of 2 dollars; otherwise, show «Servicio no disponible (» with the code and «)».
:::

::: restriccion
The message is built by a pure function, `QueMostrar`, which receives the code and the rate.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | QueMostrar | 2 | The function QueMostrar, which receives the code and the rate, is missing.
- contiene | condicional | The function decides with an If according to the code.
```

::: pistas
1. Which two paths does the message have?
2. One is the price and the other, the warning with the code.
3. The condition compares the code with 200, exactly as the task asks.
4. Turn the numbers into text with `toText` to join them to the message. Close with the variant.
:::

::: variante
Accept as fine any code from 200 to 299.
:::

::: docentes
The case 201 confirms that the task asks for exactly 200. The breaking exercise of this lesson shows why it is better to accept the whole range.
:::

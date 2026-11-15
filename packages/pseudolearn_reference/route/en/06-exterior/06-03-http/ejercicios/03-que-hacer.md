---
id: exterior.http.que-hacer
leccion: exterior.http
tipo: resolver
nivel: brote
obligatorio: true
titulo: What to show
---

::: enunciado
Read a status code and an exchange rate. If the code is 200, show «Price: » and the price in pesos of a fruit of 2 dollars; otherwise, show «Service unavailable (» with the code and «)».
:::

::: restriccion
The message is built by a pure function, `WhatToShow`, which receives the code and the rate.
:::

```programa rol=referencia
Funcion message <- WhatToShow(code Como Entero, rate Como Entero)
  Definir message Como Cadena;
  Si code = 200 Entonces
    message <- "Price: " + ATexto(2 * rate);
  Sino
    message <- "Service unavailable (" + ATexto(code) + ")";
  FinSi
FinFuncion

Algoritmo WhatToDo
  Definir code Como Entero;
  Definir rate Como Entero;
  Leer code;
  Leer rate;
  Escribir WhatToShow(code, rate);
FinAlgoritmo
```

```casos
visible | 200 ; 20 | Price: 40
visible | 503 ; 20 | Service unavailable (503)
oculto | 404 ; 1 | Service unavailable (404)
oculto | 200 ; 0 | Price: 0
oculto | 201 ; 5 | Service unavailable (201)
```

```aserciones
- declara-subprograma | WhatToShow | 2 | The function WhatToShow, which receives the code and the rate, is missing.
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

::: explicacion
The case 201 confirms that the task asks for exactly 200. The breaking exercise of this lesson shows why it is better to accept the whole range.
:::

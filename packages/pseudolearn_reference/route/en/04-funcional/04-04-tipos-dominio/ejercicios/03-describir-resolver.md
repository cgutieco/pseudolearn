---
id: funcional.tipos-dominio.describir-resolver
leccion: funcional.tipos-dominio
tipo: resolver
nivel: brote
obligatorio: true
titulo: Building and describing an order
---

::: enunciado
Read a state code and its data: 1 pending, with no data; 2 on its way, with the courier; 3 delivered, with the courier and the time; 4 cancelled, with the reason. Build the order and show its description, as in the lesson: «On its way with Sol».
:::

::: restriccion
The order is a variant with one shape per state, and the description is a function with a `Switch`.
:::

```programa rol=referencia
Variante Order
  Alternativa Pending
  Alternativa OnItsWay(courier Como Cadena)
  Alternativa Delivered(courier Como Cadena, hour Como Entero)
  Alternativa Canceled(reason Como Cadena)
FinVariante

Funcion text <- Describe(order Como Order)
  Definir text Como Cadena <- "";
  Segun order Hacer
    Order.Pending: text <- "Pending";
    Order.OnItsWay(who): text <- "On its way with " + who;
    Order.Delivered(who, hour): text <- "Delivered by " + who + " at " + ConvertirATexto(hour);
    Order.Canceled(reason): text <- "Canceled: " + reason;
  FinSegun
FinFuncion

Algoritmo Orders
  Definir code Como Entero;
  Definir courier, reason Como Cadena;
  Definir hour Como Entero;
  Definir order Como Order <- Order.Pending;
  Leer code;
  Segun code Hacer
    2:
      Leer courier;
      order <- Order.OnItsWay(courier);
    3:
      Leer courier;
      Leer hour;
      order <- Order.Delivered(courier, hour);
    4:
      Leer reason;
      order <- Order.Canceled(reason);
    De Otro Modo:
      order <- Order.Pending;
  FinSegun
  Escribir Describe(order);
FinAlgoritmo
```

```casos
visible | 2 ; Sol | On its way with Sol
visible | 1 | Pending
oculto | 3 ; Leo ; 9 | Delivered by Leo at 9
oculto | 4 ; rain | Canceled: rain
oculto | 3 ; Ana ; 23 | Delivered by Ana at 23
```

::: pistas
1. Which data does each state carry? How many shapes does the order have?
2. Use the variant and `Describe` of [the lesson](ruta:funcional.tipos-dominio).
3. Read the code; according to the code, read the matching data and build the shape.
4. A `Switch code` that builds `Order.OnItsWay`, `Order.Delivered` or `Order.Canceled`, and finally `Describe`. Close with the variant.
:::

::: variante
Add state 5, returned with a reason. What does the engine warn you about?
:::

::: explicacion
The app's catalogue of checks cannot require a variant; the restriction asks for it. Hidden cases: the four states.
:::

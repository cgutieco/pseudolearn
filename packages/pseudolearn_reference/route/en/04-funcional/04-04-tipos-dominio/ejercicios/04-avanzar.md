---
id: funcional.tipos-dominio.avanzar
leccion: funcional.tipos-dominio
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Moving forward with its errors
---

::: enunciado
An order starts pending or cancelled: read `pending`, or `canceled` followed by the reason. Then read how many times it has to move forward, with the courier `Sol` and the time 14. Show the final description, or the first reason why it could not move forward, such as «Cannot: it is canceled: rain».
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

SubProceso Advance(order Como Order, courier Como Cadena, hour Como Entero) Como Resultado<Order, Cadena>
  Segun order Hacer
    Order.Pending: Retornar Exito(Order.OnItsWay(courier));
    Order.OnItsWay(who): Retornar Exito(Order.Delivered(who, hour));
    Order.Delivered(who, when): Retornar Error("already delivered by " + who + " at " + ConvertirATexto(when));
    Order.Canceled(reason): Retornar Error("it is canceled: " + reason);
  FinSegun
FinSubProceso

Algoritmo Advances
  Definir start, reason Como Cadena;
  Definir times Como Entero;
  Leer start;
  Definir order Como Order <- Order.Pending;
  Si start = "canceled" Entonces
    Leer reason;
    order <- Order.Canceled(reason);
  FinSi
  Leer times;
  Definir problem Como Cadena <- "";
  Para paso <- 1 Hasta times Hacer
    Si problem = "" Entonces
      Segun Advance(order, "Sol", 14) Hacer
        Exito(next): order <- next;
        Error(cause): problem <- cause;
      FinSegun
    FinSi
  FinPara
  Si problem = "" Entonces
    Escribir Describe(order);
  Sino
    Escribir "Cannot: ", problem;
  FinSi
FinAlgoritmo
```

```casos
visible | pending ; 1 | On its way with Sol
visible | pending ; 2 | Delivered by Sol at 14
oculto | pending ; 0 | Pending
oculto | pending ; 3 | Cannot: already delivered by Sol at 14
oculto | canceled ; rain ; 1 | Cannot: it is canceled: rain
oculto | canceled ; out of stock ; 0 | Canceled: out of stock
```

::: pistas
1. From which states can it move forward? What happens with the others?
2. It is the `Advance` of [the lesson](ruta:funcional.tipos-dominio), repeated several times.
3. Move forward while it has not failed; the first error is kept and it does not move forward any more.
4. A loop that calls `Advance` and handles the `Result`; at the end, the description or the reason. Close with the variant.
:::

::: variante
Add `Cancel(order, reason)`, which only cancels orders that are pending or on their way.
:::

::: explicacion
Hidden cases: zero moves, moving forward too many times, moving a cancelled one and a cancelled one without moves.
:::

---
id: funcional.tipos-dominio.segun-pedido
leccion: funcional.tipos-dominio
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Three orders
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Variante Order
  Alternativa Pending
  Alternativa OnItsWay(courier Como Cadena)
  Alternativa Delivered(courier Como Cadena, hour Como Entero)
  Alternativa Cancelled(reason Como Cadena)
FinVariante

Funcion text <- Describe(order Como Order)
  Definir text Como Cadena <- "";
  Segun order Hacer
    Order.Pending: text <- "Pending";
    Order.OnItsWay(who): text <- "On its way with " + who;
    Order.Delivered(who, hour): text <- "Delivered by " + who + " at " + ConvertirATexto(hour);
    Order.Cancelled(reason): text <- "Cancelled: " + reason;
  FinSegun
FinFuncion

Algoritmo Three
  Escribir Describe(Order.Pending);
  Escribir Describe(Order.Delivered("Leo", 9));
  Escribir Describe(Order.Cancelled("rain"));
FinAlgoritmo
```

```salida
Pending
Delivered by Leo at 9
Cancelled: rain
```

::: explicacion
The `Switch` of `Describe` chooses the branch according to the shape of each order and reads its data: the courier and the time of the delivered one, the reason of the cancelled one.
:::

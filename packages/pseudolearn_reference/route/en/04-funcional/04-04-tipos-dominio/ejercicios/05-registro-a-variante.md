---
id: funcional.tipos-dominio.registro-a-variante
leccion: funcional.tipos-dominio
tipo: modificar
nivel: brote
obligatorio: false
titulo: From record to variant
---

::: enunciado
This program reads the state of a delivery as text and, if needed, one more value. With any state it does not know it shows «Pending», and so a typo such as «delivred» goes unnoticed. Rewrite it so that each state is a shape with its own data, and that there is a shape for unknown states, which shows «Unknown state: » and the text read. For known states, what is shown does not change.
:::

::: restriccion
The delivery is a variant with one shape per state, and each shape carries only its data.
:::

```programa rol=inicial
Registro Delivery
  Definir estado, courier, reason Como Cadena;
  Definir hora Como Entero;
FinRegistro

Algoritmo Deliveries
  Definir estado Como Cadena;
  Leer estado;
  Definir delivery Como Delivery <- Delivery(estado, "", "", 0);
  Si estado = "on its way" Entonces
    Leer delivery.courier;
    Escribir "On its way with ", delivery.courier;
  Sino
    Si estado = "canceled" Entonces
      Leer delivery.reason;
      Escribir "Canceled: ", delivery.reason;
    Sino
      Escribir "Pending";
    FinSi
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Variante Delivery
  Alternativa Pending
  Alternativa OnItsWay(courier Como Cadena)
  Alternativa Canceled(reason Como Cadena)
  Alternativa Unknown(estado Como Cadena)
FinVariante

Funcion text <- Describe(delivery Como Delivery)
  Definir text Como Cadena <- "";
  Segun delivery Hacer
    Delivery.Pending: text <- "Pending";
    Delivery.OnItsWay(who): text <- "On its way with " + who;
    Delivery.Canceled(reason): text <- "Canceled: " + reason;
    Delivery.Unknown(estado): text <- "Unknown state: " + estado;
  FinSegun
FinFuncion

Algoritmo Deliveries
  Definir estado, detail Como Cadena;
  Leer estado;
  Definir delivery Como Delivery <- Delivery.Unknown(estado);
  Si estado = "pending" Entonces
    delivery <- Delivery.Pending;
  FinSi
  Si estado = "on its way" Entonces
    Leer detail;
    delivery <- Delivery.OnItsWay(detail);
  FinSi
  Si estado = "canceled" Entonces
    Leer detail;
    delivery <- Delivery.Canceled(detail);
  FinSi
  Escribir Describe(delivery);
FinAlgoritmo
```

```casos
visible | on its way ; Sol | On its way with Sol
visible | delivred | Unknown state: delivred
oculto | canceled ; rain | Canceled: rain
oculto | pending | Pending
oculto | nothing | Unknown state: nothing
```

::: pistas
1. Which states exist? Which data does each one need?
2. Look at the variant of the order in [the lesson](ruta:funcional.tipos-dominio).
3. One shape per known state and another for what is not recognised, which keeps the text.
4. Build the delivery according to the text and describe it with a `Switch` over its shapes. Close with the variant.
:::

::: variante
Add the delivered state with its time, without touching the other shapes.
:::

::: explicacion
The record version accepts any text as a state. The variant forces you to decide what to do with what is not recognised.
:::

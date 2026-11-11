---
id: concurrente.canales.pedidos-contar
leccion: concurrente.canales
tipo: resolver
nivel: brote
obligatorio: true
titulo: Count the orders
---

::: enunciado
Read how many orders the kitchen prepares. The kitchen numbers them from 1 and passes them to the window, which holds 2; the window shows «I hand over order n» for each one and, at the end, «Delivered: n».
:::

::: restriccion
The kitchen is a task that sends the orders through a channel created with `Channel(2)` and closes it when it finishes; the window receives until the channel is closed.
:::

```programa rol=referencia
SubProceso Suspendible Cook(amount Como Entero, counter Como Canal<Entero>)
  Para order <- 1 Hasta amount Hacer
    Definir accepted Como Logico <- Aguardar counter.Enviar(order);
    Si No accepted Entonces
      Escribir "The counter closed";
    FinSi
  FinPara
  counter.Cerrar();
FinSubProceso

Algoritmo Orders
  Definir amount Como Entero;
  Leer amount;
  Definir counter Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Cook(amount, counter);
    Definir delivered Como Entero <- 0;
    Repetir
      Segun Aguardar counter.Recibir() Hacer
        Algo(order):
          Escribir "I hand over order ", order;
          delivered <- delivered + 1;
        Nada: Salir;
      FinSegun
    Hasta Que Falso
    Escribir "Delivered: ", delivered;
  FinTareas
FinAlgoritmo
```

```casos
visible | 3 | I hand over order 1 ⏎ I hand over order 2 ⏎ I hand over order 3 ⏎ Delivered: 3
visible | 1 | I hand over order 1 ⏎ Delivered: 1
oculto | 0 | Delivered: 0
oculto | 2 | I hand over order 1 ⏎ I hand over order 2 ⏎ Delivered: 2
oculto | 7 | I hand over order 1 ⏎ I hand over order 2 ⏎ I hand over order 3 ⏎ I hand over order 4 ⏎ I hand over order 5 ⏎ I hand over order 6 ⏎ I hand over order 7 ⏎ Delivered: 7
```

```aserciones
- declara-subprograma | Cook | 2 | The subprogram Cook, which receives the number of orders and the channel, is missing.
```

::: pistas
1. Who produces and who consumes?
2. It is the window program of the lesson, with the number of orders read at the start.
3. The kitchen sends from 1 to the number read and closes the channel; the window repeats `Receive` until `None` arrives.
4. The count is declared inside the scope, before the loop that receives. Close with the variant.
:::

::: variante
Make the window also show the number of the last order handed over.
:::

::: explicacion
With 0 orders the kitchen closes without sending anything and the first `Receive` gives `None`. With 7 orders the channel fills up several times and the kitchen waits: the output is the same.
:::

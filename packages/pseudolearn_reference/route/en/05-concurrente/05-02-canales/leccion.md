---
id: concurrente.canales
numero: "5.2"
tipo: leccion
titulo: Passing messages
duracion: 35
problema_breve: The window that holds 2 dishes
necesita: [concurrente.tareas]
introduce: [canal, aislamiento, productor-consumidor]
usa: [tarea, agenda, concurrencia]
---

::: frase
Two tasks coordinate better by passing messages than by sharing boxes.
:::

## The problem {#problema}

::: problema
The kitchen prepares orders **1, 2 and 3** and leaves them at a **service window that holds 2 dishes**. The window hands over each order as soon as it arrives and, when the kitchen closes, says how many it handed over. If the window is full, the kitchen waits.

**How do the kitchen and the window communicate without getting in each other's way?**
:::

## Try it {#intentalo}

::: intento
How many orders does the window hand over, and in what order?
:::

::: respuesta
**3**, in the order the kitchen left them: 1, 2 and 3.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The orders the kitchen prepares go in; each delivery comes out and, at the end, how many there were.
- **What does it look like?** The kitchen of the previous lesson, but now the dishes go out one at a time, without waiting for the end.
- **What can happen at once and what has to wait?** The kitchen and the window work at once; the window waits when there are no dishes and the kitchen waits when there is no room.

## The new tool {#herramienta}

A [[def:canal|channel]] is a line of messages between tasks: one task sends, another receives, and the messages come out in the order they went in. `Channel(2)` creates one that holds two messages; if it is full, whoever sends waits.

```figura-especificacion seccion=tareas.canales figura=canal-cola
```

```figura id=ruta-mostrador
pie: The orders come out of the channel in the order they went in.
paso: The kitchen leaves order 1.
paso: It leaves 2: the channel is full and the kitchen waits.
paso: The window receives 1 and there is room.
paso: The kitchen leaves order 3.
```

This way of sharing the work has a name: the [[def:productor-consumidor|producer and consumer]] scheme. One task produces messages and another consumes them, and the channel between the two makes each one wait only when needed.

```programa id=tuberia-mini titulo="A small pipeline" ejecutar
SubProceso Suspendible Produce(queue Como Canal<Entero>)
  Para valor <- 10 Hasta 30 Con Paso 10 Hacer
    Definir accepted Como Logico <- Aguardar queue.Enviar(valor);
    Si No accepted Entonces
      Escribir "channel closed";
    FinSi
  FinPara
  queue.Cerrar();
FinSubProceso

SubProceso Suspendible Consume(queue Como Canal<Entero>)
  Repetir
    Segun Aguardar queue.Recibir() Hacer
      Algo(valor): Escribir "received ", valor;
      Nada: Salir;
    FinSegun
  Hasta Que Falso
FinSubProceso

Algoritmo MiniPipeline
  Definir queue Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Produce(queue);
    Lanzar Consume(queue);
  FinTareas
FinAlgoritmo
```

```salida
received 10
received 20
received 30
```

`Send` gives back whether the channel accepted the message: a closed channel accepts nothing. `Receive` gives back an `Optional`: `Some` with the message, or `None` when the channel was closed and no messages are left. That is why the consumer ends with `Exit`.

::: especificacion
- tareas.canales
:::

## Write {#escribir fase=3}

```programa id=mostrador titulo="The kiosk window" ejecutar
SubProceso Suspendible Cook(counter Como Canal<Entero>)
  Para order <- 1 Hasta 3 Hacer
    Definir accepted Como Logico <- Aguardar counter.Enviar(order);
    Si No accepted Entonces
      Escribir "The counter closed";
    FinSi
  FinPara
  counter.Cerrar();
FinSubProceso

Algoritmo Kiosk
  Definir counter Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Cook(counter);
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

```salida
I hand over order 1
I hand over order 2
I hand over order 3
Delivered: 3
```

The kitchen is a task; the window is the algorithm itself, which receives until the channel is closed. The count of deliveries is declared and changed inside the scope, next to whoever uses it.

## Test {#probar fase=4}

Guaranteed: the order 1, 2, 3, because a channel delivers in the order it is sent, and `Delivered` at the end, because it is written after receiving everything.

Edge case: the kitchen closes without sending anything. The first `Receive` gives `None` and the window shows `Delivered: 0`.

Odd case: nobody closes the channel. The window waits forever for an order that never arrives, and the engine detects it:

```programa id=bloqueo titulo="A channel nobody closes" ejecutar
SubProceso Suspendible Cook(counter Como Canal<Entero>)
  Para order <- 1 Hasta 3 Hacer
    Definir accepted Como Logico <- Aguardar counter.Enviar(order);
    Si No accepted Entonces
      Escribir "The counter closed";
    FinSi
  FinPara
FinSubProceso

Algoritmo Kiosk
  Definir counter Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Cook(counter);
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

```salida
I hand over order 1
I hand over order 2
I hand over order 3
```

```diagnosticos
taskDeadlock
```

## Improve {#mejorar fase=5}

In one sentence: «The kitchen sends the orders through a channel and the window receives them in order until the channel is closed».

What if the two tasks wrote into the same box, a shared count? Each one would have to guess what the other did between turns. The language pushes towards another way of working, [[def:aislamiento|isolation]]: each task keeps its own data and only shares what it sends through a channel.

An open problem remains: if there are two suppliers, which one do you listen to?

## What you learned {#aprendiste}

::: resumen
- {canal} A channel is a line of messages between tasks, with room for a few; it delivers in the order it was sent.
- {productor-consumidor} The producer and consumer scheme splits the work: one task produces messages and another consumes them.
- {aislamiento} With isolation, each task keeps its data and only shares what it sends through a channel.
:::

## Practise {#practica}

::: practica
- concurrente.canales.canal-suma
- concurrente.canales.canal-tabla
- concurrente.canales.pedidos-contar
- concurrente.canales.quien-es-quien
- concurrente.canales.sin-cerrar
- concurrente.canales.promedio-sensor
:::

::: profundizar titulo="Common pitfalls"
- **«Two tasks can write the same box without problems».** Go back to isolation: what is shared travels through the channel.
- **Forgetting to close the channel.** The deadlock program shows what happens.
- **Expecting a full channel to drop messages.** It does not drop them: whoever sends waits until there is room.
:::

::: siguiente
Two suppliers can bring the bread. How do you serve the one that arrives first and stop waiting for what is no longer needed?
:::

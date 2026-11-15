---
id: concurrente.canales.sin-cerrar
leccion: concurrente.canales
tipo: encontrar-error
nivel: brote
obligatorio: false
titulo: The window that never finishes
---

::: enunciado
The program hands over all the orders, but it never shows the final count and the engine stops it. Find the error and fix it.
:::

```programa rol=inicial
SubProceso Suspendible Cook(amount Como Entero, counter Como Canal<Entero>)
  Para order <- 1 Hasta amount Hacer
    Definir accepted Como Logico <- Aguardar counter.Enviar(order);
    Si No accepted Entonces
      Escribir "The counter closed";
    FinSi
  FinPara
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
oculto | 5 | I hand over order 1 ⏎ I hand over order 2 ⏎ I hand over order 3 ⏎ I hand over order 4 ⏎ I hand over order 5 ⏎ Delivered: 5
```

::: pistas
1. What does the window wait for after the last order?
2. The window leaves the loop only when `Receive` gives `None`.
3. `Receive` gives `None` when the channel was closed and is empty. Who closes it?
4. `counter.Close()` is missing at the end of the kitchen. Close with the variant.
:::

::: variante
What would happen if the window closed the channel instead of the kitchen?
:::

::: explicacion
The engine ends with `taskDeadlock`: no task can move forward. It is the error of forgetting to close the channel, the second one in the lesson's list.
:::

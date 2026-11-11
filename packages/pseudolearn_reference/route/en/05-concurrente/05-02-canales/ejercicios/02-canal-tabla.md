---
id: concurrente.canales.canal-tabla
leccion: concurrente.canales
tipo: rastrear
nivel: brote
obligatorio: false
titulo: Trace the consumer
---

::: enunciado
Complete the table of the task that adds: the message received and the total, one row per message.
:::

```programa rol=objeto id=traza
SubProceso Suspendible Produce(queue Como Canal<Entero>)
  Para valor <- 4 Hasta 6 Hacer
    Definir accepted Como Logico <- Aguardar queue.Enviar(valor);
    Si No accepted Entonces
      Escribir "channel closed";
    FinSi
  FinPara
  queue.Cerrar();
FinSubProceso

SubProceso Suspendible AddUp(queue Como Canal<Entero>)
  Definir total Como Entero <- 0;
  Definir valor Como Entero <- 0;
  Repetir
    Segun Aguardar queue.Recibir() Hacer
      Algo(received):
        valor <- received;
        total <- total + valor;
      Nada: Salir;
    FinSegun
  Hasta Que Falso
  Escribir total;
FinSubProceso

Algoritmo ChannelSum
  Definir queue Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Produce(queue);
    Lanzar AddUp(queue);
  FinTareas
FinAlgoritmo
```

```salida
15
```

```vueltas marca=19 columnas=valor,total
```

::: explicacion
Each message is added to the total: 4, then 4 + 5 = 9 and finally 9 + 6 = 15. The messages arrive in the order they were sent.
:::

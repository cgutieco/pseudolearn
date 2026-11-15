---
id: concurrente.canales.canal-suma
leccion: concurrente.canales
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The sum that arrives in parts
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
SubProceso Suspendible Produce(queue Como Canal<Entero>)
  Para number <- 4 Hasta 6 Hacer
    Definir accepted Como Logico <- Aguardar queue.Enviar(number);
    Si No accepted Entonces
      Escribir "channel closed";
    FinSi
  FinPara
  queue.Cerrar();
FinSubProceso

SubProceso Suspendible AddUp(queue Como Canal<Entero>)
  Definir total Como Entero <- 0;
  Repetir
    Segun Aguardar queue.Recibir() Hacer
      Algo(number): total <- total + number;
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

::: explicacion
The producer sends 4, 5 and 6 and closes. The consumer adds each message and, when `Receive` gives `None`, it leaves the loop and writes 15.
:::

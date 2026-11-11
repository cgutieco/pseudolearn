---
id: concurrente.tareas.turnos-ordenar
leccion: concurrente.tareas
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Order the kitchen
---

::: enunciado
The lines of the kitchen program are mixed up. Put them in order so that it works.
:::

```programa rol=referencia
SubProceso Suspendible Cook(dish Como Cadena, price Como Entero, portions Como Entero) Como Entero
  Escribir "Starting ", dish;
  Retornar price * portions;
FinSubProceso

Algoritmo Kitchen
  Tareas
    Definir juices Como Tarea<Entero> <- Lanzar Cook("juices", 3, 3);
    Definir sandwiches Como Tarea<Entero> <- Lanzar Cook("sandwiches", 5, 2);
    Definir fruits Como Tarea<Entero> <- Lanzar Cook("fruit", 2, 4);
    Escribir "Tray: ", Aguardar juices + Aguardar sandwiches + Aguardar fruits, " pesos";
  FinTareas
  Escribir "Tray delivered";
FinAlgoritmo
```

```casos
visible | — | Starting juices ⏎ Starting sandwiches ⏎ Starting fruit ⏎ Tray: 27 pesos ⏎ Tray delivered
```

::: explicacion
The tasks are launched inside the scope, the tray awaits the three results before closing it, and «Tray delivered» goes after `EndTasks`.
:::

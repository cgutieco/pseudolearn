---
id: concurrente.tareas.suma-tareas
leccion: concurrente.tareas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The sum of two tasks
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
SubProceso Suspendible Square(number Como Entero) Como Entero
  Retornar number * number;
FinSubProceso

Algoritmo SumOfTasks
  Tareas
    Definir one Como Tarea<Entero> <- Lanzar Square(3);
    Definir two Como Tarea<Entero> <- Lanzar Square(4);
    Escribir Aguardar one + Aguardar two;
  FinTareas
FinAlgoritmo
```

```salida
25
```

::: explicacion
Each task gives back a square: 9 and 16. `Await` hands over each result when its task has finished, and the sum is 25, no matter which one finished first.
:::

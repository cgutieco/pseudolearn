---
id: concurrente.tareas.bandeja
leccion: concurrente.tareas
tipo: resolver
nivel: brote
obligatorio: true
titulo: The tray
---

::: enunciado
Read the portions of juices, of sandwiches and of fruit, and show the value of the tray with the format «Tray: 27 pesos». The prices are 3, 5 and 2 pesos.
:::

::: restriccion
Each dish is computed in its own task, launched with `Spawn` inside a `Tasks` scope.
:::

```programa rol=referencia
SubProceso Suspendible Cook(price Como Entero, portions Como Entero) Como Entero
  Retornar price * portions;
FinSubProceso

Algoritmo Tray
  Definir juices Como Entero;
  Definir sandwiches Como Entero;
  Definir fruits Como Entero;
  Leer juices;
  Leer sandwiches;
  Leer fruits;
  Tareas
    Definir ofJuices Como Tarea<Entero> <- Lanzar Cook(3, juices);
    Definir ofSandwiches Como Tarea<Entero> <- Lanzar Cook(5, sandwiches);
    Definir ofFruits Como Tarea<Entero> <- Lanzar Cook(2, fruits);
    Escribir "Tray: ", Aguardar ofJuices + Aguardar ofSandwiches + Aguardar ofFruits, " pesos";
  FinTareas
FinAlgoritmo
```

```casos
visible | 3 ; 2 ; 4 | Tray: 27 pesos
visible | 1 ; 1 ; 1 | Tray: 10 pesos
oculto | 0 ; 0 ; 0 | Tray: 0 pesos
oculto | 0 ; 2 ; 0 | Tray: 10 pesos
oculto | 10 ; 10 ; 10 | Tray: 100 pesos
```

```aserciones
- declara-subprograma | Cook | 2 | The subprogram Cook, which receives the price and the portions, is missing.
```

::: pistas
1. Which calculation is repeated three times with different data?
2. It is the cook of the lesson, without the message: it receives the price and the portions and gives back the value of the dish.
3. Launch three `Task<Integer>` tasks and add up what `Await` hands over from each one.
4. The sum and the `Write` go inside the scope, before `EndTasks`. Close with the variant.
:::

::: variante
Add a fourth cook who makes waters of 2 pesos.
:::

::: explicacion
The assertion requires the cook subprogram. The case of 0 portions confirms that the tray still waits for the three; 10 portions of each dish test larger amounts.
:::

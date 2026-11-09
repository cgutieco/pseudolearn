---
id: concurrente.tareas
numero: "5.1"
tipo: apertura
titulo: Several things at once
duracion: 35
problema_breve: The tray that waits for everyone
necesita: [funcional.proyecto]
introduce: [programacion-concurrente, concurrencia, tarea, agenda]
usa: [paradigma, subprograma, funcion-pura, programacion-funcional]
---

::: frase
A concurrent program splits the work into tasks that move forward by turns, and waits for all of them before going on.
:::

## The problem {#problema}

::: problema
The kiosk kitchen has **three cooks**: one makes **3 juices** of 3 pesos, another **2 sandwiches** of 5 pesos and another **4 fruits** of 2 pesos. The tray is served **only when the three have finished**, and the ticket carries the total value of the tray. Until now, every program did one thing after another.

**How do you write a kitchen where the three work at once and the tray waits for all of them?**
:::

## Try it {#intentalo}

::: intento
Work out the value of the tray and say what has to happen before it is handed over.
:::

::: respuesta
9 + 10 + 8 = **27 pesos**. The tray waits for the three to finish, no matter who finishes first.
:::

## A new paradigm {#paradigma}

::: recuerda termino=paradigma
:::

Until now, every program was a single line of orders: the next one started when the previous one finished. [[def:programacion-concurrente|Concurrent programming]] offers another way to organise it.

::: paradigma
- pregunta: what if a program were a team of workers that move forward by turns and wait for each other when needed?
- metafora: a kitchen with several cooks and a single stove that they take turns at. It stops holding at one point: a cook can decide alone when to leave the stove; a task gives up its turn only when it waits for something.
- historia: in 1965, Edsger Dijkstra published how to coordinate processes that share resources. In 1978, Tony Hoare described processes that communicate by sending each other messages, the idea used by the next lesson.
- costo: you have to think about what can happen at once and what has to wait; some errors only show up with certain turns.
:::

[[def:concurrencia|Concurrency]] is that possibility: that several parts of a program move forward without waiting for the previous one to finish completely.

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** Three orders with price and amount go in; the value of the tray comes out.
- **What does it look like?** The report card of Part II: three equal calculations with different data.
- **What can happen at once and what has to wait?** The three dishes are independent; the tray waits for the three.

## The new tool {#herramienta}

A [[def:tarea|task]] is a job that is launched so that it moves forward on its own. It is written as a `Suspendable` subprogram, launched with `Spawn` inside a `Tasks` scope, and its result is asked for with `Await`. When it reaches `EndTasks`, the scope waits for all its tasks: none stays alive afterwards.

```figura-especificacion seccion=tareas.ambitos figura=ambito-tareas
```

```programa id=dos-saludos titulo="Two greetings" ejecutar
```

```salida
Hola, Ana
Hola, Leo
todas terminaron
```

The only guaranteed thing is the last line: `todas terminaron` comes after the two greetings, because `EndTasks` waits for the two tasks. That Ana greets before Leo is what the engine gives today, but the program does not promise it.

How do they move forward «at once» on a single computer? By turns. The [[def:agenda|schedule]] is the line of ready tasks: it gives the turn to one, and when that task waits for something, it gives the turn to the next.

```figura-especificacion seccion=motor.agenda figura=agenda-cola
```

```figura id=ruta-cocina-turnos
pie: Only one task moves forward in each turn; the one that waits gives up its own.
paso: The algorithm launches the three tasks, which stay in the line.
paso: The algorithm awaits the juices and gives up its turn.
paso: The juices finish; the sandwiches go next.
paso: The fruit goes next.
paso: The three finished: the algorithm receives the results and adds 27.
paso: When the scope closes, no task is left alive.
```

::: especificacion
- tareas.suspendible
- tareas.ambitos
- motor.agenda
:::

## Write {#escribir fase=3}

```programa id=cocina titulo="The kiosk kitchen" ejecutar
```

```salida
Empieza jugos
Empieza sándwiches
Empieza frutas
Bandeja: 27 pesos
Bandeja entregada
```

Each cook is a task that gives back the value of their dish. `Task<Integer>` is the way to ask for that value later: `Await` hands it over when the task has finished, and if it has not finished yet, it waits.

## Test {#probar fase=4}

What is guaranteed and what is not:

| Line | Guaranteed? | Why |
|---|---|---|
| `Bandeja: 27 pesos` after the three `Empieza` | yes | it waits for the three results |
| `Bandeja entregada` at the end | yes | `EndTasks` waits for all of them |
| The order among the three `Empieza` | no | the schedule decides it |

Edge case: a cook with 0 portions. The tray adds 0 for them and, even so, waits for the three.

## Improve {#mejorar fase=5}

In one sentence: «Each cook is a task, and the tray awaits the three results before going out».

| | What organises the program | What it costs |
|---|---|---|
| Imperative | orders that change boxes, one after another | following the history of each box |
| Procedural | subprograms with a name | deciding how to split the problem |
| Objects | objects that keep their state | deciding who is responsible for what |
| Functional | pure functions that compose values | setting apart everything that touches the world |
| Concurrent | tasks that move forward by turns | thinking about what can happen at once |

An open problem remains: if the kitchen has to report dish by dish, waiting for the end of everything is not enough.

## What you learned {#aprendiste}

::: resumen
- {programacion-concurrente,concurrencia} Concurrent programming organises a program into parts that can move forward at once; concurrency is that possibility of moving forward by turns.
- {tarea} A task is a job that is launched so that it moves forward on its own; its scope waits for it before going on.
- {agenda} The schedule shares out the turns among the tasks; a task that waits gives up its turn to another.
:::

## Practise {#practica}

::: practica
- concurrente.tareas.suma-tareas
- concurrente.tareas.que-espera
- concurrente.tareas.bandeja
- concurrente.tareas.final-garantizado
- concurrente.tareas.turnos-ordenar
- concurrente.tareas.doble-romper
:::

::: profundizar titulo="Common pitfalls"
- **«The tasks run at the same time».** On a single computer they move forward by turns: the kitchen figure shows it.
- **«The order of the output will always be this one».** Separate what is guaranteed from what is observed with the table of phase 4.
- **Launching a task outside its scope.** The engine rejects it; the scopes section of the Specification explains the diagnostic.
:::

::: por-dentro
The schedule keeps the ready tasks in a line and gives the turn to the first one; a task that waits leaves the line until what it waits for is ready.

::: especificacion
- motor.agenda
:::
:::

::: siguiente
The kitchen finishes the dishes one at a time. How does it pass on each dish as soon as it is out, without the two touching the same box?
:::

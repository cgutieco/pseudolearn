---
id: concurrente.elegir
numero: "5.3"
tipo: leccion
titulo: Whatever arrives first
duracion: 35
problema_breve: Three suppliers and one order
necesita: [concurrente.canales]
introduce: [cancelacion]
usa: [tarea, canal, agenda, resultado-con-error]
---

::: frase
When several answers can arrive, you serve the first one and cut what is no longer needed.
:::

## The problem {#problema}

::: problema
The kiosk orders fruit from **three suppliers** at once: North, South and West. If **any of them has no stock**, the whole order is suspended and there is no point in waiting for the others.

**How do you write the order so that the first problem stops everything, and how do you know how many queries were cut?**
:::

## Try it {#intentalo}

::: intento
North has no stock; South has 5 and West has 3. What happens to the order?
:::

::: respuesta
The order is suspended because of North. The queries that had not finished yet are cut: with the turns the engine gives today, they are the other **two**.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The stock of each supplier goes in; out comes whether the order is confirmed or why it was suspended.
- **What does it look like?** The tray of lesson 5.1: three tasks in the same scope.
- **What can happen at once and what has to wait?** The three queries go at once; the first one that fails cuts the others.

## The new tool {#herramienta}

Sometimes only the first answer matters. `Select` waits on several channels at once and serves the first one that is ready; the others are left unserved.

```figura id=ruta-carrera
pie: The first answer is served; what is no longer needed is cut.
paso: The two offers set off at once.
paso: The North one arrives first and is served.
paso: The South one is no longer needed: it is cut.
```

```programa id=primera-oferta titulo="The first offer" ejecutar
```

```salida
Norte ofrece 12
```

Which offer arrives first is decided by the schedule: today the engine serves the North one, but the program cannot take it for granted.

[[def:cancelacion|Cancellation]] is cutting a task that is no longer needed. Inside a scope it happens by itself: if a task ends with `Failure`, the scope cancels its sisters. With `Tasks fallo`, the scope keeps what happened in `fallo`, an `Optional`: `None` if everything went well, or `Some` with a report. The report says the first error, in `First`, and how many tasks were cut, in `Cancelled`.

::: especificacion
- tareas.canales
- tareas.ambitos
:::

## Write {#escribir fase=3}

```programa id=proveedores titulo="The order to three suppliers" ejecutar
```

```salida
Falló: Norte no tiene stock
Canceladas: 2
```

Each query gives back a `Result`: `Success` with the stock or `Failure` with the reason. None of them writes anything; the algorithm decides what to show after closing the scope.

## Test {#probar fase=4}

| Case | What happens |
|---|---|
| The three with stock | `Todos confirmaron` |
| Only the last one without stock | it fails all the same; the queries that did not finish are cut |
| The three without stock | the first error rules |

What is guaranteed is that, if any fails, the order is suspended and the report carries an error. Which error is «the first» when two fail, and how many queries get cut, depends on the turns: the exercises do not ask about it.

## Improve {#mejorar fase=5}

In one sentence: «The three queries go at once, and the first error suspends the order and cuts the rest».

Compare `Select` with waiting for the answers one after another. If only one answer matters, waiting for all of them wastes the wait: with `Select`, the first one ready is already served.

## What you learned {#aprendiste}

::: resumen
- {cancelacion} Cancelling is cutting a task that is no longer needed; in a scope, the first error cancels the sisters.
:::

## Practise {#practica}

::: practica
- concurrente.elegir.canceladas
- concurrente.elegir.todos-bien
- concurrente.elegir.pedido-resolver
- concurrente.elegir.elegir-o-esperar
- concurrente.elegir.cancelar-clasificar
- concurrente.elegir.pedido-pruebas
:::

::: docentes
- **«The same channel always wins».** The schedule decides it: do not assume it.
- **«Cancelling erases what the task already did».** What was already written stays; cancelling only cuts what was missing.
- **Confusing cancelling with failing.** One task fails; the ones cut because of it did not fail.
:::

::: siguiente
When the kiosk closes, everything the program knew is lost. How do you keep it for tomorrow?
:::

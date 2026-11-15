---
id: concurrente.elegir.pedido-resolver
leccion: concurrente.elegir
tipo: resolver
nivel: brote
obligatorio: true
titulo: The fruit order
---

::: enunciado
Read the stock of North, of South and of West. If any of them has 0, show «Order suspended: » and the reason, for example «North has no stock»; otherwise, show «Order confirmed: » and the sum of the three.
:::

::: restriccion
Each supplier is queried in its own task, which gives back a `Result`: `Success` with the stock or `Failure` with the reason. The first error suspends the order.
:::

```programa rol=referencia
SubProceso Suspendible Query(name Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(name + " has no stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Order
  Definir north Como Entero;
  Definir south Como Entero;
  Definir west Como Entero;
  Leer north;
  Leer south;
  Leer west;
  Tareas outcome
    Lanzar Query("North", north);
    Lanzar Query("South", south);
    Lanzar Query("West", west);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Order suspended: ", report.Primero;
    Nada: Escribir "Order confirmed: ", north + south + west;
  FinSegun
FinAlgoritmo
```

```casos
visible | 5 ; 3 ; 2 | Order confirmed: 10
visible | 0 ; 3 ; 2 | Order suspended: North has no stock
oculto | 1 ; 1 ; 1 | Order confirmed: 3
oculto | 4 ; 4 ; 0 | Order suspended: West has no stock
oculto | 9 ; 0 ; 9 | Order suspended: South has no stock
```

```aserciones
- declara-subprograma | Query | 2 | The subprogram Query, which receives the name and the stock, is missing.
```

::: pistas
1. What does each query have to give back when there is stock, and what when there is not?
2. It is like the lesson program: three tasks in a `Tasks outcome` scope, and the one that gives back `Failure` cuts the others.
3. After `EndTasks`, `outcome` is `None` if all of them gave `Success`, or `Some` with a report whose `First` is the reason.
4. With a `Switch` on `outcome`, show the suspension with the reason or the confirmation with the sum. Close with the variant.
:::

::: variante
Also show how many suppliers had stock when the order is confirmed.
:::

::: explicacion
The cases have at most one supplier without stock, so the reason does not depend on the turns of the schedule. When a supplier fails, the scope cancels the queries that are still alive; the exercise does not ask how many.
:::

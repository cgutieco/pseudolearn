---
id: concurrente.elegir.canceladas
leccion: concurrente.elegir
tipo: predecir
nivel: semilla
obligatorio: true
titulo: The supplier that fails
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
SubProceso Suspendible Query(name Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(name + " has no stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Order
  Tareas outcome
    Lanzar Query("North", 3);
    Lanzar Query("South", 0);
    Lanzar Query("West", 2);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Failed: ", report.Primero;
    Nada: Escribir "All confirmed";
  FinSegun
FinAlgoritmo
```

```salida
Failed: South has no stock
```

::: explicacion
Only South has stock 0: its query ends with `Failure` and the scope keeps that error as the first one. How many queries get cut depends on the turns; that is why this program does not show it.
:::

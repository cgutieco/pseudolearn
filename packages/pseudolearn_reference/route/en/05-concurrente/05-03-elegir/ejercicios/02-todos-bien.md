---
id: concurrente.elegir.todos-bien
leccion: concurrente.elegir
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Everyone has some
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
    Lanzar Query("North", 1);
    Lanzar Query("South", 1);
    Lanzar Query("West", 1);
  FinTareas
  Segun outcome Hacer
    Algo(report): Escribir "Failed: ", report.Primero;
    Nada: Escribir "All confirmed";
  FinSegun
FinAlgoritmo
```

```salida
All confirmed
```

::: explicacion
No query fails, so the scope ends without a report: `outcome` is `None`.
:::

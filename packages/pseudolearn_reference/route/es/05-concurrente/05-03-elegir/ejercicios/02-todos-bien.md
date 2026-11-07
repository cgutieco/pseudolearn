---
id: concurrente.elegir.todos-bien
leccion: concurrente.elegir
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Todos tienen
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
SubProceso Suspendible Consultar(nombre Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(nombre + " no tiene stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Pedido
  Tareas fallo
    Lanzar Consultar("Norte", 1);
    Lanzar Consultar("Sur", 1);
    Lanzar Consultar("Oeste", 1);
  FinTareas
  Segun fallo Hacer
    Algo(problema): Escribir "Falló: ", problema.Primero;
    Nada: Escribir "Todos confirmaron";
  FinSegun
FinAlgoritmo
```

```salida
Todos confirmaron
```

::: explicacion
Ninguna consulta falla, así que el ámbito termina sin informe: `fallo` vale `Nada`.
:::

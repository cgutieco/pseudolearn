---
id: concurrente.elegir.canceladas
leccion: concurrente.elegir
tipo: predecir
nivel: semilla
obligatorio: true
titulo: El proveedor que falla
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
    Lanzar Consultar("Norte", 3);
    Lanzar Consultar("Sur", 0);
    Lanzar Consultar("Oeste", 2);
  FinTareas
  Segun fallo Hacer
    Algo(problema): Escribir "Falló: ", problema.Primero;
    Nada: Escribir "Todos confirmaron";
  FinSegun
FinAlgoritmo
```

```salida
Falló: Sur no tiene stock
```

::: explicacion
Solo Sur tiene stock 0: su consulta termina con `Error` y el ámbito guarda ese error como el primero. Cuántas consultas alcanzan a cortarse depende de los turnos; por eso este programa no lo muestra.
:::

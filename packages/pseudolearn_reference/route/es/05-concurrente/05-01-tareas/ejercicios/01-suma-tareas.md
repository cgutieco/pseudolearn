---
id: concurrente.tareas.suma-tareas
leccion: concurrente.tareas
tipo: predecir
nivel: semilla
obligatorio: true
titulo: La suma de dos tareas
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
SubProceso Suspendible Cuadrado(numero Como Entero) Como Entero
  Retornar numero * numero;
FinSubProceso

Algoritmo SumaDeTareas
  Tareas
    Definir primera Como Tarea<Entero> <- Lanzar Cuadrado(3);
    Definir segunda Como Tarea<Entero> <- Lanzar Cuadrado(4);
    Escribir Aguardar primera + Aguardar segunda;
  FinTareas
FinAlgoritmo
```

```salida
25
```

::: explicacion
Cada tarea devuelve un cuadrado: 9 y 16. `Aguardar` entrega cada resultado cuando su tarea terminó, y la suma es 25, sin importar cuál terminó primero.
:::

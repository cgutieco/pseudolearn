---
id: concurrente.tareas.turnos-ordenar
leccion: concurrente.tareas
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordenar la cocina
---

::: enunciado
Las líneas del programa de la cocina están mezcladas. Ordénalas para que funcione.
:::

```programa rol=referencia
SubProceso Suspendible Cocinar(plato Como Cadena, precio Como Entero, porciones Como Entero) Como Entero
  Escribir "Empieza ", plato;
  Retornar precio * porciones;
FinSubProceso

Algoritmo Cocina
  Tareas
    Definir jugos Como Tarea<Entero> <- Lanzar Cocinar("jugos", 3, 3);
    Definir sandwiches Como Tarea<Entero> <- Lanzar Cocinar("sándwiches", 5, 2);
    Definir frutas Como Tarea<Entero> <- Lanzar Cocinar("frutas", 2, 4);
    Escribir "Bandeja: ", Aguardar jugos + Aguardar sandwiches + Aguardar frutas, " pesos";
  FinTareas
  Escribir "Bandeja entregada";
FinAlgoritmo
```

```casos
visible | — | Empieza jugos ⏎ Empieza sándwiches ⏎ Empieza frutas ⏎ Bandeja: 27 pesos ⏎ Bandeja entregada
```

::: explicacion
Las tareas se lanzan dentro del ámbito, la bandeja aguarda los tres resultados antes de cerrarlo, y «Bandeja entregada» va después de `FinTareas`.
:::

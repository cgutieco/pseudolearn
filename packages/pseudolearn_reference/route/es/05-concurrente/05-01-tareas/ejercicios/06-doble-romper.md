---
id: concurrente.tareas.doble-romper
leccion: concurrente.tareas
tipo: romperlo
nivel: arbol
obligatorio: false
titulo: Una suma apurada
---

::: enunciado
Este programa calcula en dos tareas el doble y el triple de un número y muestra la suma. Con 0 acierta. Encuentra un número con el que se equivoque.
:::

```programa rol=defectuoso
SubProceso Suspendible Doble(numero Como Entero) Como Entero
  Retornar numero * 2;
FinSubProceso

SubProceso Suspendible Triple(numero Como Entero) Como Entero
  Retornar numero * 3;
FinSubProceso

Algoritmo DobleYTriple
  Definir numero Como Entero;
  Leer numero;
  Tareas
    Definir doble Como Tarea<Entero> <- Lanzar Doble(numero);
    Definir triple Como Tarea<Entero> <- Lanzar Triple(numero);
    Definir parteTriple Como Entero <- 0;
    Escribir Aguardar doble + parteTriple;
    parteTriple <- Aguardar triple;
  FinTareas
FinAlgoritmo
```

```programa rol=referencia
SubProceso Suspendible Doble(numero Como Entero) Como Entero
  Retornar numero * 2;
FinSubProceso

SubProceso Suspendible Triple(numero Como Entero) Como Entero
  Retornar numero * 3;
FinSubProceso

Algoritmo DobleYTriple
  Definir numero Como Entero;
  Leer numero;
  Tareas
    Definir doble Como Tarea<Entero> <- Lanzar Doble(numero);
    Definir triple Como Tarea<Entero> <- Lanzar Triple(numero);
    Escribir Aguardar doble + Aguardar triple;
  FinTareas
FinAlgoritmo
```

```casos
visible | 0 | 0
```

```rompe
4
-1
```

::: pistas
1. ¿Cuándo se muestra la suma, y cuándo se aguarda el triple?
2. La suma usa un valor provisorio en vez del resultado de la segunda tarea.
3. Ese valor provisorio es 0: el programa solo acierta cuando el triple también es 0.
4. Con 4 muestra 8 en vez de 20. Cierra con la variante.
:::

::: variante
¿Qué línea hay que mover para que el programa sea correcto?
:::

::: docentes
Lo rompe cualquier número distinto de 0. Es el error de usar un resultado antes de aguardarlo: el valor provisorio esconde la espera que faltaba.
:::

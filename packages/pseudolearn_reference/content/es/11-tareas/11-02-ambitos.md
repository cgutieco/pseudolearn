---
id: tareas.ambitos
numero: "11.2"
tipo: construccion
titulo: "Ámbitos de tareas con `Tareas` y `Lanzar`"
anclas: [LANG.TASK.SCOPE#R1, LANG.TASK.SCOPE#R2, LANG.TASK.SCOPE#R3, LANG.TASK.SCOPE#R4, LANG.TASK.SCOPE#R5, LANG.TASK.SCOPE#R6, LANG.TASK.SCOPE#R7, LANG.TASK.SCOPE#R8, LANG.TASK.SCOPE#R9, LANG.TASK.SCOPE#R10, LANG.TASK.SCOPE#R11, LANG.TASK.SCOPE#R12, LANG.TASK.SCOPE#R13, LANG.TASK.SCOPE#R14, LANG.TASK.SCOPE#R15, LANG.TASK.SCOPE#R16]
fichas: [help.task-scope]
diagnosticos: [spawnOutsideTaskScope, spawnTargetNotSuspendible, taskArgumentNotTransferable, taskByReferenceArgument, taskHandleEscape, taskScopeInsideDefer, taskScopeErrorTypeMismatch, taskErrorNotTransferable, taskScopeFailureUnbound, taskScopeFailureUnused]
terminos: [tarea, ámbito de tareas, asa]
---

::: frase
`Tareas` abre un espacio donde se lanzan tareas que avanzan a la vez; `FinTareas` espera a que **todas** terminen, así que ninguna se queda suelta.
:::

## Cómo se escribe {#escribe}

```forma
Tareas ⟦«fallo»⟧
  Lanzar «Unidad»(«argumentos»);
  Definir «asa» Como Tarea<«tipo»> <- Lanzar «Unidad»(«argumentos»);
  «instrucciones»
FinTareas
```

::: partes
- `Tareas` abre el ámbito. «fallo» es un nombre opcional que, después de `FinTareas`, dice si alguna tarea falló.
- `Lanzar` crea una tarea hija que ejecuta una unidad `Suspendible`. Solo se escribe directamente dentro del ámbito.
- Un **asa** `Tarea<T>` guarda la tarea lanzada; su único uso es `Aguardar asa` para obtener el resultado.
- `FinTareas` une todas las hijas: espera a las que siguen vivas.
:::

## Cómo funciona {#funciona}

`Lanzar` no detiene al padre: crea la hija y el padre sigue con la siguiente sentencia. Las hijas se ejecutan cuando el padre se pausa, como mucho hasta `FinTareas`.

```programa id=lanzar-dos titulo="Dos tareas y su unión" ejecutar
SubProceso Suspendible Saludar(nombre Como Cadena)
  Escribir "Hola, ", nombre;
FinSubProceso

Algoritmo Orden
  Tareas
    Lanzar Saludar("Ana");
    Lanzar Saludar("Leo");
    Escribir "lanzadas";
  FinTareas
  Escribir "todas terminaron";
FinAlgoritmo
```

```salida
lanzadas
Hola, Ana
Hola, Leo
todas terminaron
```

```figura id=ambito-tareas
pie: El padre lanza dos hijas y sigue. En `FinTareas` espera a que las dos acaben; después ninguna sigue viva.
```

Con un asa se recupera el valor de una hija:

```programa id=asas titulo="Esperar resultados" ejecutar
SubProceso Suspendible Cuadrado(n Como Entero) Como Entero
  Retornar n * n;
FinSubProceso

Algoritmo Paralelo
  Tareas
    Definir a Como Tarea<Entero> <- Lanzar Cuadrado(3);
    Definir b Como Tarea<Entero> <- Lanzar Cuadrado(4);
    Escribir Aguardar a + Aguardar b;
  FinTareas
FinAlgoritmo
```

```salida
25
```

## Fallos {#fallos}

Si las hijas devuelven `Resultado<T, E>`, el primer `Error` que termina **cancela** a las demás y salta a `FinTareas`. El nombre de fallo del ámbito es un `Opcional<FalloTareas<E>>`: vale `Nada` si todo fue bien, o `Algo` con un `FalloTareas` cuyos campos son `f.Primero` (el primer error), `f.Asociados` (los errores que llegaron después) y `f.Canceladas` (cuántas hijas se cancelaron).

```programa id=fallo-tareas titulo="El primer error manda" ejecutar
SubProceso Suspendible Dividir(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("división entre cero");
  FinSi
  Retornar Exito(a div b);
FinSubProceso

Algoritmo Fallos
  Tareas fallo
    Lanzar Dividir(10, 2);
    Lanzar Dividir(1, 0);
  FinTareas
  Segun fallo Hacer
    Algo(f):
      Escribir "primer error: ", f.Primero;
    Nada:
      Escribir "todo bien";
  FinSegun
FinAlgoritmo
```

```salida
primer error: división entre cero
```

::: limite
- Los argumentos de `Lanzar` tienen que ser **transferibles** y no pueden ir por referencia: las tareas no comparten memoria mutable.
- Un asa no puede salir del ámbito: asignarla, pasarla o devolverla es `taskHandleEscape`.
- Una trampa en cualquier tarea termina **toda** la ejecución, sin limpiezas.
:::

::: errores
```programa id=lanzar-fuera titulo="Lanzar fuera de Tareas" ejecutar
Algoritmo Fuera
  Lanzar Saludo();
FinAlgoritmo

SubProceso Suspendible Saludo()
FinSubProceso
```

```diagnosticos
spawnOutsideTaskScope
```
:::

::: por-dentro
`Lanzar` reserva una tarea nueva en la agenda del motor con su propio marco; `FinTareas` es una instrucción de unión que suspende al padre mientras quede alguna hija viva.

```ri programa=lanzar-dos
```
:::

::: resumen
- `Tareas` abre un ámbito y `FinTareas` espera a todas sus hijas.
- `Lanzar` crea una hija sin detener al padre.
- Un asa se usa solo con `Aguardar`.
- El primer error cancela a las hermanas y queda en el nombre de fallo.
:::

::: vease
- [Unidades suspendibles](#tareas.suspendible)
- [Canales](#tareas.canales)
- [Inmutable y transferible](#tipos.inmutable)
:::

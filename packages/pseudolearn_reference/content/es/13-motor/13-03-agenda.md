---
id: motor.agenda
numero: "13.3"
tipo: motor
titulo: La agenda de tareas
anclas: [ENG.TASK.AGENDA#R1, ENG.TASK.AGENDA#R2, ENG.TASK.AGENDA#R3, ENG.TASK.AGENDA#R4, ENG.TASK.AGENDA#R5, ENG.TASK.AGENDA#R6, ENG.TASK.AGENDA#R7]
diagnosticos: [taskDeadlock]
terminos: [agenda, cola de listas, bloqueo]
---

::: frase
Las tareas no corren a la vez de verdad: una **agenda** determinista decide cuál avanza, y por eso cada ejecución sigue siempre el mismo orden.
:::

## Cómo funciona {#funciona}

Solo una tarea se ejecuta en cada momento. Las demás están **listas** (en una cola), **suspendidas** (esperando algo) o **terminadas**.

- La tarea raíz tiene identidad 0; cada `Lanzar` asigna la siguiente: 1, 2, 3…
- La cola de listas es FIFO: las nuevas, las despertadas y las que ceden entran al final.
- Cuando la tarea actual se suspende o termina, se reanuda la primera de la cola. `Lanzar` no desplaza al padre.
- Para que ninguna acapare el turno, una tarea que ejecuta 1024 sentencias seguidas dentro de un bucle suspendible cede su lugar.

```figura id=agenda-cola
pie: La agenda con la tarea en marcha, la cola de listas y las suspendidas. Al suspenderse la actual, entra la primera de la cola.
```

```programa id=turnos titulo="El orden de los turnos" ejecutar
SubProceso Suspendible Contar(nombre Como Cadena, canal Como Canal<Entero>)
  Para i <- 1 Hasta 2 Hacer
    Escribir nombre, " ", i;
    Si NO Aguardar canal.Enviar(i) Entonces
      Retornar;
    FinSi
  FinPara
FinSubProceso

Algoritmo Turnos
  Definir canal Como Canal<Entero> <- Canal(4);
  Tareas
    Lanzar Contar("A", canal);
    Lanzar Contar("B", canal);
    Escribir "padre";
  FinTareas
FinAlgoritmo
```

```salida
padre
A 1
A 2
B 1
B 2
```

El padre escribe primero porque `Lanzar` no lo detiene. En `FinTareas` se suspende y entra A, la primera de la cola. Como el canal tiene sitio, `Enviar` no suspende a A, que termina antes de que entre B.

## Bloqueo {#bloqueo}

Si no queda ninguna tarea lista y ningún efecto pendiente puede despertar a alguna, la ejecución termina con `taskDeadlock`:

```programa id=bloqueo titulo="Esperar algo que nunca llega" ejecutar termina=failed
SubProceso Suspendible Esperar(canal Como Canal<Entero>)
  Segun Aguardar canal.Recibir() Hacer
    Algo(valor): Escribir valor;
    Nada: Escribir "cerrado";
  FinSegun
FinSubProceso

Algoritmo Bloqueo
  Definir canal Como Canal<Entero> <- Canal(1);
  Tareas
    Lanzar Esperar(canal);
  FinTareas
FinAlgoritmo
```

```diagnosticos
taskDeadlock
```

::: resumen
- Una sola tarea avanza; las demás esperan en una cola FIFO.
- Las identidades de tarea crecen desde 0 sin reutilizarse.
- Sin tareas listas ni efectos pendientes, la ejecución termina con `taskDeadlock`.
:::

::: vease
- [Ámbitos de tareas](#tareas.ambitos)
- [Canales](#tareas.canales)
- [Determinismo](#vision.determinismo)
:::

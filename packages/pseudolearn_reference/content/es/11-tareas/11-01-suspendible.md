---
id: tareas.suspendible
numero: "11.1"
tipo: concepto
titulo: "Unidades suspendibles y `Aguardar`"
anclas: [LANG.TASK.SUSPENSION#R1, LANG.TASK.SUSPENSION#R2, LANG.TASK.SUSPENSION#R3, LANG.TASK.SUSPENSION#R4, LANG.TASK.SUSPENSION#R5, LANG.TASK.SUSPENSION#R6, LANG.TASK.SUSPENSION#R7, LANG.TASK.SUSPENSION#R8]
diagnosticos: [suspendibleCallWithoutAwait, awaitOutsideSuspendible, awaitOperandInvalid, suspendibleModifierNotAllowed, suspendibleAsValue, awaitInsideDefer]
terminos: [suspensión, espera]
---

::: frase
Una unidad `Suspendible` puede pausarse a mitad de camino mientras espera algo; `Aguardar` marca en el código cada punto donde esa pausa puede ocurrir.
:::

## Cómo funciona {#funciona}

`SubProceso Suspendible` declara un subprograma que **puede suspenderse**: dejar de ejecutarse un momento mientras espera a otra tarea, a un canal o a un efecto del anfitrión. El algoritmo principal es suspendible sin necesidad de marcarlo.

Cada llamada a una unidad suspendible tiene que ir precedida por `Aguardar`. Así, leyendo el código, se ve exactamente dónde puede pausarse el programa: en ningún otro sitio.

```figura id=aguardar-pausa
pie: La tarea avanza hasta `Aguardar`, se pausa mientras otra trabaja y continúa con el resultado. Fuera de los puntos marcados nunca se interrumpe.
```

```programa id=sin-aguardar titulo="Una llamada suspendible sin Aguardar" ejecutar
SubProceso Suspendible Doble(n Como Entero) Como Entero
  Retornar n * 2;
FinSubProceso

Algoritmo SinAguardar
  Escribir Doble(2);
FinAlgoritmo
```

```diagnosticos
suspendibleCallWithoutAwait
```

`Aguardar` puede ir en cualquier posición de una expresión. Lo calculado antes de la espera se conserva.

::: limite
- `Suspendible` no se admite en `Funcion`, métodos, constructores ni funciones literales.
- Una unidad suspendible no es un valor: no se puede guardar ni pasar como función.
- `Aguardar` solo acepta una llamada a una unidad suspendible o una operación de una capacidad; dentro de `Diferir` está prohibido.
:::

::: resumen
- `Suspendible` declara una unidad que puede pausarse.
- Cada punto de pausa se marca con `Aguardar`.
- Entre dos `Aguardar`, una tarea no se interrumpe.
:::

::: vease
- [Ámbitos de tareas](#tareas.ambitos)
- [Canales](#tareas.canales)
- [Agenda del motor](#motor.agenda)
:::

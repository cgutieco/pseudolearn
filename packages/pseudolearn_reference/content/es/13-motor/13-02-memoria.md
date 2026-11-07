---
id: motor.memoria
numero: "13.2"
tipo: motor
titulo: Memoria y recolector
anclas: [MEM.MANAGED.UNOBSERVABLE#R1, MEM.MANAGED.UNOBSERVABLE#R2, MEM.MANAGED.UNOBSERVABLE#R3, ENG.TASK.MEMORY#R1, ENG.TASK.MEMORY#R2, ENG.TASK.MEMORY#R3]
terminos: [montón, recolector, alcanzabilidad]
---

::: frase
Los objetos, arreglos y textos creados al ejecutar viven en el **montón**, y el recolector recupera los que nadie puede alcanzar sin que el programa lo note nunca.
:::

## Cómo funciona {#funciona}

Un valor está **vivo** si se puede llegar a él desde una variable de algún marco activo. Cuando ya no se puede, su memoria se puede recuperar. El programa **no puede observar** cuándo ni si ocurre: no hay finalizadores, ni referencias débiles, ni consultas de memoria libre.

```figura id=alcanzables
pie: Desde las variables de los marcos se llega a dos objetos; el tercero ya no tiene camino y el recolector puede reutilizar su memoria.
```

La prueba de que es inobservable es fuerte: ejecutar un programa recolectando en **cada** creación de valor, o no recolectando nunca, da exactamente la misma salida, la misma terminación y la misma traza.

Un valor alcanzable solo desde variables cuyo bloque terminó —el cuerpo de un bucle, una rama— deja de contar para el [límite de celdas](#motor.limites) en cuanto ese bloque termina.

```programa id=basura titulo="Objetos que se crean y se olvidan" ejecutar
Clase Caja
  Definir valor Como Entero;
FinClase

Algoritmo Basura
  Definir total Como Entero <- 0;
  Para i <- 1 Hasta 1000 Hacer
    Definir c Como Caja <- Nuevo Caja();
    c.valor <- i;
    total <- total + c.valor;
  FinPara
  Escribir total;
FinAlgoritmo
```

```salida
500500
```

Cada vuelta crea una caja que deja de ser alcanzable al terminar la vuelta. Las tareas suspendidas también son raíces: lo que guardan sus marcos, sus resultados pendientes y los mensajes de los canales sigue vivo mientras haga falta.

::: resumen
- Los valores creados al ejecutar viven en el montón.
- Lo que no se puede alcanzar se recupera, sin efecto observable.
- Recolectar siempre o nunca da la misma ejecución.
:::

::: vease
- [Copia, referencias e identidad](#objetos.copia)
- [Límites del motor](#motor.limites)
:::

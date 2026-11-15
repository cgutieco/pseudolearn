---
id: motor.limites
numero: "13.6"
tipo: motor
titulo: Límites del motor
anclas: [ENG.LIMITS#R1, ENG.LIMITS#R2, ENG.LIMITS#R3, ENG.LIMITS#R4, ENG.LIMITS#R5, ENG.LIMITS#R6, ENG.LIMITS#R7, ENG.LIMITS#R8, ENG.LIMITS#R9, ENG.LIMITS#R10, ENG.LIMITS#R11, ENG.LIMITS#R12, ENG.LIMITS#R13]
diagnosticos: [recursionDepthExceeded, cellLimitExceeded, statementBudgetExhausted, taskLimitExceeded, channelCapacityExceeded]
terminos: [límite, presupuesto, celda]
---

::: frase
Los límites son recursos que fija quien ejecuta el programa —profundidad, sentencias, memoria, tiempo— y no forman parte del lenguaje: un programa que no los alcanza da el mismo resultado con cualquier configuración.
:::

## Cómo funciona {#funciona}

| Límite | Se mide en | Al agotarlo |
|---|---|---|
| profundidad | marcos activos | fallo `recursionDepthExceeded` |
| celdas | valores vivos del montón | fallo `cellLimitExceeded` |
| sentencias | entradas a sentencia | corte `statementBudgetExhausted` |
| tiempo | reloj del anfitrión | corte sin diagnóstico |
| tareas vivas | tareas lanzadas y sin terminar | fallo `taskLimitExceeded` |

Las unidades son **deterministas**: no dependen de la máquina. Un objeto ocupa una celda más una por atributo; un arreglo, una más una por elemento; un texto creado al ejecutar, una más una por cada ocho caracteres. Los literales y lo que `Escribir` saca no ocupan celdas.

```figura id=limites-recursos
pie: Cuatro recursos con su tope. Agotar profundidad o celdas es un fallo del programa; agotar sentencias o tiempo es un corte por límite.
```

```programa id=profundo titulo="Una recursión que agota la profundidad" ejecutar termina=failed
SubProceso Bajar(n Como Entero) Como Entero
  Retornar Bajar(n + 1) + 1;
FinSubProceso

Algoritmo Profundo
  Escribir Bajar(0);
FinAlgoritmo
```

```diagnosticos
recursionDepthExceeded
```

::: limite
- Todo anfitrión admite al menos 1000 marcos y 4194304 celdas.
- La app usa 1000 marcos; la terminal, 100000 y sin presupuesto de sentencias.
- Ningún límite agota la pila del anfitrión ni produce un fallo interno.
- Los límites de red y de JSON no terminan el programa: llegan como valores de error.
:::

::: resumen
- Los límites los configura el anfitrión; no son parte del lenguaje.
- Se miden en unidades deterministas.
- Profundidad y celdas fallan; sentencias y tiempo cortan.
:::

::: vease
- [Recursión](#subprogramas.recursion)
- [Memoria y recolector](#motor.memoria)
:::

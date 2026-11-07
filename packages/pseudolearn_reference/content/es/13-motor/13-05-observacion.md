---
id: motor.observacion
numero: "13.5"
tipo: motor
titulo: Observar la ejecución
anclas: [ENG.TRACE.STEP#R1, ENG.TRACE.STEP#R2, ENG.TRACE.STEP#R3, ENG.TRACE.STEP#R4, ENG.STATE.INCREMENTAL#R1, ENG.STATE.INCREMENTAL#R2, ENG.STATE.INCREMENTAL#R3]
terminos: [traza, paso, evento]
---

::: frase
La ejecución se puede mirar paso a paso: el motor emite una **traza** de eventos, y cada evento lleva lo que cambió en la memoria.
:::

## Cómo funciona {#funciona}

Un **paso** es el intervalo entre dos eventos consecutivos de la traza: entrar en una sentencia, tomar una decisión, escribir, llamar, volver. Avanzar un paso entrega exactamente el evento siguiente; no hay nada más pequeño.

Sobre los eventos se construyen los avances del depurador:

| Avance | Hasta |
|---|---|
| siguiente sentencia | la próxima sentencia del mismo marco o de uno exterior |
| entrar | la próxima sentencia, aunque sea dentro de una llamada |
| salir | el retorno que cierra el marco actual |

```figura id=traza-pasos
pie: Cada evento de la traza es un paso. El estado de memoria de cualquier evento se reconstruye acumulando los cambios desde el principio.
```

```programa id=observar titulo="Un programa para mirar" ejecutar
Algoritmo Observar
  Definir n Como Entero <- 3;
  Si n > 2 Entonces
    Escribir "grande";
  FinSi
FinAlgoritmo
```

```salida
grande
```

```traza programa=observar
```

Cada evento puede llevar el **cambio de estado**: variables escritas, objetos creados, marcos apilados o retirados. Sumar los cambios desde el principio da el estado completo en cualquier evento, y volver a consultar un evento pasado da siempre lo mismo. Los eventos se entregan por lotes del tamaño que prefiera el anfitrión, sin pérdidas ni duplicados.

::: resumen
- La traza es la lista de eventos; un paso es un evento.
- Siguiente, entrar y salir se definen sobre eventos.
- Los cambios de estado reconstruyen la memoria en cualquier punto.
:::

::: vease
- [Las capas del motor](#motor.capas)
- [Límites del motor](#motor.limites)
:::

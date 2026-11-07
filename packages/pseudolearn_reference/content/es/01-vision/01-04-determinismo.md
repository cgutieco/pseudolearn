---
id: vision.determinismo
numero: "1.4"
tipo: concepto
titulo: "Determinismo: el mismo programa da siempre lo mismo"
anclas: [ENG.EXEC.MODEL#R2, MEM.MANAGED.UNOBSERVABLE#R2, LIB.CORE.RANDOM#R1]
terminos: [determinismo, semilla]
---

::: frase
Con el mismo programa, las mismas entradas y la misma semilla, el motor produce siempre la misma salida, en cualquier ordenador.
:::

## Cómo funciona {#funciona}

Un programa es **determinista** si cada vez que lo ejecutas pasa exactamente lo mismo. En PseudoLearn esto es una garantía: la salida, la forma de terminar, los diagnósticos y la traza son idénticos en un teléfono, en un portátil o en el navegador.

Para que eso sea posible, el motor controla todo lo que podría variar:

- El **azar** sale de una fuente con **semilla**. Misma semilla, misma secuencia de números.
- Las **tareas** concurrentes avanzan por turnos en un orden fijo.
- El **reloj**, los archivos y la red se piden como capacidades y se pueden grabar y reproducir.
- La **memoria** se recupera sin que el programa pueda notarlo.

```figura id=determinismo
pie: Dos ejecuciones con la misma semilla producen la misma secuencia. Cambiar la semilla cambia los números, no las reglas.
```

Esta especificación se construye siempre con la semilla 42. Por eso este programa escribe los mismos números cada vez:

```programa id=dados titulo="Tres tiradas de dado" ejecutar
Proceso Dados
  Escribir Aleatorio(1, 6), " ", Aleatorio(1, 6), " ", Aleatorio(1, 6);
FinProceso
```

```salida
1 1 6
```

::: analogia
Una semilla es como el orden en que se baraja una baraja: si dos personas barajan exactamente igual, sacan las mismas cartas. La analogía deja de valer en que el motor no baraja nada; calcula cada número a partir del anterior.
:::

::: resumen
- Mismo programa, mismas entradas y misma semilla: mismo resultado.
- El azar sale de una fuente con semilla.
- Tareas, reloj, archivos y red se controlan para no romper el determinismo.
- La recuperación de memoria no es observable.
:::

::: vease
- [Azar con semilla](#biblioteca.azar)
- [Agenda de tareas](#motor.agenda)
- [Efectos, anfitrión y cinta](#motor.efectos)
:::

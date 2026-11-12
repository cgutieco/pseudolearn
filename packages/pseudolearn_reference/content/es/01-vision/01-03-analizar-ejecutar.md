---
id: vision.analizar-ejecutar
numero: "1.3"
tipo: concepto
titulo: Analizar, ejecutar y observar
anclas: [LANG.TYPES.CHECKING-LEVELS#R1, ENG.TRACE.EVENTS#R1, ENG.STATE.SNAPSHOT#R1]
terminos: [análisis, ejecución, observación]
---

::: frase
El motor hace tres trabajos distintos con un programa: analizarlo sin ejecutarlo, ejecutarlo y dejar que observes lo que ocurre por dentro.
:::

## Cómo funciona {#funciona}

**Analizar** es leer el programa sin ejecutarlo. El editor lo hace cada vez que escribes: colorea las palabras, señala errores y ofrece ayuda. Analizar nunca cambia nada ni escribe en la salida.

**Ejecutar** es recorrer las instrucciones de verdad. El resultado es la salida, la forma en que terminó el programa y, si algo falló, el diagnóstico de ejecución.

**Observar** es ejecutar dejando rastro. El motor registra cada suceso importante (entra en una sentencia, toma una decisión, escribe algo) y guarda el estado de la memoria. Con ese rastro el editor dibuja la ejecución paso a paso.

```figura id=tres-trabajos
pie: Tres trabajos con el mismo programa. Cada uno produce algo distinto; solo ejecutar y observar recorren las instrucciones.
```

Este programa se analiza sin errores, se ejecuta y deja una traza con una decisión:

```programa id=par titulo="¿Par o impar?" ejecutar
Algoritmo Paridad
  Definir numero Como Entero <- 14;
  Si numero mod 2 = 0 Entonces
    Escribir numero, " es par";
  Sino
    Escribir numero, " es impar";
  FinSi
FinAlgoritmo
```

```salida
14 es par
```

::: por-dentro
Esta es la traza que produjo el motor al observar `Paridad`. Cada línea es un suceso con la línea del programa donde ocurrió:

```traza programa=par
```
:::

::: resumen
- Analizar: leer sin ejecutar; produce colores, errores y ayuda.
- Ejecutar: recorrer las instrucciones; produce salida y terminación.
- Observar: ejecutar dejando traza y estados de memoria.
:::

::: vease
- [El viaje de un programa](#vision.viaje)
- [Observación: traza, puntos de control y línea de tiempo](#motor.observacion)
:::

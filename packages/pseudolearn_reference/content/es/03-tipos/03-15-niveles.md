---
id: tipos.niveles
numero: "3.15"
tipo: concepto
titulo: Niveles de comprobación
anclas: [LANG.TYPES.CHECKING-LEVELS#R1, DIAG.CLASSES#R1]
diagnosticos: [divisionByZero, incompatibleTypesInAssignment]
terminos: [comprobación estática, comprobación dinámica]
---

::: frase
El motor comprueba todo lo que puede antes de ejecutar; lo que depende de valores concretos, como dividir entre cero, lo comprueba al ejecutar.
:::

## Cómo funciona {#funciona}

Hay dos momentos para descubrir un problema:

- **Antes de ejecutar** (comprobación estática): la forma del programa, que los nombres existan y que los tipos encajen. Si algo falla aquí, el programa no se ejecuta.
- **Al ejecutar** (comprobación dinámica): lo que depende del valor real en ese momento, como dividir entre cero, salirse de un arreglo o leer una variable sin valor.

```figura id=niveles
pie: Qué se comprueba en cada momento. Cuanto antes se descubre un error, más barato es arreglarlo.
```

Este programa es correcto para el análisis, porque dividir dos enteros tiene sentido. Pero al ejecutar, el divisor vale cero:

```programa id=dividir-cero titulo="Correcto al analizar, falla al ejecutar" ejecutar termina=failed
Proceso DividirCero
  Definir edad Como Entero <- 10;
  Definir divisor Como Entero <- 0;
  Escribir edad div divisor;
FinProceso
```

```diagnosticos
divisionByZero
```

En cambio, guardar un texto en una variable entera se descubre sin ejecutar nada:

```programa id=tipo-mal titulo="Un error que se ve antes" ejecutar
Proceso TipoMal
  Definir edad Como Entero <- "diez";
FinProceso
```

```diagnosticos
incompatibleTypesInAssignment
```

## Un fallo nunca es silencioso {#controlado}

Cuando una comprobación dinámica falla, el programa no sigue con un valor inventado: se detiene en esa sentencia con un diagnóstico que dice qué pasó y dónde. Los fallos esperables del mundo exterior, como un archivo que no existe, no detienen el programa: se devuelven como `Resultado` para que el programa decida.

::: resumen
- Antes de ejecutar se comprueban forma, nombres y tipos.
- Al ejecutar se comprueban los valores concretos.
- Un fallo de ejecución detiene el programa con un diagnóstico preciso.
- Los fallos esperables del exterior llegan como `Resultado`.
:::

::: vease
- [Errores, advertencias y fallos](#vision.errores)
- [Orden de los efectos y la cinta](#motor.efectos)
:::

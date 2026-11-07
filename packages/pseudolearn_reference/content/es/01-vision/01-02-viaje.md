---
id: vision.viaje
numero: "1.2"
tipo: concepto
titulo: "El viaje de un programa: del texto a la ejecución"
anclas: [ENG.EXEC.MODEL#R1, IR.LOWERING#R2, LANG.TYPES.CHECKING-LEVELS#R1]
terminos: [token, árbol sintáctico, representación intermedia, bytecode, máquina virtual]
---

::: frase
Antes de ejecutar un programa, el motor lo parte en piezas, comprueba que tiene sentido y lo traduce a instrucciones simples para su máquina virtual.
:::

## Cómo funciona {#funciona}

Cuando pulsas «Ejecutar», el texto del programa recorre un camino de cinco etapas. Cada etapa produce algo nuevo a partir de lo anterior. Avanza por la figura para seguir el programa `Doble` en su viaje.

```programa id=doble titulo="El programa que viaja" ejecutar
Proceso Doble
  Definir n Como Entero <- 21;
  Escribir n * 2;
FinProceso
```

```salida
42
```

```figura id=viaje
pie: Las cinco etapas del motor. Las tres primeras ocurren antes de ejecutar nada; si alguna encuentra errores, el programa no llega a ejecutarse.
paso: **Análisis léxico.** El texto se parte en piezas llamadas tokens: `Proceso`, `Doble`, `Definir`, `n`, `Como`, `Entero`… Los espacios y los comentarios se guardan aparte.
paso: **Análisis sintáctico.** Los tokens se agrupan en un árbol: un proceso que contiene una definición y una escritura.
paso: **Análisis semántico.** El motor comprueba los nombres y los tipos: `n` existe, es un `Entero` y `n * 2` también lo es.
paso: **Traducción.** El árbol se convierte en una representación intermedia y luego en instrucciones simples para la máquina virtual.
paso: **Ejecución.** La máquina virtual ejecuta las instrucciones una a una y escribe 42.
panel Etapa 1: tokens
panel Etapa 2: árbol
panel Etapa 3: tipos comprobados
panel Etapa 4: instrucciones
panel Salida 5: 42
```

## Primero comprobar, después ejecutar {#comprobar}

Las tres primeras etapas forman el **análisis**. Si encuentran un error, el programa no se ejecuta: no tendría sentido ejecutar algo que no se entiende. Por eso un error de escritura se ve de inmediato, sin esperar a que el programa llegue a esa línea.

Hay errores que el análisis no puede ver porque dependen de los valores reales: dividir entre cero, salirse de un arreglo o leer una variable sin valor. Esos se detectan al ejecutar, en el momento exacto en que ocurren.

::: por-dentro
Esta es la representación intermedia real del programa `Doble`. Cada línea es una instrucción sencilla; `stmt.enter` y `stmt.exit` marcan dónde empieza y termina cada sentencia, que es lo que permite ejecutar paso a paso.

```ri programa=doble
```
:::

::: resumen
- El motor trabaja en cinco etapas: léxico, sintaxis, semántica, traducción y ejecución.
- Si el análisis encuentra errores, el programa no se ejecuta.
- Los errores que dependen de valores concretos aparecen al ejecutar.
:::

::: vease
- [Analizar, ejecutar y observar](#vision.analizar-ejecutar)
- [Mapa de capas del motor](#motor.capas)
- [Representación intermedia](#motor.ri)
:::

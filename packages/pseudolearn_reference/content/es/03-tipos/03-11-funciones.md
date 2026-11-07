---
id: tipos.funciones
numero: "3.11"
tipo: tipo
titulo: Funciones como valores
anclas: [LANG.TYPES.FUNCTION#R1]
fichas: [help.function-literal]
diagnosticos: [mutableClosureCapture]
terminos: [función, clausura, captura]
---

::: frase
Un subprograma también es un valor: se puede guardar en una variable, pasar como argumento o devolver, y llamarlo después.
:::

## Cómo se escribe {#escribe}

```forma
Definir «nombre» Como SubProceso(«tipos de parámetros») Como «tipo de retorno»
SubProceso(«parámetros») Como «tipo de retorno»
  «instrucciones»
FinSubProceso
```

```railes produccion=functionType
```

## Cómo funciona {#funciona}

El tipo de una función describe sus parámetros y su retorno, por ejemplo `SubProceso(Entero) Como Entero`. Cualquier subprograma con esa forma es un valor de ese tipo. Una variable de tipo función se llama como si fuera el propio subprograma.

```programa id=aplicar titulo="Guardar un subprograma en una variable" ejecutar
SubProceso doble(x Como Entero) Como Entero
  Retornar x * 2;
FinSubProceso
SubProceso aplicar(f Como SubProceso(Entero) Como Entero, valor Como Entero) Como Entero
  Retornar f(valor);
FinSubProceso
Proceso Aplicar
  Definir operacion Como SubProceso(Entero) Como Entero <- doble;
  Escribir operacion(4), " ", aplicar(doble, 10);
FinProceso
```

```salida
8 20
```

## Funciones sin nombre y clausuras {#clausuras}

Una función puede escribirse en el sitio, sin nombre: `SubProceso(x Como Entero) Como Entero … FinSubProceso`. Si usa variables de fuera, las **captura**: se lleva una copia de su valor. Esa función con sus copias se llama **clausura**.

```programa id=multiplicador titulo="Fábrica de multiplicadores" ejecutar
SubProceso multiplicador(factor Como Entero) Como SubProceso(Entero) Como Entero
  Retornar SubProceso(x Como Entero) Como Entero
    Retornar x * factor;
  FinSubProceso;
FinSubProceso
Proceso Clausuras
  Definir doble Como SubProceso(Entero) Como Entero <- multiplicador(2);
  Definir triple Como SubProceso(Entero) Como Entero <- multiplicador(3);
  Escribir doble(5), " ", triple(5);
FinProceso
```

```salida
10 15
```

```figura id=clausura
pie: Cada clausura se lleva su propia copia de `factor`. Por eso `doble` y `triple` no se pisan.
```

::: limite
- Solo se pueden capturar variables que nunca se reasignan después de recibir su valor: así la copia y el original no pueden divergir.
- Los parámetros por referencia no se pueden capturar.
- Las funciones no se escriben, no se comparan y no cruzan entre tareas.
:::

::: errores
Capturar una variable que después cambia es un error, porque la clausura vería un valor y el resto del programa otro:

```programa id=captura-mutable titulo="Capturar algo que cambia" ejecutar
Proceso CapturaMutable
  Definir n Como Entero <- 1;
  Definir f Como SubProceso() Como Entero <- SubProceso() Como Entero
    Retornar n;
  FinSubProceso;
  n <- 2;
  Escribir f();
FinProceso
```

```diagnosticos
mutableClosureCapture
```
:::

::: por-dentro
Una clausura es un objeto en el montón con el código de la función y un **entorno** con las copias capturadas. El entorno sobrevive al subprograma que lo creó mientras alguien pueda llamar a la clausura, y el recolector lo libera cuando ya nadie puede.

```ri programa=multiplicador
```
:::

::: resumen
- Un subprograma es un valor de tipo `SubProceso(parámetros) Como retorno`.
- Se puede guardar, pasar, devolver y llamar.
- Una función sin nombre captura copias de las variables que usa.
- Solo se capturan variables que no cambian.
:::

::: vease
- [Declaración de subprogramas](#subprogramas.declaracion)
- [Genéricos](#tipos.genericos)
:::

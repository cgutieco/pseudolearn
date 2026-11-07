---
id: tipos.arreglos
numero: "3.4"
tipo: tipo
titulo: Arreglos
anclas: [LANG.TYPES.ARRAY#R1, LANG.ARRAY.DIMENSION#R1, LANG.ARRAY.ACCESS#R1]
fichas: [help.arrays, help.array-access]
diagnosticos: [arrayIndexOutOfRange, arrayDimensionCountMismatch, negativeArraySize, arrayCannotBeUsedAsValue, dimensionWithoutType]
terminos: [arreglo, índice, dimensión]
---

::: frase
Un arreglo es una fila (o una tabla) de casillas del mismo tipo, con un tamaño fijo y numeradas desde cero.
:::

## Cómo se escribe {#escribe}

```forma
Dimension «nombre»[«tamaño»] Como «tipo»
Dimension «nombre»[«filas», «columnas»] Como «tipo»
«nombre»[«índice»] <- «valor»
```

```railes produccion=dimensionDeclaration
```

## Cómo funciona {#funciona}

`Dimension` crea el arreglo y sus casillas de una vez. Cada casilla se usa como una variable: se le asigna un valor y se lee con el nombre y el índice entre corchetes. Los índices empiezan en **cero**: un arreglo de tamaño 3 tiene las casillas 0, 1 y 2.

```figura id=arreglo-casillas
pie: Un arreglo de tamaño 4 tiene las casillas 0 a 3. La casilla 4 no existe.
```

```programa id=notas titulo="Las notas de la semana" ejecutar
Algoritmo Notas
  Dimension notas[4] Como Entero;
  notas[0] <- 7;
  notas[1] <- 9;
  notas[2] <- 6;
  notas[3] <- 8;
  Definir suma Como Entero <- 0;
  Para i <- 0 Hasta 3 Hacer
    suma <- suma + notas[i];
  FinPara
  Escribir "Media: ", suma / 4;
FinAlgoritmo
```

```salida
Media: 7.5
```

Un arreglo puede tener varias **dimensiones**. Una tabla de 2 filas y 3 columnas se declara con dos tamaños y cada casilla se nombra con dos índices dentro de los mismos corchetes:

```programa id=tabla titulo="Una tabla de multiplicar pequeña" ejecutar
Algoritmo Tabla
  Dimension tabla[2, 3] Como Entero;
  Para f <- 0 Hasta 1 Hacer
    Para c <- 0 Hasta 2 Hacer
      tabla[f, c] <- (f + 1) * (c + 1);
    FinPara
  FinPara
  Escribir tabla[0, 2], " ", tabla[1, 2];
FinAlgoritmo
```

```salida
3 6
```

## Dimensionar en dos pasos {#dos-pasos}

El pseudocódigo clásico declara primero la variable con `Definir` y después la dimensiona con `Dimension` sin repetir el tipo. PseudoLearn lo admite si entre las dos sentencias no se usa la variable.

## Un arreglo no es un valor {#no-valor}

Un arreglo entero no se puede asignar, comparar, escribir ni devolver. Solo sus casillas son valores. Para pasarlo entero a un subprograma se usa un parámetro de tipo arreglo, que comparte las casillas.

::: limite
- Índices: enteros desde 0 hasta tamaño − 1 en cada dimensión.
- Tamaño 0: válido (un arreglo sin casillas). Tamaño negativo: `negativeArraySize`.
- Los tamaños se calculan al ejecutar, así que pueden ser expresiones.
- No hay máximo fijado por el lenguaje; el límite lo pone la memoria disponible del motor.
:::

::: errores
Salirse del arreglo detiene el programa en ese acceso:

```programa id=fuera titulo="La casilla que no existe" ejecutar termina=failed
Algoritmo Fuera
  Dimension v[3] Como Entero;
  v[3] <- 1;
FinAlgoritmo
```

```diagnosticos
arrayIndexOutOfRange
```

Usar un número de índices distinto del de dimensiones se detecta antes de ejecutar:

```programa id=indices titulo="Un índice de menos" ejecutar
Algoritmo Indices
  Dimension m[2, 2] Como Entero;
  m[0] <- 1;
FinAlgoritmo
```

```diagnosticos
arrayDimensionCountMismatch
```

Y un arreglo completo no puede escribirse:

```programa id=escribir-arreglo titulo="Escribir el arreglo entero" ejecutar
Algoritmo EscribirArreglo
  Dimension v[2] Como Entero;
  v[0] <- 1;
  v[1] <- 2;
  Escribir v;
FinAlgoritmo
```

```diagnosticos
arrayCannotBeUsedAsValue
```
:::

::: por-dentro
En la representación intermedia, el acceso a una casilla es una instrucción que comprueba el índice antes de leer o escribir. Si el índice no está en rango, la instrucción produce la trampa `arrayIndexOutOfRange` con la posición exacta del acceso.

```ri programa=tabla
```
:::

::: docentes
El error clásico es recorrer de 1 a N en lugar de 0 a N − 1. Pide escribir el bucle de `notas` con `Para i <- 1 Hasta 4` y comenta el fallo que produce: el mensaje dice qué índice y qué tamaño.
:::

::: resumen
- `Dimension` crea un arreglo de tamaño fijo con casillas del mismo tipo.
- Los índices van de 0 a tamaño − 1; varios índices van en los mismos corchetes.
- Salirse del rango es un fallo de ejecución.
- Un arreglo entero no es un valor: no se asigna, compara ni escribe.
:::

::: vease
- [Vectores](#tipos.vectores)
- [Para](#control.para)
- [Parámetros](#subprogramas.parametros)
:::

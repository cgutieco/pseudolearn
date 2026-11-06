# Declaración y asignación

Una declaración introduce uno o varios nombres y les fija un tipo; con un único nombre puede darle
además su valor inicial. Una asignación guarda un valor nuevo en una variable ya declarada.

## Varios nombres en una declaración

Una declaración puede introducir varios nombres del mismo tipo, separados por comas. El valor inicial
después de la flecha solo se admite cuando la declaración tiene un único nombre.

{{ejemplo:example-esp-declaracion-multiple}}

## Sin valor no se puede leer

Una variable declarada sin valor inicial existe, pero todavía no tiene valor: el lenguaje no inventa un
cero ni una cadena vacía, y un valor que nadie escribió no es un valor. Leerla antes de que todos los
caminos que llegan a ese punto le hayan dado uno es un error que se detecta antes de ejecutar.

```pseudo
Algoritmo SinInicializar
  Definir x Como Entero;
  Escribir x;
FinAlgoritmo
```

{{diagnostico:variableUsedUninitialized}}

## Reasignar una variable

`Definir` crea variables que se pueden reasignar tantas veces como haga falta. No se pueden reasignar la
variable de control de `Para`, que pertenece al bucle, ni los nombres que introducen `Para Cada`, los
patrones de `Segun` sobre variantes y las tareas.

```pseudo
Algoritmo ReasignarControl
  Para i <- 1 Hasta 3 Hacer
    i <- 5;
  FinPara
FinAlgoritmo
```

{{diagnostico:controlVariableModified}}

## El destino de una asignación

A la izquierda de una asignación solo puede haber algo que denote un sitio donde guardar: un nombre de
variable, o un elemento de un arreglo, o un miembro de un objeto. Un literal, una expresión entre
paréntesis o el resultado de una operación no denotan ningún sitio, y escribirlos ahí es un error de
sintaxis con nombre propio.

```pseudo
Algoritmo DestinoInvalido
  10 <- 5
FinAlgoritmo
```

{{diagnostico:invalidAssignmentTarget}}

## Orden de evaluación

Primero se evalúan los índices del destino, en el orden en que aparecen; después la expresión de la
derecha; después se guarda el valor. Es el orden de lectura del texto, que es el único que se puede
predecir sin conocer el motor.

{{ejemplo:example-esp-declaracion-orden-evaluacion}}

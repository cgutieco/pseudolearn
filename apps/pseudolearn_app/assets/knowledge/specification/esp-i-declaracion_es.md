# Declaración y asignación

Una declaración introduce un nombre, le fija un tipo y le da su valor inicial. Una asignación guarda un
valor nuevo en un nombre que se declaró como mutable.

## Un nombre por declaración

Cada declaración introduce un solo nombre con su tipo y su valor. Para tener varias variables se
escribe una declaración por cada una.

{{ejemplo:example-esp-declaracion-multiple}}

## Toda declaración lleva su valor inicial

Un nombre declarado sin valor no existe: el lenguaje no inventa un cero ni una cadena vacía, y un valor
que nadie escribió no es un valor. Por eso la declaración exige el valor inicial después de la flecha, y
un nombre nunca se puede leer antes de tenerlo.

```pseudo
Algoritmo SinInicializar
  Definir x Como Entero
  Escribir x
FinAlgoritmo
```

{{diagnostico:missingBindingInitializer}}

## Inmutable por omisión, mutable por elección

`Definir` crea un vínculo que no se puede reasignar. Si el programa necesita cambiar el valor, lo dice en
la declaración con `Mutable`. Un vínculo mutable que nunca se modifica es una advertencia, porque la
palabra no se estaría usando.

```pseudo
Algoritmo ReasignarInmutable
  Definir x Como Entero <- 5
  x <- 6
FinAlgoritmo
```

{{diagnostico:immutableBindingAssignment}}

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

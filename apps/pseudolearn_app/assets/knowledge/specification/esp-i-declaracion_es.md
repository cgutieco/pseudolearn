# Declaración y asignación

Una declaración introduce un nombre y le fija un tipo. Una asignación guarda un valor en un nombre ya
introducido. Son dos sentencias distintas y no se pueden escribir juntas.

## Declarar varias variables a la vez

Una sola sentencia de declaración puede introducir varios nombres separados por comas. Todos reciben
el mismo tipo, que se escribe una sola vez al final.

{{ejemplo:example-esp-declaracion-multiple}}

## Declarar no da valor

Una variable declarada y no asignada no tiene valor por omisión, y leerla antes de asignarla es un
fallo. El lenguaje no inventa un cero ni una cadena vacía: un valor que nadie escribió no es un valor.

```pseudo
Algoritmo SinInicializar
  Definir x Como Entero
  Escribir x
FinAlgoritmo
```

{{diagnostico:variableUsedUninitialized}}

## Una declaración no admite valor inicial

El tipo se escribe al final de la declaración, así que un valor inicial tendría que colarse antes del
tipo y sería indistinguible de una asignación. La asignación ya es una sentencia de primera clase y
escribirla en la línea siguiente enseña exactamente lo mismo.

```pseudo
Algoritmo InicializacionEnDeclaracion
  Definir x Como Entero <- 5
FinAlgoritmo
```

{{diagnostico:initializationInDeclarationNotAllowed}}

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

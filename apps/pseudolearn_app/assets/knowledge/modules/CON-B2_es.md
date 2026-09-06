:::parte pregunta

Un algoritmo que solo calcula con números escritos en su propio texto resuelve un caso y ninguno más:
para sumar otros dos números hay que reescribirlo. Un programa útil recibe sus datos desde fuera y
entrega su resultado hacia fuera. Este módulo formaliza esas dos direcciones: cómo se pide un valor y
cómo se muestra.

:::parte modelo-maquina

Leer no inventa una casilla nueva: escribe en una que ya existía, exactamente igual que una asignación,
solo que el valor no viene del propio texto del programa sino de fuera. Escribir tampoco lee la
memoria del programa hacia una casilla propia: solo mira el valor que ya tiene una casilla, o el que
resulta de evaluar una expresión, y lo traduce a texto. Ninguna de las dos crea ni destruye una
casilla: piden o entregan lo que ya está.

:::parte desarrollo

## Leer: uno por uno, en el orden que se escriben

{{ejemplo:example-b2-lectura-multiple}}

Una sola sentencia {{lexema:read}} puede pedir varios valores, separados como los elementos de
cualquier lista, pero no los pide todos a la vez: los pide **de uno en uno**, en el orden en que
aparecen. El tipo que cada valor tiene que cumplir es el tipo del designador que lo recibe: pedir un
número entero para una casilla de texto no tiene sentido, y el motor vuelve a pedir el mismo valor
hasta que el que reciba corresponda.

## Escribir: una lista de expresiones, sin separador automático

{{ejemplo:example-b2-saludo}}

{{lexema:write}} admite una lista de expresiones que se evalúan una sola vez, de izquierda a derecha, y
se concatenan **sin ningún espacio ni separador que el lenguaje añada por su cuenta**. El espacio que
se quiera ver entre dos valores se escribe como una tercera expresión, un texto literal. Por defecto
cada {{lexema:write}} termina en un salto de línea; el modificador {{lexema:withoutNewline}}, escrito
siempre al final de la lista, lo suprime y dos escrituras consecutivas terminan en la misma línea.

## Un designador no es cualquier expresión

Lo que recibe un valor leído tiene que ser un nombre al que se le pueda asignar: una variable, no una
cuenta. `a + 1` es una expresión válida para escribir, pero no hay ninguna casilla en la que guardar el
resultado de sumarle uno a algo, así que no es un destino válido para leer.

:::parte prediccion

- example-b2-lectura-multiple#5#b Con las entradas 6 y 4, ¿qué valor tiene `b` justo después de que termine la sentencia `Leer a, b;`?

Antes de comprobarlo, decide en qué orden se piden `a` y `b`, y qué pasaría si a esa sentencia solo se
le diera un valor en vez de dos.

:::parte errores-frecuentes

## Leer hacia algo que no es un nombre

A la derecha de {{lexema:read}} tiene que haber un designador: un nombre en el que guardar el valor
que llega. Una cuenta no tiene dónde guardarse.

```pseudo
Algoritmo LecturaInvalida
    Definir n Como Entero;
    Leer n + 1;
FinAlgoritmo
```

{{diagnostico:invalidReadTarget}}

:::parte especificacion

- esp-i-entrada-salida Qué emite la salida, qué exige la lectura y cómo se escribe cada valor

:::parte ejercicios

- CON-B2-E1 Presentación con nombre y edad
- CON-B2-E2 Suma de dos valores en una sola lectura
- CON-B2-E3 Ficha de producto en una línea
- CON-B2-E4 Promedio de cuatro lecturas
- CON-B2-E5 Etiqueta y valor sin salto de línea
- CON-B2-E6 Conversión de temperatura con formato

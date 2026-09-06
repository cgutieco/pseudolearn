# Entrada y salida

Un programa que no comunica nada no se puede comprobar. Estas dos sentencias son la única frontera
entre el programa y quien lo ejecuta, y su forma está fijada al detalle porque de ella depende que un
caso de prueba pueda compararse carácter a carácter.

## La salida admite cero o más expresiones

Tras {{lexema:write}} va una lista de expresiones separadas por {{lexema:comma}}. La lista puede estar
**vacía**, y entonces la sentencia emite una línea en blanco. Las expresiones se evalúan de izquierda a
derecha y **una sola vez** cada una.

{{ejemplo:example-esp-io-salida-expresiones}}

## No hay separador automático

Los valores se emiten **concatenados, sin ningún espacio ni coma añadidos por el lenguaje**. El espacio
que se quiera ver se escribe en el programa, como un texto más de la lista. Es la regla que hace que la
salida de un programa sea exactamente lo que su texto dice y no lo que un formateador decida.

{{ejemplo:example-esp-io-separador}}

## El modificador sin salto va al final

{{lexema:withoutNewline}} es un **modificador de la sentencia de salida**, no una segunda instrucción.
Va en sufijo, después de la lista, y es opcional: ausente, se emite un salto de línea tras los valores;
presente, no se emite. Escribirlo antes de la lista o repetirlo es un error de sintaxis.

Que sea un modificador y no otra sentencia tiene tres consecuencias que se pueden comprobar: un solo
símbolo de salida en el ordinograma, un solo camino en el evaluador, y ningún par de construcciones
hermanas que puedan divergir al mantenerlas.

{{ejemplo:example-esp-io-sin-salto}}

## Cómo se escribe cada valor

El texto que emite la salida está fijado por el lenguaje y no lo decide la máquina donde se ejecuta.
Esto es lo que se emite para un valor de cada tipo:

- {{lexema:integerType}}: dígitos decimales, con signo menos si es negativo, y nunca un separador de
  millares.
- {{lexema:realType}}: notación posicional, sin exponente, con **al menos un dígito decimal** incluso
  cuando el valor no tiene parte fraccionaria.
- {{lexema:booleanType}}: el lexema del perfil activo para verdadero o para falso.
- {{lexema:characterType}}: el carácter, sin comillas.
- {{lexema:stringType}}: el contenido, sin comillas.

El texto que emite la salida y el que devuelve la función incorporada de conversión a cadena son el
mismo, producidos por la misma pieza. Que difirieran sería la clase de incoherencia que ningún
ejercicio detecta hasta que alguien la cruza.

{{ejemplo:example-esp-io-valores}}

## La lectura exige al menos un designador

Tras {{lexema:read}} va **uno o más** designadores separados por {{lexema:comma}}. A diferencia de la
salida, la lectura vacía no tiene significado posible: escribir nada es una línea en blanco, pero leer
nada no es nada.

Los valores se piden **de uno en uno y en orden**, no todos a la vez, y el tipo esperado de cada valor
es el tipo del designador que lo recibe.

{{ejemplo:example-esp-io-lectura}}

## Un valor que no corresponde al tipo esperado

No interrumpe la ejecución. El paso señala qué tipo esperaba, emite su diagnóstico y **permanece en el
mismo estado**, volviendo a pedir el mismo valor. Es una decisión sobre la máquina paso a paso, no un
detalle de la interfaz: un fallo esperable es un diagnóstico, nunca una excepción que escape.

Un índice fuera de rango en el destino de una lectura sí es un fallo de ejecución, porque el sitio
donde guardar no existe.

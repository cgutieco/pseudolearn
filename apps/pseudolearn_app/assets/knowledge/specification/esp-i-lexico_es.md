# Estructura léxica

Antes de que exista una sentencia existe un texto, y el lenguaje decide primero cómo se parte ese
texto en piezas. Esta sección fija qué es un nombre, qué es un número, qué es un texto entre comillas,
dónde termina una sentencia y qué se ignora.

## Identificadores

Un identificador empieza por letra o por guion bajo, y sigue con letras, dígitos o guiones bajos. Qué
caracteres cuentan como letra lo fija el alfabeto del perfil activo.

Entre sí, dos identificadores se comparan **exactamente**: ni las mayúsculas ni las tildes se ignoran
nunca en un nombre que escribe quien programa, de modo que `total` y `Total` son dos variables
distintas.

Un identificador tampoco puede coincidir con una palabra reservada del perfil activo, y esa
coincidencia sí se decide con las políticas de mayúsculas y de tildes del perfil. Si el perfil acepta
`Segun`, `segun` y `SEGÚN` como la misma palabra reservada, ninguna de las tres queda libre para
nombrar una variable. Usar una de ellas donde el lenguaje espera un nombre es un error de sintaxis, y
el mensaje señala la palabra escrita y la palabra reservada con la que choca.

{{ejemplo:example-esp-lexico-identificadores}}

## Las mayúsculas y las tildes del léxico reservado son otra cosa

La insensibilidad a mayúsculas y a tildes es una política del perfil y alcanza **solo** a las palabras
reservadas, a los operadores y a los delimitadores. En el perfil de referencia el léxico reservado es
insensible a las dos cosas, de modo que dos formas de escribir la misma palabra reservada son el mismo
token.

La razón es práctica y está declarada: en un teclado táctil casi nadie escribe tildes, y castigarlo no
enseña nada sobre programar.

{{ejemplo:example-esp-lexico-mayusculas}}

## Palabras reservadas de varias palabras

El léxico admite lexemas formados por más de una palabra, de modo que un perfil puede definir una
misma construcción como una sola palabra o como dos separadas por un espacio. Ningún token cruza un
salto de línea.

## Números

Un literal entero es una secuencia de dígitos. Un literal real lleva un punto como separador decimal y
**al menos un dígito a cada lado**, así que ni la forma sin parte entera ni la forma sin parte decimal
son literales válidos.

El signo no forma parte del literal: es un operador unario aplicado a él.

{{ejemplo:example-esp-lexico-numeros}}

## Cadenas y caracteres

Se delimitan con {{lexema:quote}} o con la comilla simple, y las dos formas se aceptan porque el
material educativo del que viene quien estudia usa las dos de manera intercambiable. La forma canónica
que el lenguaje emite al imprimir un programa es la comilla doble.

{{ejemplo:example-esp-lexico-cadenas}}

## Comentarios

Un comentario va desde el marcador de comentario hasta el fin de la línea. El marcador es un dato del
perfil, no del lenguaje.

{{ejemplo:example-esp-lexico-comentarios}}

## Fin de sentencia

Una sentencia termina al final de la línea. El terminador explícito {{lexema:semicolon}} se acepta
**siempre** como separador, lo que permite escribir varias sentencias en una misma línea; que además
sea obligatorio es una bandera de rigor del perfil, no una regla del lenguaje.

{{ejemplo:example-esp-lexico-fin-sentencia}}

## Espacios en blanco

Los espacios, las tabulaciones y los saltos de línea separan tokens y no son significativos, con la
única excepción del salto de línea como fin de sentencia. **La indentación no significa nada**: sangrar
un bloque ayuda a leerlo y no cambia lo que el programa hace.

{{ejemplo:example-esp-lexico-espacios}}

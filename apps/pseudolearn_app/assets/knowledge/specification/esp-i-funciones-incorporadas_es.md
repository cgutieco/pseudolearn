# Funciones incorporadas

Son las operaciones que el lenguaje trae escritas y que ningún programa tiene que declarar. Su
semántica es del lenguaje; su nombre visible es un dato del perfil y cambia con el idioma.

## El catálogo completo

{{tabla:builtinFunctions}}

## Su nombre no es una palabra reservada

El nombre de una función incorporada **no consume ningún token del inventario**, así que se puede usar
como nombre de una variable o de un subprograma. Cuando eso ocurre, la declaración **oculta** la función
incorporada dentro de su ámbito, exactamente como haría cualquier lenguaje real.

No se diagnostica, y no se diagnostica a propósito: prohibirlo obligaría a que un catálogo que crece
fuera invalidando programas que ya eran correctos.

{{ejemplo:example-esp-funciones-nombre-no-reservado}}

## Las diez matemáticas

Raíz cuadrada, valor absoluto, logaritmo natural, exponencial, seno, coseno, arcotangente,
truncamiento, redondeo y aleatorio. Vienen del catálogo de partida y ninguna de ellas está aquí por una
decisión del sistema de tipos: están porque un curso introductorio las usa.

Dos de ellas hacen doble trabajo: {{firma:truncate}} y {{firma:round}} son las dos salidas de la
conversión de real a entero, que el lenguaje no hace nunca sola.

{{ejemplo:example-esp-funciones-matematicas}}

## Las ocho que el sistema de tipos obliga a tener

Cada conversión implícita rechazada obliga a que exista una explícita, o el lenguaje se queda sin forma
de hacer algo legítimo. Estas ocho no son una ampliación de gusto: son la consecuencia de rechazos ya
tomados.

- {{firma:toText}} es la salida del rechazo a concatenar un número con un texto. El texto que devuelve
  y el que emite la sentencia de salida son **el mismo**, producidos por la misma pieza.
- {{firma:textToInteger}} y {{firma:textToReal}} son lo que permite usar en aritmética un dato leído
  como cadena. Fallan al ejecutar si el texto no es un número, porque antes no se puede saber.
- {{firma:length}} es lo que permite recorrer una cadena. Cuenta **puntos de código**, que es lo que
  coincide con lo que se ve en pantalla.
- {{firma:characterAt}} es la única vía de cadena a carácter, que la tabla de conversiones declara no
  convertible.
- {{firma:characterCode}} es la única vía de carácter a número, y {{firma:characterFromCode}} es la
  inversa.
- {{firma:shallowCopy}} es la copia superficial de un objeto, comprometida por la sección de objetos.

{{ejemplo:example-esp-funciones-sistema-tipos}}

## Sobre el aleatorio, y el determinismo declarado

{{firma:random}} **no consulta el reloj ni ningún generador de la máquina que ejecuta el programa**. El
motor recibe una fuente pseudoaleatoria con semilla explícita, propia del proyecto, para que una
ejecución sea reproducible por construcción.

No es un detalle de implementación: sin él, un ejercicio con casos de prueba y una función aleatoria
serían incompatibles, y la ejecución paso a paso no podría repetirse dos veces igual.

{{ejemplo:example-esp-funciones-aleatorio}}

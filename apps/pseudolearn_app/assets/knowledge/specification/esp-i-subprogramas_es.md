# Subprocesos y funciones

Un subprograma es un trozo de programa con nombre, con entradas propias y con su propia memoria. Es lo
que permite escribir una vez lo que se usa muchas, y lo que permite leer un programa largo sin tenerlo
entero en la cabeza.

## Una sola construcción, dos papeles

Se abre con {{lexema:subroutine}}, su nombre y sus paréntesis, opcionalmente
{{lexema:typeConnector}} con un tipo de retorno, y cierra con {{lexema:endSubroutine}}.

Un subprograma que **declara** tipo de retorno devuelve un valor y se llama dentro de una expresión;
uno que **no lo declara** no devuelve nada y se llama como una sentencia. No hay dos palabras clave ni
dos gramáticas: hay una cláusula opcional.

Se elige así porque los lenguajes a los que se salta después tienen **una** construcción cuyo tipo de
retorno puede ser vacío, y porque la distinción que de verdad importa —si una llamada es una sentencia
o una expresión— no es sintáctica en ningún lenguaje real: depende de si hay valor devuelto.

Los paréntesis son **obligatorios**, también sin parámetros y también en la llamada. No son decoración:
son lo que permite distinguir una llamada de la lectura de una variable sin mirar ninguna tabla, y por
tanto lo que permite que un nombre mal escrito tenga un diagnóstico que diga si sobra o falta algo.

El tipo de retorno es uno de los cinco tipos primitivos o una clase. **No se puede devolver un
arreglo**, porque un arreglo no es un valor.

{{ejemplo:example-esp-subprogramas-dos-papeles}}

## Dónde vive un subprograma

Un texto de origen contiene **exactamente un algoritmo y cero o más subprogramas y clases**, en
cualquier orden, todos al nivel superior. Un subprograma no se declara dentro de otro ni dentro del
cuerpo del algoritmo.

El orden no importa porque la resolución de nombres recoge todas las cabeceras en una pasada previa;
exigir que la declaración preceda al uso obligaría a reordenar el texto para escribir dos subprogramas
que se llaman entre sí. Y no hay anidamiento porque un subprograma dentro de otro solo tendría sentido
con ámbitos anidados, y el lenguaje no los tiene.

{{ejemplo:example-esp-subprogramas-donde-vive}}

## Parámetros

Cada parámetro es un nombre, opcionalmente {{lexema:typeConnector}} con su tipo, y opcionalmente una
marca de paso en sufijo. Un parámetro de arreglo se marca con {{lexema:leftBracket}} y
{{lexema:rightBracket}} y tantos {{lexema:comma}} como dimensiones tenga menos una: **los tamaños no
aparecen**, porque el arreglo ya existe cuando llega y el subprograma no lo dimensiona.

El tipo es opcional en la gramática y la bandera de declaración obligatoria lo hace exigible. No hay
bandera nueva: un parámetro es la variable de entrada del subprograma, y la bandera que ya obliga a
declarar toda variable lo alcanza.

{{ejemplo:example-esp-subprogramas-parametros}}

## Paso por valor y paso por referencia

La marca va **en sufijo**, después del tipo, y ausente el paso es **por valor**. Escribir
{{lexema:byValue}} es admisible y redundante; {{lexema:byReference}} hace que el parámetro nombre la
misma casilla que el argumento.

**La marca es por parámetro y no se arrastra.** Escribirla una vez y aplicarla a los parámetros
siguientes se rechaza expresamente: bajo esa regla, quien lee un parámetro sin marca no puede saber
cómo se pasa sin buscar hacia arriba, y eso es un fallo silencioso.

Un argumento que corresponde a un parámetro por referencia **tiene que ser un designador**: un nombre,
un elemento de arreglo o un miembro de un objeto. Un literal, una expresión o la llamada a otro
subprograma no tienen dónde guardar nada.

Cuando el argumento es un elemento de arreglo, su índice **se evalúa una sola vez, en el momento de la
llamada**, y la posición queda fijada para toda la ejecución del subprograma. Pasar la misma variable a
dos parámetros por referencia está **permitido** y produce lo que produce: los dos parámetros nombran
la misma casilla. No se diagnostica, porque el proyecto enseña el aliasing en vez de ocultarlo.

{{ejemplo:example-esp-subprogramas-paso}}

## Los arreglos se pasan siempre por referencia

No es una excepción caprichosa: se deduce de que un arreglo no es un valor. Pasar por valor es copiar
un valor, y aquí no hay ninguno que copiar. Por eso marcar un parámetro de arreglo por valor es un
fallo con nombre propio —no se ignora en silencio— y marcarlo por referencia es admisible y redundante.

{{ejemplo:example-esp-subprogramas-paso-arreglos}}

## Retorno

{{lexema:returnKeyword}} es una **sentencia**, no un nombre declarado en la cabecera al que el cuerpo
asigna. Puede aparecer **varias veces**, en cualquier punto del cuerpo, incluidos el interior de un
condicional, de una selección y de cualquiera de los tres bucles; al ejecutarse, el subprograma termina
inmediatamente y lo que quede de cuerpo no se ejecuta.

Se rechaza la regla de salida única: es una convención de estilo, no del lenguaje, y ningún lenguaje
real la impone.

Lleva expresión en un subprograma con tipo de retorno declarado y no la lleva en uno sin tipo, donde
sirve de salida anticipada. Un subprograma con tipo declarado **cuyo cuerpo no contiene ningún
retorno** falla sin ejecutar; que un camino concreto llegue al final sin pasar por ninguno es un fallo
de ejecución, señalado en el cierre del subprograma. La partición es deliberada: nunca se rechaza un
programa correcto por no poder demostrar que lo es.

{{ejemplo:example-esp-subprogramas-retorno}}

## Llamada

Una llamada es el nombre seguido de sus argumentos entre paréntesis, y la misma forma sirve como
sentencia y como expresión. Cuál de las dos es válida lo decide si el subprograma declara tipo de
retorno, y por tanto es una comprobación de significado y no de escritura.

- Llamar **como expresión** a un subprograma sin tipo de retorno es un fallo: no hay valor que colocar.
- Llamar **como sentencia** a uno con tipo de retorno es válido y produce una advertencia: el valor se
  descarta.
- **El número de argumentos coincide con el de parámetros.** No hay parámetros opcionales ni valores
  por omisión.
- Los argumentos se evalúan de izquierda a derecha, una sola vez cada uno, antes de entrar en el
  cuerpo.

{{ejemplo:example-esp-subprogramas-llamada}}

## No hay variables globales

Cada subprograma tiene su propio ámbito, y las variables del algoritmo **no son visibles** dentro de
ningún subprograma. Toda comunicación pasa por los parámetros y por el valor de retorno.

Es el punto donde más se separan unas notaciones de otras, y la razón de elegir así es triple: un
subprograma que lee una variable que no recibió no es reutilizable; la ejecución paso a paso puede
mostrar el estado visible de cada momento porque es el marco actual y nada más; y ningún lenguaje real
hace globales por defecto las variables del programa principal.

Los nombres de subprograma forman **un espacio propio**, único para todo el texto. Aun así, un
subprograma y una variable no pueden llamarse igual dentro del mismo ámbito: no se prohíbe por
necesidad técnica sino porque el programa que lo hace no se puede leer.

```pseudo
SubProceso Probar()
  Escribir x
FinSubProceso
Algoritmo ErrorGlobal
  Definir x Como Entero
  x <- 5
  Probar()
FinAlgoritmo
```

{{diagnostico:undeclaredVariable}}

## Recursión, y el límite de profundidad

Un subprograma puede llamarse a sí mismo, directa o indirectamente, y la recursión mutua funciona sin
ninguna declaración adicional porque no hay orden de declaración.

**Hay un límite de profundidad de llamada, es del lenguaje y vale mil.** Alcanzarlo produce un fallo de
ejecución que señala la llamada que excede el límite, y la ejecución se detiene ahí.

No es un dato del perfil: un programa que recurre novecientas veces terminaría bajo un límite y fallaría
bajo otro, y eso cambia lo que el programa hace, no si es válido. El número es mil porque es el límite
por omisión del intérprete que más probablemente sea el paso siguiente, y porque ningún ejercicio de un
curso introductorio se acerca a esa profundidad mientras que una recursión sin caso base la alcanza en
un instante.

La pila de llamadas es una estructura de datos del evaluador y no la de la máquina que lo ejecuta, así
que **es imposible que una recursión infinita se manifieste como un desbordamiento de pila**: se cuenta
antes de crear el marco siguiente, y lo que sale es un diagnóstico.

{{ejemplo:example-esp-subprogramas-recursion}}

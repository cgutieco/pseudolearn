# Notación orientada a objetos

**Todo lo dicho en la notación imperativa y estructurada sigue vigente, sin ningún cambio.** No es una
cortesía: es una norma de este documento. El léxico, los cinco tipos primitivos, la tabla de
operadores, la declaración y la asignación, la entrada y la salida, las cinco estructuras de control,
los arreglos, los subprogramas y el sistema de tipos son los mismos, y ninguna regla de este documento
los contradice. Lo que sigue **solo añade**.

Lo que añade es una forma de decir que un dato y las operaciones que le corresponden son una sola cosa
con nombre. Un objeto no es una variable más: es un valor cuya identidad importa, y esa es la
diferencia que hay que tener en la cabeza para leer el resto.

## Declaración de clase

Una clase se abre con {{lexema:classKeyword}} y su nombre, opcionalmente {{lexema:inheritsFrom}} y el
nombre de su superclase, y cierra con {{lexema:endClass}}. Entre las dos palabras solo hay miembros.

- **Las clases son hermanas del algoritmo y de los subprogramas**, al nivel superior del texto. No hay
  clases anidadas, ni una clase dentro de un subprograma o del cuerpo del algoritmo, y un subprograma
  tampoco se declara dentro de una clase: lo que vive ahí son miembros.
- **El orden de declaración no importa**, por la misma razón que no importa entre subprogramas: la
  resolución de nombres recoge todas las cabeceras en una pasada previa.
- **Herencia simple únicamente.** Varias superclases separadas por coma tienen diagnóstico propio.
- La inicial mayúscula en el nombre de una clase **no se exige**: es estilo, no gramática.

Una clase vacía no es un error. Que una clase herede de sí misma, o que un ciclo de herencia se cierre,
sí lo es.

{{ejemplo:example-esp-clases-declaracion}}

## Atributos y visibilidad

**Un atributo se declara con la misma sentencia con la que se declara cualquier variable o cualquier
arreglo.** No hay una segunda forma de declarar, y no la hay a propósito: escribirla obligaría a decidir
otra vez el valor inicial, los varios nombres por sentencia y los arreglos, que ya están decididos una
vez.

Delante de un miembro puede ir {{lexema:publicVisibility}} o {{lexema:privateVisibility}}.

- **La visibilidad es un prefijo por miembro y no se arrastra.** Se rechaza la visibilidad por bloques
  por la misma razón por la que se rechazó la marca de paso arrastrada: quien lee un miembro sin buscar
  hacia arriba no podría saber su visibilidad.
- **Por omisión, público**, en atributos y en métodos.
- **Privado significa privado a la clase, no a la instancia, y la subclase no lo ve.** No hay un tercer
  nivel de visibilidad. Un método de una clase puede leer el atributo privado de otra instancia de esa
  misma clase; un método de una subclase no puede leer un atributo privado que declaró la superclase.

Un atributo que redeclara el nombre de un atributo heredado es un fallo, sea cual sea su visibilidad.

{{ejemplo:example-esp-clases-atributos}}

## Métodos

Un método se abre con {{lexema:method}}, su nombre y sus paréntesis, opcionalmente
{{lexema:typeConnector}} con un tipo de retorno, y cierra con {{lexema:endMethod}}.

**Un método es un subprograma con receptor: la misma forma, con otra palabra de apertura y de cierre.**
Hereda sin repetirlo todo lo que ya está decidido para los subprogramas: paréntesis obligatorios también
sin parámetros, lista de parámetros con dimensiones y marcas de paso, retorno como sentencia admisible
varias veces y con terminación inmediata, y advertencia al llamar como sentencia a un método que
devuelve valor. El tipo de retorno es uno de los cinco primitivos o una clase.

**Todos los métodos son de instancia.** No hay métodos estáticos.

{{ejemplo:example-esp-clases-metodos}}

## Constructor

El constructor se escribe con {{lexema:method}} seguido de {{lexema:constructor}}, sus paréntesis y su
cuerpo, y cierra como cualquier método.

- **Es un método cuyo nombre es una palabra reservada.** No admite visibilidad ni tipo de retorno: es
  siempre público y nunca devuelve valor.
- **Es opcional, y como máximo hay uno.** Sin declarar ninguno, la clase tiene un constructor implícito
  sin parámetros que no asigna nada. Dos constructores en la misma clase es un fallo: no hay sobrecarga.
- **No se nombra como la clase.** Se rechaza esa forma —la de varios lenguajes conocidos— porque
  obligaría al analizador a comparar el nombre del método con el de la clase para saber qué está
  leyendo. Un método declarado con el nombre exacto de su clase produce un diagnóstico propio que
  explica cómo se declara aquí un constructor.
- **Cadena de construcción.** Antes del cuerpo del constructor de una clase se ejecuta el de su
  superclase. Si la superclase tiene constructor con parámetros, la subclase **debe** invocarlo como
  primera sentencia de su propio constructor; si no lo tiene, o lo tiene sin parámetros, la invocación
  es opcional.

Un retorno sin expresión dentro de un constructor no es un error: es una salida anticipada. Uno con
expresión sí lo es.

{{ejemplo:example-esp-clases-constructor}}

## Instanciación

Se escribe {{lexema:newInstance}}, el nombre de la clase y sus argumentos entre paréntesis, y es una
**expresión**, no una sentencia.

**Declarar y crear son dos sentencias porque son dos cosas.** Declarar una variable de una clase crea
una referencia sin objeto; asignarle una instanciación crea el objeto y hace que la referencia lo
apunte. Se rechaza la creación implícita al declarar.

**No hay valor nulo escribible.** Una variable de clase declarada y no asignada está **sin instanciar**,
y acceder a un miembro suyo es un fallo de ejecución con nombre propio. Es la misma decisión que la
ausencia de valores por omisión para los primitivos: un olvido no se convierte en un programa que se
ejecuta y da un resultado equivocado.

Instanciar una clase declarada más adelante en el texto no es un error, y encadenar un acceso sobre el
resultado de una instanciación tampoco.

{{ejemplo:example-esp-clases-instanciacion}}

## Objeto actual y superclase

**{{lexema:thisObject}} es obligatorio para acceder a cualquier miembro del objeto actual.** Dentro de
un método o de un constructor, un identificador suelto **nunca** designa un atributo: designa un
parámetro o una variable local. Los atributos se alcanzan exclusivamente detrás de un acceso a miembro
sobre el objeto actual.

Con esa obligación no hay ninguna regla de sombra que escribir: los atributos no están en el ámbito del
método, están detrás de un acceso. Un identificador suelto que coincide con el nombre de un atributo
tiene diagnóstico propio, porque es exactamente el error que se comete al venir de un material que no lo
exige.

**{{lexema:superClass}} da acceso a la implementación de la superclase, y solo a eso.** Únicamente
puede ser el receptor de una llamada a un método o al constructor: no es una expresión por sí solo, no
se puede asignar, y **no da acceso a atributos** —si la subclase no ve los privados de su superclase, no
puede haber un resquicio por el que los vea—.

**La llamada por la superclase no es dinámica.** Invoca la implementación de la superclase aunque el
objeto sea de una subclase que la sobrescribe; sin esa garantía, una sobrescritura que llama a su
superclase sería una recursión infinita.

{{ejemplo:example-esp-clases-este-super}}

## Acceso a miembro, llamada a método y sobrescritura

Un acceso a miembro es una expresión seguida de {{lexema:dot}} y del nombre del miembro; una llamada a
método es lo mismo seguido de sus argumentos entre paréntesis.

- **El acceso a miembro es un designador**: sirve como destino de una asignación y de una lectura. Una
  llamada a método no lo es, igual que no lo es una llamada a función.
- **Se encadena**, también sobre el resultado de una llamada. Esto no reabre la prohibición de
  encadenar corchetes: aquella existe porque el número de índices debe coincidir con las dimensiones
  declaradas, y encadenar accesos no tiene ese problema porque cada uno se resuelve contra el tipo del
  resultado del anterior.
- **Toda llamada a método es de despacho dinámico**, sobre la clase real del objeto y nunca sobre el
  tipo con el que se declaró la variable.
- **La sobrescritura no lleva marca.** Un método de una subclase con el mismo nombre que uno de su
  superclase lo sobrescribe. Como no hay sobrecarga, un método con el mismo nombre y **distinta firma**
  es un fallo con nombre propio: no es una segunda versión, es una sobrescritura mal escrita. Misma
  firma significa mismo número de parámetros, mismos tipos, mismas marcas de paso y mismo tipo de
  retorno.

**Qué métodos existen se comprueba contra el tipo declarado cuando se conoce.** Una variable declarada
del tipo de la superclase que apunta a una instancia de la subclase no admite un método que solo la
subclase tiene, aunque al ejecutar fuese a funcionar. No es una limitación del motor: es la distinción
entre tipo declarado y tipo real, que es la lección central del polimorfismo, y el diagnóstico es donde
se enseña.

{{ejemplo:example-esp-clases-miembro-sobrescritura}}

## Las clases como tipos, y qué es un objeto como valor

Donde el lenguaje admite un tipo, admite también el nombre de una clase: en la declaración de una
variable, en el tipo de los elementos de un arreglo, en el tipo de un parámetro y en el tipo de retorno
de un subprograma o de un método. Un identificador en posición de tipo que no nombra ninguna clase
declarada es un fallo de significado y no de escritura, porque el analizador no tiene tabla de
símbolos.

**Un objeto es un valor; un arreglo no lo es.** El valor es la referencia, y de ahí sale todo lo demás:

- **Asignar un objeto completo es válido**, y copia la referencia: los dos nombres pasan a designar el
  mismo objeto. Asignar un arreglo completo sigue siendo un fallo.
- **Devolver un objeto es válido.** Devolver un arreglo sigue sin serlo.
- **Comparar dos objetos con {{lexema:equal}} o {{lexema:notEqual}} compara identidad**, no contenido, y
  solo entre tipos comparables. Comparar instancias de dos clases sin relación de herencia es un fallo,
  porque el resultado sería siempre falso.
- **Escribir un objeto en la salida es un fallo con nombre propio**: no hay conversión automática a
  cadena, aquí tampoco.
- Cualquier otro operador sobre un objeto es un fallo.

**Paso de un objeto a un subprograma o a un método.** Un parámetro de tipo clase **por valor** —que es
la omisión— copia la referencia: el subprograma puede modificar el objeto a través de ella, pero no
puede hacer que la variable de quien llamó apunte a otro objeto. Un parámetro **por referencia** permite
además reasignarla.

{{ejemplo:example-esp-clases-como-tipos}}

## Copia

La copia explícita es **copia superficial**: crea un objeto nuevo con los mismos valores de atributo, y
los atributos que a su vez son objetos **se siguen compartiendo**.

Es la semántica que se encuentra al pasar a un lenguaje real, y deja visible el aliasing anidado en vez
de ocultarlo. Se materializa como **función incorporada**, no como palabra reservada: su nombre se
traduce como el de cualquier otra función incorporada.

{{ejemplo:example-esp-clases-copia}}

## Lo que este lenguaje no tiene, y por qué

Esta parte no es un apéndice. Está aquí porque quien viene de otro material va a escribir estas
construcciones, y decir que no existen y por qué es más útil que el silencio.

- **Herencia múltiple.** Una clase hereda de una sola. Varias superclases separadas por coma tienen
  diagnóstico propio.
- **Interfaces y clases abstractas.** No existen. Un método se sobrescribe sin marca y el despacho es
  siempre dinámico, así que el polimorfismo que un curso introductorio necesita ya está.
- **Métodos y atributos estáticos.** No existen. Todos los miembros son de instancia.
- **Sobrecarga.** No existe: dos miembros con el mismo nombre en la misma clase son una declaración
  duplicada, y un método que sobrescribe con distinta firma es una sobrescritura mal escrita, no una
  segunda versión.
- **Genéricos.** No existen.
- **Excepciones.** No existen. Un fallo esperable es un diagnóstico del motor con su sitio señalado, no
  algo que el programa pueda lanzar y capturar.
- **Destructores.** No existen. No hay ningún momento del programa en el que quien lo escribe tenga que
  ocuparse de liberar un objeto.
- **Un tercer nivel de visibilidad.** Solo hay público y privado. Un miembro privado no lo ve la
  subclase, y esa es toda la regla.

Ninguna de estas ausencias es un olvido, y ninguna se resuelve con una palabra que el lenguaje reconozca
a medias: escribir cualquiera de ellas produce un diagnóstico que la nombra y dice qué hacer en su
lugar.

```pseudo
Clase A
FinClase
Clase B
FinClase
Clase C HeredaDe A, B
FinClase
Algoritmo ErrorHerenciaMultiple
FinAlgoritmo
```

{{diagnostico:multipleInheritanceNotSupported}}

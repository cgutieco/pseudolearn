# Sistema de tipos y política de rigor

Esta sección dice **qué es exactamente un error de tipos** y **qué cambia entre el perfil estricto y el
flexible**. El lenguaje es fuertemente tipado y no abre ninguna excepción: cada conversión silenciosa
que se rechaza aquí es un error de quien programa que, admitido, se convertiría en un programa que se
ejecuta y da un resultado equivocado.

## Las tres relaciones entre tipos

Toda regla de esta sección se apoya en tres relaciones, nombradas para no tener que redescribirlas cada
vez:

- **Identidad**: son el mismo tipo primitivo, o la misma clase. Es la que se usa al comparar la firma
  de un método con la del que sobrescribe.
- **Convertibilidad**: idénticos, o de entero a real, o de una clase a una superclase suya. Es la que
  gobierna la asignación, el argumento de una llamada y el valor de retorno.
- **Comparabilidad**: uno es convertible al otro. Es la que gobierna los operadores relacionales.

**La convertibilidad es dirigida**, y ahí está toda la decisión: que un entero valga donde se espera un
real no implica lo contrario.

{{ejemplo:example-esp-tipos-relaciones}}

## La única conversión implícita entre primitivos

Solo hay una: de {{lexema:integerType}} a {{lexema:realType}}, porque no pierde información. Todas las
demás se rechazan, y cada rechazo tiene su razón:

- De {{lexema:realType}} a {{lexema:integerType}} se pierde la parte decimal, y decidir si se trunca o
  se redondea es de quien programa. Hay una función incorporada para cada opción.
- Entre {{lexema:characterType}} y {{lexema:stringType}} no hay conversión en ninguna dirección: son
  tipos distintos, y una cadena de longitud distinta de uno no tiene carácter equivalente.
- Entre {{lexema:booleanType}} y los numéricos no hay conversión. Es la regla que hace que un
  condicional sobre un número sea un error y no una costumbre.
- De cualquier tipo a {{lexema:stringType}} tampoco. Es la conversión automática al concatenar que
  tienen otros lenguajes, y se rechaza expresamente.

De una clase a una superclase suya **sí** es implícita, y es lo que hace posible el polimorfismo. La
contraria no lo es, y no hay operador de conversión descendente.

## Rango de los números, y qué ocurre al salirse

{{lexema:integerType}} es un número de sesenta y cuatro bits con signo. {{lexema:realType}} es un
número de coma flotante de doble precisión.

**El desbordamiento de un entero es un fallo de ejecución con nombre propio, nunca un giro silencioso
al negativo.** Convertir un número grande en uno negativo sin avisar es el error más difícil de
explicar que un lenguaje puede producir, y aquí la máquina paso a paso puede señalar la operación
culpable. Producir un valor no finito con un real —infinito o no numérico— es igualmente un fallo de
ejecución.

## El tipo de cada operador

- Los signos unarios admiten un operando numérico y devuelven su mismo tipo.
- Suma, resta y multiplicación admiten dos numéricos: dos enteros dan entero, y cualquier par con al
  menos un real da real.
- {{lexema:plus}} funciona además como concatenación cuando al menos un operando es una cadena, o
  cuando los dos son caracteres, y entonces devuelve una cadena.
- {{lexema:divide}} admite cualquier par numérico y devuelve **siempre un real**, aunque los dos
  operandos sean enteros.
- {{lexema:integerDivide}} y {{lexema:modulo}} admiten **únicamente** dos enteros y devuelven entero.
- {{lexema:power}} sigue la misma regla que la multiplicación: dos enteros dan entero, y un par con al
  menos un real da real.
- Los relacionales de orden admiten dos numéricos, dos caracteres o dos cadenas, y devuelven un lógico.
- {{lexema:equal}} y {{lexema:notEqual}} admiten dos tipos comparables y devuelven un lógico.
- {{lexema:not}}, {{lexema:and}} y {{lexema:or}} admiten **únicamente** lógicos y devuelven un lógico.

## Cinco reglas de esa lista que llevan decisión

**La división de dos enteros da un real.** Se rechaza la división entera con la misma barra que hacen
otros lenguajes, porque convierte el promedio en un truncamiento invisible y porque dejaría a la
división entera sin ninguna función.

**La división entera y el módulo solo aceptan enteros.** Truncar los operandos y seguir reintroduciría
por la puerta de atrás la conversión que esta misma sección rechaza.

**Truncan hacia cero, y el resto toma el signo del dividendo.** Con enteros negativos, dividir −7 entre
2 da −3 y su resto es −1. Así se cumple además la identidad que permite explicar los dos operadores
como uno solo.

**La potencia conserva el entero, y un exponente negativo es un fallo de ejecución.** El tipo de una
expresión no puede depender del valor que un operando tenga al ejecutarse, así que el tipo se mantiene y
el caso se resuelve donde se conoce el valor.

**Concatenar un número con un texto es un fallo con nombre propio.** El diagnóstico tiene dos salidas
que nombrar: la función incorporada de conversión, y el hecho de que la salida ya admite una lista de
expresiones, de modo que escribir el rótulo y el número como dos elementos de la lista no necesita
conversión ninguna.

Dos reglas más que no son de tipos pero son observables: los operadores lógicos **evalúan en
cortocircuito**, y comparar dos reales por igualdad es válido y produce advertencia. Comparar dos
lógicos con menor o mayor, en cambio, es un fallo: entre valores de verdad no hay orden.

{{ejemplo:example-esp-tipos-cinco-reglas}}

## Quién comprueba qué: la regla de los dos niveles

Una comprobación se hace **sin ejecutar** si es decidible sin ejecutar y sin construir un grafo de
caminos; en cualquier otro caso se hace **al ejecutar**, señalando el sitio exacto. **Nunca se rechaza
un programa correcto por no poder demostrar que lo es.**

No es una regla inventada aquí: es la misma con la que se decidió quién comprueba que todos los caminos
de una función retornan, y la misma con la que se decide la visibilidad de un miembro.

## Inferencia de tipos en el perfil flexible

**El tipo de una variable no declarada queda fijado por la primera acción que le da un valor**, y esas
acciones son exactamente dos: la asignación y la lectura. No es la primera aparición en el texto: una
variable que aparece por primera vez dentro de una expresión sin haber recibido valor es un uso sin
inicializar, no una inferencia.

Con una asignación, el tipo es el de la expresión de la derecha y se conoce sin ejecutar. Con una
lectura, el tipo depende de lo que se escriba y por tanto se fija **al ejecutar**, clasificando el
texto introducido en este orden y ganando el primero que encaja: literal entero, literal real, uno de
los dos lexemas lógicos del perfil activo y, en cualquier otro caso, cadena.

**Un carácter nunca se infiere.** Un texto de un solo carácter se clasifica como cadena de longitud
uno: desde el texto introducido las dos lecturas son indistinguibles, y cadena es la que no pierde
información. Quien necesite un carácter lo declara.

En el perfil estricto no hay inferencia, porque la bandera de declaración obligatoria no deja ninguna
variable sin tipo. La inferencia no es una bandera nueva: es lo que ocurre cuando esa bandera está
apagada.

{{ejemplo:example-esp-tipos-inferencia}}

## Ampliación aceptable y conflicto real

**Ampliación aceptable, una y solo una.** Si el tipo inferido es entero y más adelante se asigna un
real, el tipo de la variable pasa a real. Es aceptable porque todo valor entero anterior es
representable como real, así que ninguna línea ya comprobada deja de ser correcta.

**Conflicto real, todo lo demás.** Cualquier asignación cuyo tipo no sea convertible al tipo ya fijado
falla **en esa línea**, no en la declaración ni al final del programa.

Tres propiedades hacen la regla comprobable: la ampliación ocurre **como máximo una vez por variable**,
porque solo hay una conversión implícita entre primitivos; **no retropropaga**, así que las líneas
anteriores no se vuelven a comprobar; y **no hay ampliación entre clases**, de modo que asignar a una
variable de una clase una instancia de una clase hermana es conflicto aunque compartan superclase.

```pseudo
Algoritmo ConflictoInferencia
  x <- 10
  x <- "Texto"
FinAlgoritmo
```

{{diagnostico:typeConflictOnInferredVariable}}

## Variable usada sin inicializar, y la ausencia de valores por omisión

Leer el valor de una variable a la que nunca se le asignó ninguno es un fallo **en las dos políticas**.
Lo que la bandera decide es **cuándo se detecta**, no si lo es: sin ejecutar cuando es decidible sin
ejecutar, y al ejecutar en cualquier otro caso.

**No hay valores por omisión.** Una variable declarada y no asignada **existe pero no tiene valor**, y
el entorno distingue los dos estados de modo que la tabla de prueba lo muestre. Las razones son tres: un
valor por omisión convierte un olvido en un programa que se ejecuta y da un resultado equivocado; la
máquina paso a paso puede señalar la lectura culpable, mientras que un cero por omisión no tiene nada
que subrayar; y es lo que ya ocurre con las variables de tipo clase, que arrancan sin instanciar.

```pseudo
Algoritmo SinInicializar
  Definir x Como Entero
  Escribir x
FinAlgoritmo
```

{{diagnostico:variableUsedUninitialized}}

## Variable declarada y no usada, y asignada y no leída

**Usar es leer el valor. Asignar no es usar.** De ahí salen dos avisos distintos, los dos advertencia en
las dos políticas: una variable declarada y nunca usada es código muerto, y una variable asignada y
nunca leída es lo que caza un nombre mal escrito —y bajo el perfil flexible es la única red que queda,
porque no hay declaración que lo delate.

Tres casos cuentan como uso, y están escritos porque cada uno produciría un aviso falso: una variable
pasada como argumento por referencia, la variable de control de un bucle contado, y un atributo leído
desde cualquier método de su clase aunque ese método no se llame nunca.

```pseudo
Algoritmo DeclaradaNoUsada
  Definir total Como Entero
FinAlgoritmo
```

{{diagnostico:variableDeclaredNeverUsed}}

## Arreglos y objetos en el sistema de tipos

El índice de un arreglo es de tipo entero; un índice real es un fallo y **no** un truncamiento.

**El tamaño no forma parte del tipo.** El tipo de un arreglo es el par formado por el tipo de sus
elementos y su número de dimensiones. Es una consecuencia y no una elección: un parámetro de arreglo
declara sus dimensiones sin sus tamaños, así que el tipo con el que se comprueba una llamada no puede
contenerlos.

Para los objetos, la regla de subtipo es la que ya anticipó la convertibilidad: una variable de una
clase puede referenciar una instancia de esa clase o de cualquier subclase suya, y la contraria no.
**La consecuencia se enseña, no se tapa**: sobre una variable declarada del tipo de la superclase, la
llamada a un método que solo existe en la subclase es un fallo aunque al ejecutar fuese a funcionar, y
el diagnóstico dice exactamente eso, porque ahí está la distinción entre tipo declarado y tipo real.

{{ejemplo:example-esp-tipos-arreglos-objetos}}

## La política de severidad

**Un código de diagnóstico nunca cambia de significado entre políticas.** Cambia de severidad, o no
cambia nada. Si dos políticas necesitaran que el mismo código quisiera decir dos cosas, harían falta
dos códigos.

Cada código pertenece a una clase, que es un dato del lenguaje, y la severidad es un dato del perfil que
solo puede moverse dentro de lo que su clase permite: lo **estructural** es error en las dos políticas;
lo **gobernado por bandera** es error en la estricta y advertencia en la flexible; lo de **higiene** es
advertencia en las dos; lo **informativo** es información en las dos; y lo de **ejecución recuperable**
es advertencia en las dos y no detiene el programa.

Dos invariantes se comprueban solos: la política flexible es siempre igual o más permisiva que la
estricta, y ningún código estructural baja de error en ninguna política.

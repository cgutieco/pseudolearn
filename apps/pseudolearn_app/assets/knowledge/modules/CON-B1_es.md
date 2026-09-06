:::parte pregunta

Un algoritmo que solo hace cuentas con números escritos a mano no sirve para nada: resuelve un caso y
ninguno más. Para que sirva para todos los casos hace falta poder decir «el número que me den», y para
eso hace falta guardar valores con un nombre. Este módulo trata de eso: qué clases de valores hay,
cómo se les pone nombre y qué ocurre exactamente cuando se les da uno nuevo.

:::parte modelo-maquina

La memoria del programa es una fila de casillas. Cada casilla tiene un nombre, admite valores de una
sola clase y guarda un valor cada vez. Declarar es pedir una casilla y decidir qué clase de valores
admite. Asignar es escribir dentro, borrando lo que hubiera.

{{figura:cajas-memoria}}

Esa es la idea entera, y conviene tenerla presente: casi todo lo que sorprende de un programa se
explica mirando qué casillas hay y qué había dentro de cada una en el paso anterior.

:::parte desarrollo

## Cinco clases de valores

Todo valor pertenece a uno de cinco tipos, y el tipo decide qué operaciones tienen sentido con él.

{{tabla:primitiveTypes}}

## Declarar y asignar son dos cosas

Se declara con {{lexema:declare}} y se asigna con {{lexema:assignment}}. Declarar reserva la casilla y
le fija el tipo. Asignar escribe dentro. No se pueden escribir juntas, y esa separación no es un
capricho: hace que se lea de un vistazo dónde nace un nombre y dónde cambia su valor.

{{ejemplo:example-sum}}

Ese programa declara tres casillas, escribe en dos de ellas, calcula con las dos y guarda el resultado
en la tercera. Nada más ocurre, y nada más hace falta.

## El orden de las operaciones no es el orden de lectura

Dentro de una expresión, las operaciones no se aplican de izquierda a derecha sino por prioridad. Esta
es la tabla que el lenguaje usa, de mayor a menor:

{{tabla:precedence}}

{{ejemplo:example-b1-expresiones}}

Las dos líneas de ese programa se escriben casi igual y no valen lo mismo. La primera multiplica antes
de sumar porque la multiplicación está en una fila más alta; la segunda suma antes porque los
paréntesis mandan sobre la tabla.

## Asignar es borrar

Una asignación no añade un valor: sustituye el que había. Por eso intercambiar el contenido de dos
casillas no se puede hacer en dos pasos, y hace falta una tercera casilla que recuerde el valor que se
va a perder.

{{diagrama:example-b1-intercambio#ordinograma}}

:::parte prediccion

Antes de ejecutar nada, escribe en un papel qué valores tienen `a` y `b` justo después de la última
asignación de este programa:

{{ejemplo:example-b1-intercambio}}

Ahora ejecútalo paso a paso y compara. Si tu predicción coincide, tu modelo de la máquina funciona. Si
no coincide, acabas de encontrar exactamente dónde no funcionaba, que vale mucho más.

- example-b1-intercambio#5#a Valor de `a` y de `b` justo después de la última asignación

:::parte errores-frecuentes

## Dar un valor inicial dentro de la declaración

El tipo se escribe al final de la declaración, así que un valor inicial no cabe ahí. Se declara en una
línea y se asigna en la siguiente.

```pseudo
Algoritmo ValorInicial
  Definir n Como Entero <- 5;
FinAlgoritmo
```

{{diagnostico:initializationInDeclarationNotAllowed}}

## Asignar a algo que no es una casilla

A la izquierda de una asignación tiene que haber un nombre, no un número ni una cuenta. Escribirlo al
revés es el error de quien viene de las matemáticas, donde la igualdad no tiene dirección.

```pseudo
Algoritmo DestinoInvalido
  Definir n Como Entero;
  n <- 3;
  5 <- n;
FinAlgoritmo
```

{{diagnostico:invalidAssignmentTarget}}

## Guardar en una casilla un valor de otra clase

Una casilla de enteros no admite texto. El aviso no es una manía del lenguaje: es lo que impide que el
programa siga adelante calculando con algo que no es un número.

```pseudo
Algoritmo TipoIncompatible
  Definir n Como Entero;
  n <- "cinco";
  Escribir n;
FinAlgoritmo
```

{{diagnostico:incompatibleTypesInAssignment}}

:::parte especificacion

- esp-i-tipos-primitivos Los cinco tipos, sus valores y su rango
- esp-i-operadores La tabla de precedencia completa y el cortocircuito
- esp-i-declaracion La forma exacta de una declaración y de una asignación

:::parte ejercicios

- CON-B1-E1 Suma de dos números
- CON-B1-E2 Área de un rectángulo
- CON-B1-E3 Intercambio de dos valores
- CON-B1-E4 Promedio de tres notas
- CON-B1-E5 Completar el perímetro
- CON-B1-E6 De la suma a la diferencia
- CON-B1-E7 Precio con descuento, en secuencia

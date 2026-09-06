:::parte pregunta

Una cuenta bancaria tiene un saldo, y solo tiene sentido depositar o retirar contra ese saldo exacto.
Modelarla con una variable suelta y un puñado de subprogramas que reciben esa variable como parámetro
funciona, hasta que hay dos cuentas: entonces cada subprograma necesita un parámetro más, y nada impide
pasarle el saldo de la cuenta equivocada. Este módulo introduce la clase: una forma de mantener juntos
el estado y la conducta que le corresponden, para que ese error deje de ser posible.

:::parte modelo-maquina

Una clase es un plano: declara qué casillas tiene cada objeto de esa clase y qué subprogramas pueden
tocarlas. El plano no ocupa memoria por sí solo. Cada vez que se crea un objeto con {{lexema:newInstance}}
se reserva un juego de casillas nuevo, propio de ese objeto, y ese juego es lo que hasta ahora este curso
llamaba «los parámetros que había que pasar juntos porque pertenecían a lo mismo».

:::parte desarrollo

## De variables sueltas a un objeto

{{ejemplo:example-c1-cuenta}}

{{diagrama:example-c1-cuenta#clases}}

`Definir cuenta Como CuentaBancaria` declara una referencia, todavía sin objeto. `Nuevo CuentaBancaria(100)`
crea el objeto —reserva su casilla `saldo` y ejecuta el constructor con `100`— y la asignación hace que
`cuenta` designe ese objeto. Son dos pasos distintos porque son dos cosas distintas: declarar no crea, y
crear es una expresión, no una sentencia aparte.

## Los métodos son subprogramas con un objeto de más

`cuenta.Depositar(50)` y `cuenta.Saldo()` son llamadas a subprogramas, con la única diferencia de que
cada uno recibe, además de sus parámetros escritos, el objeto sobre el que se llamó. Dentro del método,
ese objeto se nombra {{lexema:thisObject}}. `Este.saldo` no es un parámetro ni una variable local: es la
casilla del objeto sobre el que corre el método en este momento.

:::parte prediccion

- example-c1-cuenta#8# ¿Qué valor escribe el programa al final, después de depositar 50 sobre un saldo inicial de 100?

Antes de comprobarlo, decide si `Saldo()` puede devolver un valor distinto del que `Depositar` dejó en la
casilla del objeto: ¿hay alguna otra `CuentaBancaria` de por medio que pudiera confundirse con esta?

:::parte errores-frecuentes

## Un constructor que declara qué devuelve

El constructor nunca devuelve un valor: crea el objeto, no lo calcula. Escribirle un tipo de retorno es
tratarlo como si fuera un método cualquiera.

```pseudo
Clase Punto
    Privado Definir x Como Entero;

    Metodo Constructor(unX Como Entero) Como Entero
        Este.x <- unX;
    FinMetodo
FinClase
```

{{diagnostico:constructorReturnTypeNotAllowed}}

## Una clase dentro de otra clase

Las clases son hermanas del algoritmo y de los subprogramas, todas al nivel superior del texto. No hay
clases anidadas: solo tendrían sentido con ámbitos anidados, y este lenguaje no los tiene.

```pseudo
Clase Exterior
    Clase Interior
        Privado Definir n Como Entero;
    FinClase
FinClase
```

{{diagnostico:nestedClassNotSupported}}

:::parte especificacion

- esp-o-clases Notación orientada a objetos: clase, atributos, métodos, constructor e instanciación

:::parte ejercicios

- CON-C1-E1 Clase Rectangulo con área
- CON-C1-E2 Clase Contador con incremento
- CON-C1-E3 Clase Termometro con conversión
- CON-C1-E4 Clase Producto con descuento
- CON-C1-E5 Clase Pila simple de un elemento
- CON-C1-E6 Clase Semaforo con estado

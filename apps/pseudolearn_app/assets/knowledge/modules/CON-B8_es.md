:::parte pregunta

Leer un programa no es lo mismo que escribirlo: exige seguir el flujo de control sin poder ejecutarlo,
y un texto largo esconde esa estructura entre líneas que se parecen. Este módulo no añade ninguna
construcción nueva del lenguaje: enseña a leer las que ya existen a través de su dibujo, con el
ordinograma y con el estructograma.

:::parte modelo-maquina

El ordinograma dibuja el flujo con flechas: cada símbolo es un paso y cada flecha dice cuál sigue,
incluidas las que vuelven hacia atrás para cerrar un bucle. El estructograma no tiene flechas: cada
construcción es una caja que contiene otras cajas, anidadas como el propio texto las anida. Esa
diferencia no es de estilo. Un estructograma **no puede dibujar un salto que rompa el anidamiento** —no
hay una flecha que se pueda trazar fuera de una caja hacia cualquier otro punto del dibujo—, y por eso
es la prueba visual de que un programa está hecho enteramente de las cinco construcciones estructuradas
de este lenguaje: nada salta a mitad de otra construcción, y nada dibujado dos veces representa el mismo
código dos veces.

:::parte desarrollo

## El mismo programa, dos dibujos

{{ejemplo:example-b8-clasificar}}

{{diagrama:example-b8-clasificar#ordinograma}}

El ordinograma de este programa muestra el bucle contado como una flecha que vuelve desde el final del
cuerpo hasta la comprobación del contador, con el condicional colgando dentro del cuerpo del bucle. Leer
el ordinograma es seguir esa flecha: el camino que toma la ejecución en cada vuelta depende de si la
nota leída llegó o no a 5.

{{diagrama:example-b8-clasificar#estructograma}}

El mismo programa en estructograma no tiene ninguna flecha que seguir: la caja del bucle contado
contiene la caja del condicional, que contiene sus dos ramas, y leer el diagrama es leer las cajas de
afuera hacia adentro. Las dos formas describen exactamente el mismo comportamiento porque describen
exactamente el mismo árbol: son dos dibujos de la misma estructura, nunca dos programas distintos.

## Por qué «estructurado» es una promesa que se puede dibujar

Un lenguaje sin {{lexema:whileKeyword}} ni {{lexema:forKeyword}} podría simular un bucle con un salto
incondicional hacia atrás, y ese salto se puede dibujar en un ordinograma con una flecha suelta. En un
estructograma no hay dónde ponerla: cada caja está completamente dentro de otra o completamente fuera,
nunca cruzando el borde de una. Este lenguaje no tiene ninguna sentencia de salto —ni siquiera para salir
antes de un bucle— precisamente para que la promesa de «programa estructurado» valga siempre, no solo
cuando a quien escribe se le ocurre no usar el salto que sí existe.

:::parte prediccion

- example-b8-clasificar#10#aprobados Con cantidad 4 y las notas 3, 6, 5 y 2, ¿cuántas notas aprobaron?

Antes de comprobarlo, sigue el ordinograma paso a paso —o cuenta las cajas del estructograma que se
activan— y decide cuántas veces se cumple la condición del condicional.

:::parte errores-frecuentes

## Una construcción que el lenguaje reconoce y rechaza a propósito

Un salto incondicional rompería la promesa de que todo estructograma se puede dibujar sin flechas
sueltas. El lenguaje reconoce la palabra y la rechaza explícitamente, en vez de tratarla como un nombre
cualquiera.

```pseudo
Algoritmo SaltoIncondicional
    Definir i Como Entero;
    i <- 0;
    goto fin;
FinAlgoritmo
```

{{diagnostico:unsupportedStructuredConstruct}}

## Una selección múltiple que nunca se cierra

Como cualquier otra construcción de bloque, una selección múltiple sin su cierre deja al analizador sin
poder decidir dónde termina la caja del estructograma y dónde sigue el resto del programa.

```pseudo
Algoritmo SeleccionSinCierre
    Definir dia Como Entero;
    dia <- 3;
    Segun dia Hacer
        1:
            Escribir "Lunes";
FinAlgoritmo
```

{{diagnostico:unclosedSwitchStatement}}

:::parte especificacion

- esp-i-control El condicional, la selección múltiple y los tres bucles

:::parte ejercicios

- CON-B8-E1 Contar aprobados
- CON-B8-E2 Suma de los números pares
- CON-B8-E3 Mayor de una serie
- CON-B8-E4 De contar aprobados a contar reprobados
- CON-B8-E5 Contar días de fin de semana
- CON-B8-E6 Aprobados y reprobados en dos líneas

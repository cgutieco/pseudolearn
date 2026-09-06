:::parte pregunta

Con enteros y con texto, dos casillas con el mismo valor son intercambiables: no importa cuál se mire.
Con objetos eso deja de ser cierto. Dos variables pueden apuntar al **mismo** objeto, y entonces mutar
uno a través de una de ellas se ve a través de la otra. Este módulo es sobre esa distinción —referencia
contra valor— y sobre las dos formas de dejar de compartir un objeto sin querer: el alias accidental y
la copia superficial.

:::parte modelo-maquina

Cada objeto tiene una identidad propia, distinta de su contenido, y la tabla de prueba la muestra así:
`Caja#1` es el objeto número 1 de la clase `Caja`, y ese número no cambia mientras el objeto exista.
Una variable de clase no guarda el objeto: guarda **una referencia** a él, el mismo número. Cuando dos
variables tienen la misma referencia, son la misma casilla `Caja#1` vista con dos nombres, no dos
casillas con el mismo contenido.

:::parte desarrollo

## Asignar un objeto copia la referencia, no el contenido

{{ejemplo:example-c3-alias}}

{{diagrama:example-c3-alias#clases}}

`b <- a` no crea una `Caja` nueva: copia la referencia que `a` tenía, así que `a` y `b` pasan a designar
el mismo objeto `Caja#1`. A partir de ahí, escribir a través de `b` es escribir la misma casilla que `a`
ve. Esto no es un caso especial de los objetos: es la consecuencia directa de que un objeto **es** su
referencia (11.8), igual que un arreglo pasado a un subprograma comparte sus elementos con quien lo
llamó.

## Copiar rompe el alias, a propósito

{{ejemplo:example-c3-copia}}

{{firma:shallowCopy}} crea un objeto **nuevo**, con los mismos valores que el original tenía en ese
instante, y le da su propia identidad —`Caja#2`, no `Caja#1`—. Mutar la copia ya no toca el original: es
exactamente la diferencia con el ejemplo anterior. La copia es **superficial**: si un atributo fuera a su
vez un objeto, ese atributo interior se seguiría compartiendo entre el original y la copia, porque copiar
una referencia no copia lo que la referencia señala.

:::parte prediccion

- example-c3-alias#7#b ¿Qué identidad de objeto muestra la casilla `b` justo después de la sentencia `b <- a;`?

Antes de comprobarlo, decide si `b` va a mostrar una identidad nueva o la misma que `a` ya tenía, y por
qué la asignación de un objeto no puede crear una identidad que no existía.

:::parte errores-frecuentes

## Escribir un objeto directamente

Un objeto no tiene una representación de texto: escribirlo directamente no dice qué atributo mostrar,
así que el lenguaje lo rechaza en vez de inventar una conversión.

```pseudo
Clase Caja
    Publico Definir contenido Como Entero;
FinClase

Algoritmo EscribirObjeto
    Definir caja Como Caja;
    caja <- Nuevo Caja();
    Escribir caja;
FinAlgoritmo
```

{{diagnostico:objectCannotBeWritten}}

## Un nombre suelto dentro de un método que coincide con un atributo

Dentro de un método, un identificador sin `Este` delante nunca es un atributo: es un parámetro o una
variable local. Si coincide con el nombre de un atributo, lo más probable es que faltara `Este.` antes.

```pseudo
Clase Caja
    Privado Definir contenido Como Entero;

    Publico Metodo Vaciar()
        contenido <- 0;
    FinMetodo
FinClase

Algoritmo ProbarVaciar
FinAlgoritmo
```

{{diagnostico:identifierMatchesFieldWithoutThis}}

:::parte especificacion

- esp-o-clases Instanciación, identidad, copia superficial y las clases como tipos

:::parte ejercicios

- CON-C3-E1 Detectar si dos variables son el mismo objeto
- CON-C3-E2 Alias que muta un contador compartido
- CON-C3-E3 Copia que no afecta al original
- CON-C3-E4 Intercambiar el contenido de dos cajas
- CON-C3-E5 Nodo enlazado de dos elementos
- CON-C3-E6 Copiar y comparar identidades

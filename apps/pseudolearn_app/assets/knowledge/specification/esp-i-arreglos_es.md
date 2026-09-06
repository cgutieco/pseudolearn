# Arreglos

Un arreglo es una colección de casillas del mismo tipo a las que se llega por posición en vez de por
nombre. Es la primera estructura de datos del lenguaje y la única que no es un valor.

## Una sola sentencia declara el arreglo entero

Tras {{lexema:dimension}} van uno o más dimensionados separados por {{lexema:comma}}, y al final
{{lexema:typeConnector}} con el tipo de los elementos, que es común a todos ellos. Un dimensionado es
un nombre seguido de sus tamaños entre {{lexema:leftBracket}} y {{lexema:rightBracket}}, separados por
{{lexema:comma}} cuando hay más de una dimensión.

Se rechaza la forma de dos sentencias separadas —una para dimensionar y otra para tipar— y conviene
saber por qué: crea cuatro clases de error de emparejamiento que con una sola sentencia no existen
—dimensionado sin tipar, tipado sin dimensionar, dimensionado dos veces, y las dos sentencias en orden
invertido— a cambio de ninguna ventaja.

El tipo de los elementos puede ser cualquiera de los cinco primitivos o el nombre de una clase; en ese
caso los elementos empiezan **sin instanciar**.

{{ejemplo:example-esp-arreglos-declaracion}}

## El índice empieza en cero

Un arreglo declarado con N elementos admite los índices de 0 a N−1. Es una decisión del lenguaje y no
un dato del perfil: ningún perfil la cambia.

El criterio que la decide es el declarado del proyecto —la forma que prepara mejor para el lenguaje
real—: los lenguajes a los que se salta después indexan desde cero. Se rechaza por eso la base uno de
la notación académica.

{{ejemplo:example-esp-arreglos-indice-cero}}

## El tamaño es una expresión, y a veces tiene que ser constante

Sintácticamente un tamaño es siempre una expresión. Bajo el perfil estricto tiene que ser además una
**expresión constante**, y eso significa un literal o un operador aplicado a expresiones constantes.
No incluye nombres de variable, porque el lenguaje no tiene constantes con nombre.

Un tamaño **cero es válido**: el arreglo no admite ningún índice, y recorrerlo con un bucle contado
simplemente no itera. Un tamaño negativo es un fallo de ejecución, y un tamaño que no es entero es un
fallo de significado.

{{ejemplo:example-esp-arreglos-tamano-constante}}

## Un arreglo no es un valor

No se puede asignar entero, ni comparar, ni escribir en la salida, ni devolver desde una función. Solo
se accede a sus elementos.

Declararlo así no es una restricción caprichosa: es lo que permite un diagnóstico específico —«un
arreglo no es un valor»— en vez de un error de tipos confuso, y es lo que decide, más adelante, que los
arreglos se pasen siempre por referencia.

```pseudo
Algoritmo ErrorArregloValor
  Dimension a[3] Como Entero
  Escribir a
FinAlgoritmo
```

{{diagnostico:arrayCannotBeUsedAsValue}}

## Acceso a un elemento

Un elemento se alcanza escribiendo el nombre seguido de sus índices entre {{lexema:leftBracket}} y
{{lexema:rightBracket}}, separados por {{lexema:comma}}. **Un solo par de corchetes para cualquier
número de dimensiones**, nunca corchetes encadenados.

Es coherente con la forma del dimensionamiento y convierte «el número de índices coincide con las
dimensiones declaradas» en una regla única y comprobable en un solo sitio. La forma encadenada tiene
diagnóstico propio, porque es exactamente lo que escribe quien viene de otro lenguaje.

Los índices se evalúan de izquierda a derecha, una sola vez cada uno.

{{ejemplo:example-esp-arreglos-acceso}}

## Qué falla, y cuándo se nota

Un número de índices distinto del de dimensiones declaradas y un índice que no es entero se detectan
sin ejecutar. Un índice fuera de rango, por arriba o por abajo, es un fallo de ejecución y señala
exactamente el índice culpable, porque su valor no se conoce antes.

En un arreglo de tamaño cero **cualquier** índice está fuera de rango, y ese es el caso límite que
conviene tener escrito para no confundirlo con un error de declaración.

```pseudo
Algoritmo ErrorCorchetesEncadenados
  Dimension m[2, 2] Como Entero
  m[0][1] <- 5
FinAlgoritmo
```

{{diagnostico:chainedArrayAccess}}

:::parte pregunta

Guardar cinco notas exige cinco casillas, y guardar cien exige cien. Declararlas una por una con un
nombre distinto cada vez deja de ser razonable mucho antes de llegar a cien. Este módulo introduce una
sola casilla con muchos compartimentos: una fila entera de valores del mismo tipo, con un número en vez
de un nombre para elegir cuál.

:::parte modelo-maquina

{{figura:arreglo-indexado}}

Un arreglo es un tramo contiguo de casillas del mismo tipo, con un único nombre y un índice que elige
el compartimento. El índice **empieza en cero**: el primer compartimento es el 0, y un arreglo de N
elementos llega hasta el N−1, nunca hasta N. No es una convención local: es la misma base que van a
usar los lenguajes reales que vienen después, y aprenderla aquí evita reaprenderla.

:::parte desarrollo

## Declarar un arreglo es una sola sentencia

{{ejemplo:example-b5-recorrido}}

{{lexema:dimension}} declara el nombre, el tamaño y el tipo de los elementos en una sola sentencia: no
hay una sentencia para el tamaño y otra para el tipo. Recorrer un arreglo entero, para llenarlo o para
leerlo, es el patrón más común de todos: un bucle contado cuyo índice va de 0 al tamaño menos uno.

## Un arreglo no es un valor

Un arreglo no se asigna entero, no se compara y no se escribe de una vez: solo se accede a sus
elementos, uno por uno, con el índice entre corchetes. Pedir el valor completo del arreglo como si
fuera un número es exactamente el error que la sección de errores frecuentes de este módulo muestra.

## Buscar un elemento

{{ejemplo:example-b5-busqueda}}

Buscar es recorrer con un bucle contado y comparar cada elemento con el valor buscado. Si el elemento
aparece, su índice se guarda y el recorrido puede seguir sin que eso cambie el resultado: lo importante
es que el índice quede en la casilla `indice` antes de que el bucle termine. Si nunca aparece, `indice`
conserva el valor con el que se inicializó, que por eso es un valor que ningún índice real puede tomar.

## Dos dimensiones: el mismo corchete, dos índices

{{ejemplo:example-b5-matriz}}

Una matriz es un arreglo de dos dimensiones: un solo par de corchetes con dos índices separados por
coma, `datos[fila, columna]`, nunca dos pares de corchetes encadenados. Recorrerla entera es un bucle
contado dentro de otro: el de afuera avanza por fila, el de adentro por columna, y juntos visitan cada
compartimento exactamente una vez.

:::parte prediccion

- example-b5-busqueda#9#indice Con los números 4, 8, 15, 16, 23 y buscando el 15, ¿qué valor tiene `indice` al terminar el programa?

Antes de comprobarlo, decide en qué posición del arreglo está el 15 —recordando que la primera posición
es la 0, no la 1— y compáralo con el valor que esperabas.

:::parte errores-frecuentes

## Un índice que no es entero

Un índice elige un compartimento, y los compartimentos se cuentan con números enteros. Un índice real
no señala ninguno en concreto.

```pseudo
Algoritmo IndiceNoEntero
    Dimension numeros[5] Como Entero;
    Definir i Como Real;
    i <- 1.5;
    Escribir numeros[i];
FinAlgoritmo
```

{{diagnostico:nonIntegerArrayIndex}}

## Menos índices de los que el arreglo tiene dimensiones

Un arreglo de dos dimensiones necesita dos índices entre los mismos corchetes, separados por coma. Uno
solo no basta, y dos pares encadenados tampoco existen en este lenguaje.

```pseudo
Algoritmo NumeroDeIndicesIncorrecto
    Dimension datos[3, 3] Como Entero;
    Escribir datos[0];
FinAlgoritmo
```

{{diagnostico:arrayDimensionCountMismatch}}

:::parte especificacion

- esp-i-arreglos Dimensionamiento, base cero y acceso a un elemento

:::parte ejercicios

- CON-B5-E1 Suma de los elementos de un vector
- CON-B5-E2 Elemento mayor de un vector
- CON-B5-E3 Invertir un vector
- CON-B5-E4 Buscar un valor en un vector
- CON-B5-E5 Suma de una matriz 2x2
- CON-B5-E6 Diagonal principal de una matriz 3x3

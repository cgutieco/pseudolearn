:::parte pregunta

Un algoritmo que resuelve tres problemas parecidos escribiendo tres veces casi el mismo código no se
puede corregir en un solo sitio cuando algo cambia. Este módulo introduce el subprograma: una pieza de
código con nombre, que recibe datos por sus parámetros y que se puede llamar una y otra vez desde
cualquier parte del algoritmo.

:::parte modelo-maquina

Cada llamada a un subprograma abre su **propio marco** de memoria, con sus propias casillas, separado
del marco del algoritmo y de cualquier otra llamada. Las variables del algoritmo no son visibles dentro
de un subprograma: toda la comunicación pasa por los parámetros, que son casillas nuevas creadas al
entrar, y por el valor de retorno, si el subprograma declara uno. Al terminar la llamada, ese marco
desaparece entero.

:::parte desarrollo

## Una función devuelve un valor; un procedimiento no

{{ejemplo:example-b6-funcion}}

{{lexema:subroutine}} es una sola construcción para las dos cosas. Si declara un tipo de retorno con
{{lexema:typeConnector}}, se llama dentro de una expresión y tiene que terminar con
{{lexema:returnKeyword}} en algún camino. Si no lo declara, se llama como una sentencia por su cuenta y
no devuelve nada.

## Por valor copia; por referencia comparte la misma casilla

{{ejemplo:example-b6-referencia}}

Un parámetro **por valor** —la marca por omisión— recibe una copia: lo que el subprograma haga con él
no se ve fuera. Un parámetro {{lexema:byReference}} no recibe una copia, recibe **la misma casilla** que
el argumento nombra, así que un cambio dentro del subprograma es un cambio en la variable de quien lo
llamó. Por eso intercambiar dos valores solo funciona si los dos parámetros son por referencia: con una
copia no hay forma de que el cambio salga del subprograma.

## Los arreglos siempre se pasan por referencia

{{ejemplo:example-b6-arreglo-parametro}}

Un arreglo no es un valor, así que no hay nada que copiar: pasarlo por valor no tiene sentido y el
lenguaje lo rechaza. Un parámetro de arreglo se escribe con los corchetes vacíos —`datos[]` para una
dimensión— porque el tamaño ya lo trae el arreglo que se pasó; el subprograma no lo vuelve a declarar.

:::parte prediccion

- example-b6-referencia#8#n1 Con las entradas 3 y 9, ¿qué valor tiene `n1` justo después de que termine la llamada a `Intercambiar`?

Antes de comprobarlo, decide qué pasaría si `Intercambiar` recibiera sus dos parámetros por valor en vez
de por referencia: ¿cambiaría `n1` en el algoritmo que llama?

:::parte errores-frecuentes

## Llamar con menos o más argumentos de los que el subprograma espera

El número de argumentos de una llamada tiene que coincidir exactamente con el número de parámetros
declarados. No hay parámetros opcionales.

```pseudo
SubProceso Sumar(a Como Entero, b Como Entero) Como Entero
    Retornar a + b;
FinSubProceso

Algoritmo LlamadaConArgumentosDeMas
    Escribir Sumar(1, 2, 3);
FinAlgoritmo
```

{{diagnostico:argumentCountMismatch}}

## Un argumento de un tipo que no corresponde

El tipo de cada argumento tiene que ser compatible con el tipo del parámetro que recibe.

```pseudo
SubProceso Duplicar(n Como Entero) Como Entero
    Retornar n * 2;
FinSubProceso

Algoritmo LlamadaConTipoIncorrecto
    Escribir Duplicar("cinco");
FinAlgoritmo
```

{{diagnostico:incompatibleArgumentType}}

## Pasar un literal a un parámetro por referencia

Un parámetro por referencia necesita un sitio donde escribir; un literal o el resultado de una cuenta no
tienen dónde guardar nada.

```pseudo
SubProceso Incrementar(n Como Entero Por Referencia)
    n <- n + 1;
FinSubProceso

Algoritmo ReferenciaSinDesignador
    Incrementar(5);
FinAlgoritmo
```

{{diagnostico:byReferenceArgumentRequiresDesignator}}

## Retornar fuera de un subprograma

{{lexema:returnKeyword}} solo tiene sentido dentro del cuerpo de un subprograma: el algoritmo no
devuelve nada a nadie.

```pseudo
Algoritmo RetornoFueraDeSubprograma
    Definir n Como Entero;
    n <- 5;
    Retornar n;
FinAlgoritmo
```

{{diagnostico:returnOutsideSubroutine}}

:::parte especificacion

- esp-i-subprogramas Una sola construcción, parámetros, paso, retorno, ámbito y recursión

:::parte ejercicios

- CON-B6-E1 Función cuadrado
- CON-B6-E2 Función máximo de dos números
- CON-B6-E3 Procedimiento que intercambia dos variables
- CON-B6-E4 Procedimiento que duplica un vector
- CON-B6-E5 Función que cuenta elementos mayores que un límite
- CON-B6-E6 Procedimiento que ordena dos variables

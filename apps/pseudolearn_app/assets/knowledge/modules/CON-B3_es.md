:::parte pregunta

Hasta ahora todo programa hace exactamente los mismos pasos sin importar los datos que reciba. Eso no
alcanza para casi nada útil: aprobar o no depende de la nota, y el mensaje que corresponde depende de
qué día es. Este módulo introduce las dos formas de bifurcar el camino que sigue un programa según lo
que sus datos digan.

:::parte modelo-maquina

Bifurcar no cambia el modelo de memoria: sigue siendo la misma fila de casillas. Lo que cambia es que
ahora **no todas las sentencias del texto se ejecutan siempre**. Cuál cuerpo se ejecuta depende del
valor de una expresión, evaluada una sola vez, en el instante en que la ejecución llega a la
bifurcación. Rastrear un programa con bifurcaciones exige la misma tabla de prueba de siempre, con una
columna nueva: qué rama se tomó, y por qué.

:::parte desarrollo

## El condicional: dos caminos, uno de los dos

{{ejemplo:example-b3-aprobado}}

{{diagrama:example-b3-aprobado#ordinograma}}

{{lexema:ifKeyword}} evalúa una expresión que tiene que ser de tipo lógico. Si es verdadera se ejecuta
el cuerpo de {{lexema:then}}; si no, el de {{lexema:elseKeyword}}, que es opcional. Ausente, no hacer
nada es la rama contraria. La palabra intermedia {{lexema:then}} es obligatoria siempre: da un punto de
sincronización claro, y sin ella el error sería genérico en vez de nombrar exactamente qué falta.

El mismo condicional, en estructograma:

{{diagrama:example-b3-aprobado#estructograma}}

**No hay una construcción propia para «si no, si»**. Encadenar condiciones es anidar un condicional
dentro de la rama contraria del anterior, cada uno con su propio cierre. El árbol no tiene un nodo de
cadena: lo que hay es un condicional dentro de otro, tantas veces como haga falta.

## La selección múltiple: una expresión, varias etiquetas

{{ejemplo:example-b3-dia-semana}}

{{lexema:switchKeyword}} evalúa su expresión **una sola vez** y la compara con las etiquetas de cada
rama, en orden. Las etiquetas son literales, nunca expresiones: eso es lo que permite detectar una
etiqueta repetida sin tener que evaluar nada. Una vez que una rama coincide se ejecuta su cuerpo y la
ejecución sigue después del cierre: no hay caída de una rama a la siguiente rama. La rama
{{lexema:defaultCase}} es opcional y, si aparece, tiene que ser la última.

:::parte prediccion

- example-b3-dia-semana#3# Con la entrada 6, ¿qué línea exacta escribe el programa?

Antes de comprobarlo, decide con qué etiqueta compara primero el valor 6, y con cuál coincide.

:::parte errores-frecuentes

## Una condición que no es lógica

La expresión de {{lexema:ifKeyword}} tiene que producir verdadero o falso. Un número no lo es, aunque
distinto de cero «se sienta» verdadero en otros lenguajes: aquí no hay esa conversión implícita.

```pseudo
Algoritmo CondicionNoLogica
    Definir nota Como Entero;
    nota <- 5;
    Si nota Entonces
        Escribir "Aprobado";
    FinSi
FinAlgoritmo
```

{{diagnostico:nonBooleanCondition}}

## Un condicional que nunca se cierra

Todo {{lexema:ifKeyword}} necesita su {{lexema:endIf}}. Sin él, el analizador no puede saber dónde
termina el cuerpo y dónde sigue el resto del programa.

```pseudo
Algoritmo CondicionalSinCierre
    Definir nota Como Entero;
    nota <- 5;
    Si nota >= 5 Entonces
        Escribir "Aprobado";
FinAlgoritmo
```

{{diagnostico:unclosedIfStatement}}

## Una etiqueta que aparece dos veces

Cada valor solo puede pertenecer a una rama. Si dos ramas distintas nombran la misma etiqueta, la
segunda nunca se puede alcanzar.

```pseudo
Algoritmo EtiquetaRepetida
    Definir dia Como Entero;
    dia <- 3;
    Segun dia Hacer
        1, 7:
            Escribir "Fin de semana";
        7:
            Escribir "Otra vez";
    FinSegun
FinAlgoritmo
```

{{diagnostico:duplicateSwitchCaseLabel}}

:::parte especificacion

- esp-i-control El condicional, la selección múltiple y los tres bucles
- esp-i-operadores El tipo lógico y sus operadores

:::parte ejercicios

- CON-B3-E1 Par o impar
- CON-B3-E2 Fin de semana o día laboral
- CON-B3-E3 Clasificación de una nota
- CON-B3-E4 Mayor de dos números
- CON-B3-E5 Menú de operaciones
- CON-B3-E6 Categoría de una edad

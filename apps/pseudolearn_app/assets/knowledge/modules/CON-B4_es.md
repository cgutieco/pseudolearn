:::parte pregunta

Repetir un paso diez veces escribiéndolo diez veces funciona, hasta que hacen falta cien, o hasta que
no se sabe de antemano cuántas veces hacen falta. Este módulo introduce las tres formas de repetir un
cuerpo de sentencias sin repetir su texto, y el criterio para elegir cuál de las tres corresponde en
cada caso.

:::parte modelo-maquina

Un bucle no añade ninguna casilla nueva ni ninguna regla nueva sobre lo que una asignación hace: sigue
siendo la misma memoria de siempre. Lo que cambia es que la tabla de prueba deja de tener una fila por
sentencia y pasa a tener una fila **por vuelta**, porque la misma sentencia se ejecuta con valores
distintos cada vez que el control vuelve a ella. Rastrear un bucle a mano, vuelta por vuelta, es la
única forma de ver con certeza cuándo termina y con qué valor queda cada casilla.

:::parte desarrollo

## Mientras: la condición se revisa antes de entrar

{{ejemplo:example-b4-mientras}}

{{diagrama:example-b4-mientras#ordinograma}}

{{lexema:whileKeyword}} evalúa su condición **antes** de cada vuelta, incluida la primera. Si es falsa
desde el principio, el cuerpo no se ejecuta ni una sola vez, y eso no es un error: es exactamente lo
que corresponde cuando el dato de entrada ya no cumple lo que el bucle necesita.

En estructograma, la condición vive en la parte de arriba del bloque, antes del cuerpo:

{{diagrama:example-b4-mientras#estructograma}}

## Repetir: la condición se revisa después de salir

{{ejemplo:example-b4-repetir}}

{{diagrama:example-b4-repetir#ordinograma}}

{{lexema:repeat}} ejecuta el cuerpo y **después** evalúa la condición de salida. Por eso el cuerpo
corre **al menos una vez**, siempre, sin excepción: no hay forma de que la condición impida la primera
vuelta, porque todavía no existe cuando esa vuelta ocurre. Es la forma correcta para «pedir datos hasta
que uno de ellos diga que hay que parar», porque el primer dato hay que pedirlo sí o sí.

El mismo bucle, en estructograma, con la condición abajo:

{{diagrama:example-b4-repetir#estructograma}}

## Para: cuando el número de vueltas ya se conoce

{{ejemplo:example-b4-para}}

{{lexema:forKeyword}} fija de antemano el valor inicial, el final y el paso —uno, si no se escribe—, y
los tres se evalúan **una sola vez**, antes de la primera vuelta. La dirección del recorrido la decide
el signo del paso, nunca la relación entre el valor inicial y el final: con paso positivo se avanza
mientras la variable de control sea menor o igual que el final, y con paso negativo mientras sea mayor
o igual. Al terminar, la variable de control **conserva el primer valor que ya no cumplió la
condición**, no el último que sí la cumplió.

## Cuál bucle corresponde a cada caso

Tres preguntas, en este orden, deciden cuál construcción usar: ¿el número de vueltas se conoce antes de
empezar? Entonces {{lexema:forKeyword}}. Si no se conoce, ¿el cuerpo tiene que ejecutarse al menos una
vez sin importar la condición? Entonces {{lexema:repeat}}. Si ni siquiera eso está garantizado, entonces
{{lexema:whileKeyword}}, que es el único de los tres que puede terminar sin haber ejecutado el cuerpo ni
una sola vez.

:::parte prediccion

- example-b4-para#7#i Con la entrada de este ejemplo, ¿qué valor tiene `i` justo después de que el bucle termine?

Antes de comprobarlo, decide cuál fue el último valor de `i` que **sí** cumplió la condición, y cuál fue
el primero que **no** la cumplió. La variable de control se queda con uno de los dos: no es el que la
mayoría espera a primera vista.

:::parte errores-frecuentes

## Un bucle Mientras que nunca se cierra

Todo {{lexema:whileKeyword}} necesita su {{lexema:endWhile}}. Sin él, el analizador no sabe dónde
termina el cuerpo del bucle y dónde sigue el resto del algoritmo.

```pseudo
Algoritmo BucleSinCierre
    Definir i Como Entero;
    i <- 3;
    Mientras i > 0 Hacer
        Escribir i;
        i <- i - 1;
FinAlgoritmo
```

{{diagnostico:unclosedWhileStatement}}

## Un bucle Repetir sin su condición de salida

{{lexema:repeat}} no tiene una palabra de cierre propia: es la cláusula {{lexema:until}} la que cierra
el bloque. Sin ella, el bucle queda abierto igual que si le faltara cualquier otro cierre.

```pseudo
Algoritmo RepetirSinCierre
    Definir n Como Entero;
    Repetir
        Leer n;
        Escribir n;
FinAlgoritmo
```

{{diagnostico:unclosedRepeatStatement}}

## Un bucle Para que nunca se cierra

Igual que los otros dos, {{lexema:forKeyword}} necesita su {{lexema:endFor}}.

```pseudo
Algoritmo ParaSinCierre
    Definir i Como Entero;
    Para i <- 1 Hasta 5 Hacer
        Escribir i;
FinAlgoritmo
```

{{diagnostico:unclosedForStatement}}

## Un límite que no es entero

El valor final de {{lexema:forKeyword}} tiene que ser de tipo entero, igual que el valor inicial y el
paso: la variable de control avanza en pasos enteros, y compararla contra un límite real no tiene un
significado exacto.

```pseudo
Algoritmo LimiteNoEntero
    Definir i Como Entero;
    Definir limite Como Real;
    limite <- 5.5;
    Para i <- 1 Hasta limite Hacer
        Escribir i;
    FinPara
FinAlgoritmo
```

{{diagnostico:nonIntegerForBound}}

:::parte especificacion

- esp-i-control El condicional, la selección múltiple y los tres bucles

:::parte ejercicios

- CON-B4-E1 Cuenta regresiva
- CON-B4-E2 Cuenta de lecturas hasta el centinela
- CON-B4-E3 Suma de un rango
- CON-B4-E4 Suma de múltiplos de tres
- CON-B4-E5 Cantidad de cifras de un número
- CON-B4-E6 Cuenta regresiva con paso variable

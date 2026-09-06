:::parte pregunta

Algunos problemas se resuelven de forma natural describiéndolos en términos de una versión más pequeña
de sí mismos: el factorial de 5 es 5 por el factorial de 4. Este módulo introduce la recursión, un
subprograma que se llama a sí mismo, y la pila de llamadas que hace posible seguirle el rastro.

:::parte modelo-maquina

{{figura:pila-de-llamadas}}

Cada llamada recursiva abre un marco nuevo, exactamente como cualquier otra llamada de la sección
anterior, y esos marcos se apilan: el más reciente es el único activo, y los de abajo esperan a que
termine para retomar donde se quedaron. La pila de llamadas es esa estructura de marcos, uno encima del
otro. No es una metáfora suelta: es literalmente el mecanismo que decide qué casillas están vivas en
cada paso.

:::parte desarrollo

## Caso base y caso recursivo

{{ejemplo:example-b7-factorial}}

Toda recursión que termina tiene dos partes: un **caso base**, que responde sin volver a llamarse, y un
**caso recursivo**, que responde en términos de una llamada con un dato más pequeño. `Factorial` para en
`n <= 1` sin llamarse otra vez; para cualquier otro `n`, se llama a sí mismo con `n - 1`, que está más
cerca del caso base que `n`. Sin el caso base, la pila de llamadas crece sin parar.

## Cada llamada tiene su propio `n`

{{ejemplo:example-b7-suma}}

`SumaHasta(5)` no comparte su `n` con `SumaHasta(4)`: cada marco de la pila tiene el suyo, con su propio
valor, aunque las dos llamadas ejecuten el mismo texto del subprograma. Rastrear una recursión a mano
exige dibujar la pila entera, marco por marco, y leer el valor de una variable significa siempre «en el
marco que está activo ahora».

## El límite de profundidad

Este lenguaje detiene una recursión que se llama a sí misma mil veces seguidas sin terminar, con un
diagnóstico de ejecución en vez de agotar la memoria de la máquina. Una recursión sin caso base, o con
un caso base que nunca se alcanza, llega a ese límite casi de inmediato.

:::parte prediccion

- example-b7-factorial#12#n Con la entrada 4, cuando `Factorial` se llama a sí misma por última vez —la que sí resuelve el caso base—, ¿qué valor tiene `n` en ese marco?

Antes de comprobarlo, dibuja en un papel las cuatro llamadas de `Factorial(4)`, `Factorial(3)`,
`Factorial(2)` y `Factorial(1)`, apiladas una encima de otra, y marca cuál es la única con un caso base
que no vuelve a llamarse.

:::parte errores-frecuentes

## Un subprograma con tipo de retorno que nunca retorna

Un subprograma que declara qué tipo devuelve tiene que retornar ese valor en algún camino de su cuerpo.
Un caso base que solo escribe el resultado en vez de retornarlo deja al subprograma sin ninguna
sentencia de retorno.

```pseudo
SubProceso FactorialSinRetorno(n Como Entero) Como Entero
    Si n <= 1 Entonces
        Escribir 1;
    FinSi
FinSubProceso

Algoritmo FaltaRetorno
    Escribir FactorialSinRetorno(3);
FinAlgoritmo
```

{{diagnostico:subroutineWithoutReturn}}

:::parte especificacion

- esp-i-subprogramas Una sola construcción, parámetros, paso, retorno, ámbito y recursión

:::parte ejercicios

- CON-B7-E1 Factorial recursivo
- CON-B7-E2 Suma recursiva de 1 a n
- CON-B7-E3 Potencia recursiva
- CON-B7-E4 Cantidad de cifras recursiva
- CON-B7-E5 Suma de un vector, recursiva
- CON-B7-E6 Fibonacci recursivo

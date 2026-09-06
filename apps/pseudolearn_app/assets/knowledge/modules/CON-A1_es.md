:::parte pregunta

Antes de escribir una sola palabra clave conviene preguntar qué es exactamente un algoritmo, porque
«unas instrucciones que resuelven el problema» no alcanza como respuesta: una receta también son
instrucciones, y una receta mal escrita dos personas la siguen de dos formas distintas. Un algoritmo no
admite eso. Este módulo no enseña sintaxis todavía: enseña qué tiene que ser cierto de una secuencia de
pasos para que merezca llamarse algoritmo.

:::parte modelo-maquina

Un algoritmo es una secuencia de pasos **finita**, **precisa** y **no ambigua**, que empieza en un
punto declarado y termina en un número determinado de pasos. Cada palabra de esa frase descarta algo:
finita descarta «repetir para siempre sin condición de salida»; precisa descarta un paso que dos
personas puedan interpretar de dos maneras distintas; no ambigua descarta que el resultado dependa de
en qué orden alguien decida leer los pasos. El orden en que están escritos los pasos **es** el orden en
que ocurren. No hay un segundo orden posible, y esa es la diferencia entre un algoritmo y una lista de
sugerencias.

:::parte desarrollo

## Qué hace que una secuencia sea precisa

Tres condiciones, y las tres se pueden comprobar mirando el texto sin ejecutarlo:

1. **Cada paso tiene un único significado.** «Calcula el total» no es un paso: no dice con qué datos
   ni con qué operación. «Suma el precio y el impuesto» sí lo es.
2. **El paso siguiente está siempre determinado.** Nunca hace falta adivinar cuál sigue; se lee de
   arriba hacia abajo y no hay otra alternativa hasta que el propio texto declare una.
3. **Empieza y termina en un punto marcado.** Un algoritmo sin principio ni fin declarado no es un
   algoritmo incompleto: no es un algoritmo, porque no se puede decir dónde arrancar ni cuándo parar.

{{ejemplo:example-a1-vuelto}}

Ese programa cumple las tres condiciones: cada paso hace una sola cosa, el orden en que aparecen es el
orden en que ocurren, y el marco `Proceso` / `FinProceso` declara sin ambigüedad dónde empieza y dónde
termina.

## El orden no es un detalle de estilo

{{ejemplo:example-a1-promedio}}

El promedio de `n1`, `n2` y `n3` no se puede calcular antes de tener la suma completa. Escribir la
línea de la división antes que la de la suma no sería una variante de estilo: sería un algoritmo
distinto, y probablemente uno que ni siquiera se pueda ejecutar todavía, porque `suma` aún no tendría
el valor que la división necesita. El orden de escritura y el orden de ejecución son la misma cosa.

:::parte prediccion

Antes de mirar el resultado, decide en qué orden se calculan las tres cosas del ejemplo **Promedio de tres notas**:
la suma de las tres notas, la división entre tres, y la escritura del resultado. Escríbelo en un papel
como una lista numerada. Después compara tu lista con el orden real de las líneas del programa: tienen
que coincidir exactamente, porque en un algoritmo no hay otro orden posible que el que el texto declara.

:::parte errores-frecuentes

## Empezar sin declarar dónde empieza el algoritmo

Un algoritmo necesita su marco. Sin la palabra que lo abre, no hay forma de saber si lo que sigue es
parte de un algoritmo o una instrucción suelta fuera de cualquier programa.

```pseudo
Definir n Como Entero;
n <- 5;
Escribir n;
```

{{diagnostico:expectedAlgorithmStart}}

:::parte especificacion

- esp-i-lexico Cómo se reconoce dónde empieza y dónde termina un programa

:::parte pregunta

Un algoritmo escrito no es todavía un algoritmo que se entiende. Para entenderlo hace falta poder decir,
en cualquier punto, qué valor tiene cada nombre en ese instante exacto. Este módulo presenta la máquina
que guarda esos valores y la herramienta —la tabla de prueba— con la que se sigue su rastro sin
ejecutar nada de verdad.

:::parte modelo-maquina

{{figura:cajas-memoria}}

La memoria de un programa es una fila de casillas con nombre. Cada casilla guarda un valor, y ese valor
cambia solo cuando una asignación lo dice explícitamente. Para saber qué hay en cada casilla en un
momento dado no hace falta ejecutar el programa: alcanza con leer las sentencias, en orden, y anotar
qué cambia en cada una. Eso es rastrear un programa, y la tabla de prueba es la forma ordenada de
hacerlo: una columna por casilla, una fila por paso.

:::parte desarrollo

## Cómo se construye una tabla de prueba

{{ejemplo:example-a2-acumulador}}

Antes de ejecutarlo, la tabla se construye leyendo el programa de arriba hacia abajo y anotando el
valor de cada casilla después de cada sentencia que la toca. Las casillas que una sentencia no toca
conservan su valor anterior, y eso también se anota.

| Paso | Sentencia               | `total` | `n` |
|------|--------------------------|---------|-----|
| 1    | `total <- 0;`            | 0       | —   |
| 2    | `n <- 5;`                | 0       | 5   |
| 3    | `total <- total + n;`    | 5       | 5   |
| 4    | `n <- 3;`                | 5       | 3   |
| 5    | `total <- total + n;`    | 8       | 3   |

La columna de `total` no se «recalcula desde cero» en cada fila: cada valor nuevo se construye sobre el
valor que la fila anterior dejó. Esa dependencia con el paso anterior es, otra vez, la idea completa de
la sección 2 de este bloque: casi todo lo que sorprende de un programa se explica mirando qué había en
cada casilla un paso antes.

## Por qué la tabla va antes que el editor

Rastrear en papel obliga a decidir, sentencia por sentencia, qué cambia y qué no. Ejecutar directamente
en el editor deja ver el resultado final sin pasar por esa decisión, y el resultado final no enseña
nada sobre dónde estaba el error si la predicción no coincide. Por eso la tabla se construye primero, a
mano, y la ejecución paso a paso se usa después, para comprobarla.

:::parte prediccion

- example-a2-acumulador#7#total ¿Qué valor tiene `total` justo después de la segunda vez que se ejecuta `total <- total + n;`?

Construye la tabla de prueba completa del ejemplo **Acumulador simple** en un papel antes de comprobar tu
respuesta. Si tu tabla no coincide con la ejecución real, revisa fila por fila hasta encontrar la
primera en la que se separan: ahí está lo que tu modelo de la máquina todavía no tiene claro.

:::parte errores-frecuentes

## Usar un nombre que nunca se declaró

Toda casilla necesita pedirse antes de usarse. Un nombre que aparece sin una declaración previa en
todo el programa no tiene casilla asociada, y no hay valor posible que leer o escribir ahí.

```pseudo
Algoritmo VariableFantasma
    contador <- 1;
    Escribir contador;
FinAlgoritmo
```

{{diagnostico:undeclaredVariable}}

## Usar un nombre antes de la línea que lo declara

Declarar una casilla y usarla son dos pasos distintos, y el primero tiene que ocurrir antes que el
segundo **en el texto**, no solo en la intención de quien escribe.

```pseudo
Algoritmo OrdenIncorrecto
    total <- total + 1;
    Definir total Como Entero;
    Escribir total;
FinAlgoritmo
```

{{diagnostico:variableUsedBeforeDeclaration}}

:::parte especificacion

- esp-i-declaracion La forma exacta de declarar una casilla y de asignarle un valor
- esp-i-tipos-primitivos Los cinco tipos que puede admitir una casilla

:::parte ejercicios

- CON-A2-E1 Segundos en un intervalo de minutos
- CON-A2-E2 Total de una compra
- CON-A2-E3 Completar el perímetro de un cuadrado
- CON-A2-E4 Del precio al promedio de dos precios
- CON-A2-E5 Área de un triángulo
- CON-A2-E6 De Fahrenheit a Celsius

---
id: imperativo.mientras
numero: "1.3"
tipo: leccion
titulo: Repetir mientras haga falta
duracion: 30
problema_breve: La alcancía de Lucía
necesita: [imperativo.caminos]
introduce: [bucle, vuelta, rol-de-variable, contador, acumulador, tabla-por-vuelta, invariante, bucle-infinito, centinela]
usa: [variable, asignar, condicion, caso-borde, ficha-del-problema, leer-dato, ejemplo-a-mano]
pieza: 4
---

::: frase
Cuando no sabes cuántas veces hay que hacer algo, pero sí sabes cuándo parar, repites mientras no se cumpla esa condición.
:::

## El problema {#problema}

::: problema
Lucía quiere comprar una pelota que cuesta **50 monedas**. El primer día guarda **2 monedas** en su alcancía, y cada día guarda **una moneda más** que el día anterior.

**¿Qué día puede comprar la pelota, y cuántas monedas tendrá ese día?**
:::

## Inténtalo {#intentalo}

::: intento
Resuélvelo a mano. Haz una tabla con una fila por día: cuánto guarda y cuánto lleva juntado.
:::

::: respuesta
Guarda 2, 3, 4, 5… y lleva juntado 2, 5, 9, 14, 20, 27, 35, 44 y 54. El **día 9** llega a **54 monedas** y puede comprar la pelota.

Fíjate en lo que hiciste: repetiste las mismas dos cuentas nueve veces, y paraste cuando lo juntado alcanzó el precio. Antes de empezar no sabías que iban a ser nueve.
:::

## Entender {#entender fase=1}

::: recuerda termino=ficha-del-problema
:::

::: ficha
- entra: el precio de la pelota. El primer día se guardan 2 monedas y cada día una más.
- sale: el día en que se puede comprar y las monedas juntadas ese día.
- relacion: se suma lo de cada día hasta que lo juntado alcanza o supera el precio.
- ejemplo: precio 50 → día 9, con 54 monedas.
- ejemplo: precio 54 → también día 9, con 54: es justo el precio, y alcanza.
- ejemplo: precio 2 → día 1, con 2: le alcanza el primer día, sin esperar.
:::

Los dos últimos ejemplos son casos borde: están justo en el límite donde un programa apurado se equivoca.

## Planear {#planear fase=2}

Con lo que sabes hasta ahora, tendrías que escribir las cuentas una vez por día: nueve veces para 50 monedas, cuarenta y cuatro para 1000. Y si el precio lo escribe Lucía al usar el programa, ni siquiera sabrías cuántas. Mira tu tabla a mano. En cada fila hiciste lo mismo:

1. Pasa un día.
2. Ese día se guarda una moneda más que el anterior.
3. Lo de ese día se suma a lo juntado.

Y antes de cada fila te preguntaste lo mismo: ¿todavía no alcanza? Si la respuesta es sí, haces otra fila. Si es no, terminaste.

Las tres cajas que necesitas no cambian de la misma manera, y reconocer para qué sirve cada una es la mitad de la solución. Para qué sirve una caja es su [[def:rol-de-variable|rol]]:

::: roles
- contador | ruta-rol-contador | Avanza siempre lo mismo en cada vuelta: el día sube de 1 en 1, y lo que se guarda cada día también.
- acumulador | ruta-rol-acumulador | Va juntando: en cada vuelta se le suma algo nuevo a lo que ya tenía. Es la alcancía.
:::

Un [[def:contador|contador]] avanza lo mismo cada vez; un [[def:acumulador|acumulador]] va juntando. Vas a encontrarlos en casi todos los problemas que repiten algo.

## La herramienta nueva {#herramienta}

Un [[def:bucle|bucle]] es un grupo de instrucciones que se repite. Cada repetición se llama una [[def:vuelta|vuelta]]. `Mientras` repite su grupo de instrucciones mientras una condición sea verdadera. La condición se pregunta antes de cada vuelta; cuando es falsa, el programa sigue con lo que está después de `FinMientras`.

```figura-especificacion seccion=control.mientras figura=mientras-ciclo
```

```programa id=cuenta-regresiva titulo="Cuenta regresiva" ejecutar
Algoritmo CuentaRegresiva
  Definir n Como Entero <- 3;
  Mientras n > 0 Hacer
    Escribir n;
    n <- n - 1;
  FinMientras
  Escribir "¡Ya!";
FinAlgoritmo
```

```salida
3
2
1
¡Ya!
```

En un bucle, la misma instrucción se ejecuta muchas veces, cada vez con valores distintos en las cajas. Para seguirlo a mano se usa una [[def:tabla-por-vuelta|tabla por vuelta]]: una columna por caja y una fila por vuelta, con los valores al terminar esa vuelta.

```figura id=ruta-tabla-por-vuelta
pie: Cada fila es una vuelta. La tabla deja ver qué cambia y qué se mantiene.
paso: Antes del bucle: el día 1, Lucía guardó 2 y tiene 2.
paso: Primera vuelta: pasa al día 2, guarda 3 y junta 5.
paso: Segunda vuelta: día 3, guarda 4 y junta 9.
paso: Cuando lo juntado alcanza el precio, la condición es falsa y el bucle termina.
```

::: especificacion
- control.mientras
:::

## Escribir {#escribir fase=3}

El día 1 ya está hecho antes de empezar a repetir: Lucía guardó 2 monedas. El bucle se encarga de los días siguientes, y la condición es la pregunta del plan, «¿todavía no alcanza?»:

```programa id=alcancia titulo="La alcancía de Lucía" ejecutar
Algoritmo Alcancia
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro < 50 Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Lucía compra la pelota el día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```salida
Lucía compra la pelota el día 9 con 54 monedas
```

Las tres líneas dentro del bucle son los tres pasos del plan, en el mismo orden. La condición es la pregunta. Si el plan es claro, el programa casi se escribe solo.

## Probar {#probar fase=4}

El programa dice día 9 con 54 monedas, lo mismo que tu ejemplo a mano. Para estar seguro de que no fue casualidad, sigue el bucle con la tabla por vuelta:

| Vuelta | ¿Sigue? | dia | guardaHoy | ahorro |
|---|---|---|---|---|
| antes | — | 1 | 2 | 2 |
| 1 | sí | 2 | 3 | 5 |
| 2 | sí | 3 | 4 | 9 |
| 3 | sí | 4 | 5 | 14 |
| … | … | … | … | … |
| 8 | sí | 9 | 10 | 54 |
| — | no: sale | 9 | 10 | 54 |

Busca algo que sea cierto al final de todas las vueltas: «lo que hay en la alcancía es todo lo que Lucía guardó desde el día 1 hasta el día actual». Algo que se cumple al terminar cada vuelta se llama [[def:invariante|invariante]]. Si lo encuentras, sabes que el bucle es correcto sin seguirlo vuelta por vuelta: cuando sale, el invariante sigue siendo cierto, y además lo juntado ya alcanza.

Para probar los otros ejemplos sin tocar el programa, el precio se lee al empezar:

```programa id=alcancia-leida titulo="La alcancía para cualquier precio" ejecutar
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro < precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```entrada
1000
```

```salida
Día 44 con 1034 monedas
```

| Precio | A mano | El programa |
|---|---|---|
| 50 | día 9, 54 | Día 9 con 54 monedas |
| 54 (borde) | día 9, 54 | Día 9 con 54 monedas |
| 2 (borde) | día 1, 2 | Día 1 con 2 monedas |
| 1000 | día 44, 1034 | Día 44 con 1034 monedas |

Con precio 2 la condición es falsa desde el principio y el bucle da cero vueltas. No es un error: Lucía no necesita esperar.

Si te olvidas de sumar a la alcancía, lo juntado nunca cambia, la condición es verdadera para siempre y el bucle no termina. Eso es un [[def:bucle-infinito|bucle infinito]]. Así lo detiene el motor cuando se ejecuta con un límite de 10 000 sentencias:

```programa id=alcancia-infinita titulo="La alcancía que nunca se llena" ejecutar sentencias=10000 termina=limit_reached
Algoritmo Infinito
  Definir ahorro Como Entero <- 2;
  Definir guardaHoy Como Entero <- 2;
  Mientras ahorro < 50 Hacer
    guardaHoy <- guardaHoy + 1;
  FinMientras
  Escribir ahorro;
FinAlgoritmo
```

```diagnosticos
statementBudgetExhausted
```

La pregunta de control para cualquier bucle: ¿qué cambia en cada vuelta que acerca la condición a falso? Aquí, nada. Los límites de ejecución están en [la Especificación](especificacion:motor.limites).

## Mejorar {#mejorar fase=5}

En una frase: «Cuenta los días que tarda Lucía en juntar el precio si cada día guarda una moneda más».

El pedido cambia. Lucía rompe la alcancía antes de tiempo y quiere saber cuánto juntó. No recuerda la regla: te dicta las monedas una por una, y cuando termina dice -1. Ahora no sabes cuántos datos hay: paras cuando llega el -1, que no es una cantidad de monedas sino un aviso. Un valor especial que avisa «se terminaron los datos» se llama [[def:centinela|centinela]], como el guardia que avisa que alguien llega.

1. Lee el primer dato.
2. Mientras el dato no sea el aviso: súmalo y lee el siguiente.

```programa id=alcancia-dictada titulo="La alcancía dictada" ejecutar
Algoritmo AlcanciaDictada
  Definir monedas Como Entero;
  Definir ahorro Como Entero <- 0;
  Leer monedas;
  Mientras monedas <> -1 Hacer
    ahorro <- ahorro + monedas;
    Leer monedas;
  FinMientras
  Escribir "Juntó ", ahorro, " monedas";
FinAlgoritmo
```

```entrada
2
3
4
-1
```

```salida
Juntó 9 monedas
```

Hay dos `Leer`, y los dos hacen falta. El primero trae el primer dato para que la condición tenga algo que preguntar. El segundo trae el siguiente al final de cada vuelta. Si el primer dato ya es -1, el bucle da cero vueltas y el programa dice «Juntó 0 monedas», que es correcto.

## Lo que aprendiste {#aprendiste}

::: resumen
- {bucle,vuelta} Un bucle repite un grupo de instrucciones; cada repetición es una vuelta. `Mientras` pregunta antes de cada vuelta y puede dar cero vueltas.
- {rol-de-variable,contador,acumulador} El rol de una variable es para qué sirve; un contador avanza lo mismo en cada vuelta y un acumulador va juntando.
- {tabla-por-vuelta,invariante} La tabla por vuelta sigue un bucle a mano; un invariante es lo que se cumple al terminar cada vuelta.
- {bucle-infinito} Cuando nada acerca la condición a falso, el bucle es infinito.
- {centinela} Un centinela es un valor especial que avisa que se terminaron los datos.
:::

## Practica {#practica}

::: practica
- imperativo.mientras.misterio
- imperativo.mientras.misterio-tabla
- imperativo.mientras.alcancia-tomas
- imperativo.mientras.frijol
- imperativo.mientras.promedio-profesora
- imperativo.mientras.alcancia-pruebas
:::

::: docentes
- **«El bucle revisa la condición todo el tiempo».** Solo antes de cada vuelta. Pide que predigan qué pasa si lo juntado supera el precio a mitad de una vuelta.
- **Inicializar dentro del bucle.** Poner la alcancía en 0 dentro del cuerpo borra lo juntado en cada vuelta. La tabla por vuelta lo muestra de inmediato.
- **El invariante parece teoría.** Preséntalo como «la frase que la tabla repite en cada fila». Con eso basta en semilla y brote.
:::

::: siguiente
¿Y si sabes desde el principio cuántas vueltas hacen falta? ¿Cómo sabes si un número es primo?
:::

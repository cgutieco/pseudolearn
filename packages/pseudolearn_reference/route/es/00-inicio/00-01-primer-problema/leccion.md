---
id: inicio.primer-problema
numero: "0.1"
tipo: leccion
titulo: Tu primer problema
duracion: 15
problema_breve: ¿Cuántas pizzas pedir para la fiesta?
introduce: [problema, ejemplo-a-mano, programa, instruccion, ejecutar, salida, funcion-ya-hecha, ciclo-pseudolearn]
pieza: 1
---

::: frase
Programar es resolver un problema y después explicarle la solución a una computadora con tanta claridad que no pueda equivocarse.
:::

## El problema {#problema}

::: problema
Los chicos de quinto organizan la fiesta de fin de curso en el kiosco de la escuela. Van **23 personas**. Cada una come **3 porciones** de pizza, y cada pizza trae **8 porciones**.

**¿Cuántas pizzas hay que pedir?**
:::

## Inténtalo {#intentalo}

::: intento
Antes de leer más, resuélvelo con lápiz y papel. No hace falta saber programar: hace falta pensar.
:::

::: respuesta
23 personas por 3 porciones son 69 porciones. Con 8 pizzas tienes 64 porciones: faltan 5. Hay que pedir **9 pizzas**.

Si respondiste 8, cinco personas se quedan con hambre. Si respondiste 8,6, no se pueden pedir seis décimos de pizza. Las dos respuestas salen de hacer bien la cuenta y no mirar la pregunta.
:::

Lo que acabas de resolver es un [[def:problema|problema]]: una situación con datos que conoces (23 personas, 3 porciones, 8 por pizza) y una pregunta que todavía no tiene respuesta. Programar empieza siempre así: con un problema, no con una computadora.

## El ciclo PseudoLearn {#ciclo}

Para resolver cualquier problema vas a seguir siempre los mismos cinco pasos. Juntos forman [[def:ciclo-pseudolearn|el ciclo PseudoLearn]]. Al principio te guiamos en cada uno; con el tiempo los harás sin pensarlo.

```figura id=ruta-ciclo
pie: Las flechas llenas son el camino normal. Si al probar algo falla, no se empieza de cero: se vuelve a planear.
```

| Paso | La pregunta que te haces |
|---|---|
| 1. Entender | ¿Qué me dan, qué me piden y sé resolverlo a mano? |
| 2. Planear | ¿Qué pasos sigo, y en qué orden? |
| 3. Escribir | ¿Cómo se lo digo a la computadora? |
| 4. Probar | ¿La computadora responde lo mismo que yo a mano? |
| 5. Mejorar | ¿Lo puedo explicar en una frase? ¿Qué pasa si cambia el pedido? |

Ahora recorre los cinco pasos con el problema de las pizzas.

## Entender {#entender fase=1}

Entender es separar lo que sabes de lo que te piden, y comprobar que sabrías resolverlo sin computadora.

- **Lo que sabes:** 23 personas, 3 porciones por persona, 8 porciones por pizza.
- **Lo que te piden:** cuántas pizzas. Fíjate en un detalle de la pregunta: las pizzas se piden **enteras**.

La mejor forma de entender un problema es resolver casos concretos con lápiz y papel. Cada uno es un [[def:ejemplo-a-mano|ejemplo a mano]]. Sirve dos veces: ahora, para descubrir cómo se resuelve, y en el paso 4, para saber qué debe responder la computadora. Haz siempre al menos dos.

| Personas | Porciones | Entre 8 | Pizzas |
|---|---|---|---|
| 23 | 69 | 8 y sobran 5 | 9 |
| 8 | 24 | 3 exactas | 3 |

El segundo ejemplo enseña algo: cuando la división es exacta, no hay que pedir una pizza de más.

## Planear {#planear fase=2}

Mira lo que hiciste en los ejemplos y escríbelo como pasos, con tus palabras:

1. Multiplica las personas por las porciones de cada una.
2. Divide ese resultado entre las porciones de una pizza.
3. Si el resultado tiene decimales, redondea hacia arriba.

Eso ya es la solución. Lo que falta es decírsela a la computadora.

## Escribir {#escribir fase=3}

Un [[def:programa|programa]] es una lista de órdenes escritas para una computadora. Cada orden es una [[def:instruccion|instrucción]]. La computadora las lee de arriba abajo, una a la vez, y hace exactamente lo que dice cada una: ni más, ni menos, ni lo que quisiste decir.

```figura id=ruta-instrucciones-en-orden
pie: Cada paso ejecuta una sola instrucción y agrega una línea a la salida, siempre de arriba abajo.
paso: La primera instrucción muestra el texto entre comillas.
paso: La segunda calcula 2 + 3 y muestra el resultado.
paso: La tercera muestra el texto tal cual, porque está entre comillas.
```

Este es un programa completo:

```programa id=hola titulo="Mi primer programa" ejecutar
Algoritmo Hola
  Escribir "Hola";
  Escribir 2 + 3;
  Escribir "2 + 3";
FinAlgoritmo
```

```salida
Hola
5
2 + 3
```

- `Algoritmo Hola` y `FinAlgoritmo` son el sobre del programa: dicen dónde empieza, cómo se llama y dónde termina.
- `Escribir` muestra algo en la pantalla. Lo que el programa muestra es su [[def:salida|salida]].
- Lo que va entre comillas se muestra tal cual. Lo que va sin comillas se calcula primero: por eso aparece `5` y después `"2 + 3"` tal cual.
- Cada instrucción termina con punto y coma.

Pedirle a la computadora que haga lo que dice el programa es [[def:ejecutar|ejecutarlo]]. En la app es el botón ▶.

Las cuentas se escriben casi como en la escuela: `+`, `-`, `*` para multiplicar y `/` para dividir. Un solo `Escribir` puede mostrar varias cosas seguidas si las separas con comas. Con eso ya puedes escribir los pasos 1 y 2 del plan:

```programa id=fiesta-1 titulo="Fiesta, primer intento" ejecutar
Algoritmo Fiesta
  Escribir "Porciones que hacen falta: ", 23 * 3;
  Escribir "Pizzas: ", 23 * 3 / 8;
FinAlgoritmo
```

```salida
Porciones que hacen falta: 69
Pizzas: 8.625
```

La computadora hizo exactamente lo que le pediste: dividir. No sabe que las pizzas se piden enteras, porque nadie se lo dijo. Falta el paso 3 del plan.

PseudoLearn trae cálculos listos para usar. `techo` es una [[def:funcion-ya-hecha|función ya hecha]]: recibe un número entre paréntesis y devuelve el entero de arriba si el número tiene decimales, o el mismo número si no los tiene.

```programa id=fiesta-2 titulo="Fiesta, solución" ejecutar
Algoritmo Fiesta
  Escribir "Porciones que hacen falta: ", 23 * 3;
  Escribir "Pizzas que hay que pedir: ", techo(23 * 3 / 8);
FinAlgoritmo
```

```salida
Porciones que hacen falta: 69
Pizzas que hay que pedir: 9
```

La primera línea del cuerpo hace el paso 1 del plan; la segunda hace los pasos 2 y 3 juntos. Si quieres saber exactamente cómo se escribe cada cosa que usaste, está en la Especificación. No hace falta leerla ahora: es el lugar para consultar una duda.

::: especificacion
- programas.estructura
- biblioteca.consola
- expresiones.aritmeticos
- biblioteca.matematicas
:::

## Probar {#probar fase=4}

Que el programa muestre un número no quiere decir que el número sea correcto. Probar es comparar lo que responde la computadora con tus ejemplos a mano. Para el segundo ejemplo, cambia el 23 por 8 y vuelve a ejecutar:

```programa id=fiesta-8 titulo="Fiesta con 8 personas" ejecutar
Algoritmo Fiesta
  Escribir "Pizzas que hay que pedir: ", techo(8 * 3 / 8);
FinAlgoritmo
```

```salida
Pizzas que hay que pedir: 3
```

| Personas | A mano | El programa | ¿Coinciden? |
|---|---|---|---|
| 23 | 9 | 9 | sí |
| 8 | 3 | 3 | sí |

El ejemplo de 8 personas era el importante: es el caso en que una solución apurada pide una pizza de más. Los ejercicios de esta lección te enseñan a buscar esos casos a propósito.

## Mejorar {#mejorar fase=5}

Explícalo en una frase. Si no puedes, todavía no lo entiendes del todo: «El programa calcula cuántas pizzas enteras alcanzan para que todos coman sus porciones».

¿Y si cambia el pedido? Mañana confirman **30 personas** que comen **2 porciones** cada una. Para adaptarlo tienes que buscar el 23 y el 3 dentro de las instrucciones y cambiarlos en cada línea donde aparecen. En un programa de cien líneas, olvidar una sería sencillo, y el programa daría un resultado equivocado sin avisar.

## Lo que aprendiste {#aprendiste}

::: resumen
- {problema} Un problema tiene datos conocidos y una pregunta; antes de programar se lee la pregunta con cuidado.
- {ejemplo-a-mano} Un ejemplo a mano es un caso resuelto con lápiz y papel; sirve para descubrir la solución y para comprobarla.
- {programa,instruccion,ejecutar} Un programa es una lista de instrucciones que la computadora ejecuta de arriba abajo, exactamente como están escritas.
- {salida} La salida es lo que el programa muestra; lo que va entre comillas se muestra tal cual y lo demás se calcula.
- {funcion-ya-hecha} Una función ya hecha, como `techo`, recibe un valor y devuelve otro.
- {ciclo-pseudolearn} El ciclo PseudoLearn tiene cinco pasos: entender, planear, escribir, probar y mejorar.
:::

## Practica {#practica}

Ningún ejercicio te dice qué escribir. Te da un problema, y el ciclo es tuyo.

::: practica
- inicio.primer-problema.que-aparece
- inicio.primer-problema.mesas
- inicio.primer-problema.bus-excursion
- inicio.primer-problema.ana-y-beto
- inicio.primer-problema.ascensor
- inicio.primer-problema.pintar-aula
:::

::: docentes
- **«La computadora entiende lo que quise decir».** El primer intento de la fiesta muestra 8.625. Pide al grupo que prediga la salida antes de ejecutarlo: casi nadie espera decimales.
- **Comillas olvidadas.** Muchos escriben `Escribir Hola;` sin comillas. El mensaje del motor habla de cosas que todavía no se vieron: di solo «faltan las comillas» y sigue.
- **Saltarse el paso 1.** Exige los dos ejemplos a mano antes de abrir el editor. El de 8 personas es el que desarma la solución de Beto en los ejercicios.
:::

::: por-dentro
Antes de ejecutar, el motor lee el texto, comprueba que esté bien escrito y lo convierte en órdenes más pequeñas que la máquina sabe hacer. Ese viaje está contado, con figuras, en la Especificación.

::: especificacion
- vision.viaje
:::
:::

::: siguiente
¿Cómo escribir la fiesta para que cambiar la cantidad de invitados sea cambiar un solo número?
:::

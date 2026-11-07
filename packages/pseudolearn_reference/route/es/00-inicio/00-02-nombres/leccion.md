---
id: inicio.nombres
numero: "0.2"
tipo: leccion
titulo: Darle nombre a los datos
duracion: 20
problema_breve: Cambiar los invitados en un solo lugar
necesita: [inicio.primer-problema]
introduce: [variable, valor, memoria, tipo-de-dato, declarar, asignar, division-entera]
usa: [programa, instruccion, ejemplo-a-mano, funcion-ya-hecha]
pieza: 2
---

::: frase
Un programa recuerda datos guardándolos en cajas con nombre, y cada caja tiene un solo valor a la vez.
:::

## El problema {#problema}

::: problema
El kiosco anota cuántos invitados confirman para la fiesta: el lunes **23**, el martes **30** y el miércoles **27**. Cada uno come **3 porciones** y cada pizza trae **8 porciones**. El encargado quiere un programa en el que, para cada día, cambiar la cantidad de invitados sea cambiar **un solo número**.

**¿Cómo tiene que estar escrito el programa?**
:::

## Inténtalo {#intentalo}

::: intento
Vuelve al programa de la fiesta de [la lección anterior](ruta:inicio.primer-problema). Cuenta cuántas veces aparece el 23. ¿Qué pasa si cambias uno y te olvidas del otro?
:::

::: respuesta
El 23 aparece dos veces: una para las porciones y otra para las pizzas. Si cambias solo uno, el programa dice una cosa en la primera línea y otra en la segunda, y no avisa. Hace falta escribir el dato una sola vez y darle un nombre.
:::

## Entender {#entender fase=1}

Hay datos que cambian cada día (los invitados) y datos fijos (3 porciones por persona, 8 por pizza). La pregunta no es una cuenta nueva: es dónde se escribe cada dato.

Primero, los ejemplos a mano de los tres días:

| Día | Invitados | Porciones | Entre 8 | Pizzas |
|---|---|---|---|---|
| Lunes | 23 | 69 | 8,625 | 9 |
| Martes | 30 | 90 | 11,25 | 12 |
| Miércoles | 27 | 81 | 10,125 | 11 |

## Planear {#planear fase=2}

1. Escribe cada dato una sola vez y ponle un nombre.
2. Calcula las porciones a partir de los nombres, no de los números.
3. Calcula las pizzas a partir de las porciones.

## La herramienta nueva {#herramienta}

Mientras se ejecuta, un programa guarda datos en la [[def:memoria|memoria]] de la computadora. Imagínala como un estante de cajas. Cada caja tiene un nombre y guarda un [[def:valor|valor]]: un número, un texto. Una caja con nombre es una [[def:variable|variable]].

Antes de usar una caja hay que [[def:declarar|declararla]]: decir su nombre y qué clase de valor guarda. Esa clase es su [[def:tipo-de-dato|tipo de dato]]. Por ahora alcanzan tres: `Entero` para números sin decimales, `Real` para números con decimales y `Cadena` para textos.

```figura-especificacion seccion=declaraciones.definir figura=cajas-variables
```

Guardar un valor en una caja es [[def:asignar|asignarlo]], y se escribe con una flecha `<-`. El valor nuevo reemplaza al anterior, que se pierde: cada caja tiene un solo valor a la vez.

```programa id=cumple titulo="Un año más" ejecutar
Algoritmo Cumple
  Definir edad Como Entero <- 10;
  Escribir edad;
  edad <- edad + 1;
  Escribir edad;
FinAlgoritmo
```

```salida
10
11
```

`edad <- edad + 1` no es una ecuación imposible. Se lee de derecha a izquierda: «calcula con el valor viejo de `edad` y guarda el resultado en `edad`». El valor viejo, 10, se usa una vez y desaparece.

```figura-especificacion seccion=declaraciones.asignacion figura=intercambio
```

Una segunda herramienta sirve para repartir. `div` dice cuántas veces cabe un entero en otro, sin decimales; `mod` dice cuánto sobra después de repartir. Juntos forman la [[def:division-entera|división entera y su resto]].

```programa id=caramelos titulo="Repartir caramelos" ejecutar
Algoritmo Caramelos
  Escribir 47 div 6, " ", 47 mod 6;
FinAlgoritmo
```

```salida
7 5
```

```figura-especificacion seccion=expresiones.division figura=reparto
```

::: especificacion
- declaraciones.definir
- tipos.primitivos
- declaraciones.asignacion
- expresiones.division
:::

## Escribir {#escribir fase=3}

```programa id=fiesta-nombres titulo="La fiesta con nombres" ejecutar
Algoritmo Fiesta
  Definir invitados Como Entero <- 23;
  Definir porcionesPorPersona Como Entero <- 3;
  Definir porcionesPorPizza Como Entero <- 8;
  Definir porciones Como Entero <- invitados * porcionesPorPersona;
  Escribir "Pizzas que hay que pedir: ", techo(porciones / porcionesPorPizza);
FinAlgoritmo
```

```salida
Pizzas que hay que pedir: 9
```

Los nombres dicen qué guarda cada caja. `p` también funcionaría, pero dentro de una semana nadie recordaría si `p` eran porciones, personas o pizzas. `porcionesPorPizza` no deja dudas.

## Probar {#probar fase=4}

Cambia solo la primera línea: 30 invitados dan 12 pizzas y 27 invitados dan 11, igual que los ejemplos a mano. Ya no hay que buscar números dentro de las cuentas.

Cuidado con el orden. Una caja guarda un valor, no una fórmula: no se recalcula sola.

```figura id=ruta-caja-no-se-recalcula
pie: Asignar copia un valor en el momento en que se ejecuta. Si un dato cambia después, hay que volver a calcular.
paso: Se calculan las porciones con 23 invitados: la caja guarda 69.
paso: Cambia la caja de invitados a 30. Las porciones siguen en 69: nadie las volvió a calcular.
paso: Solo al ejecutar otra vez la cuenta, las porciones pasan a 90.
```

## Mejorar {#mejorar fase=5}

En una frase: «El programa guarda cada dato una vez, con un nombre, y calcula las pizzas a partir de esos nombres».

Queda un problema. Cada día alguien tiene que abrir el programa y cambiar la primera línea, y el encargado del kiosco no programa.

## Lo que aprendiste {#aprendiste}

::: resumen
- {variable,valor,memoria} La memoria son cajas con nombre; cada variable guarda un valor a la vez.
- {declarar,tipo-de-dato} Declarar crea la caja y fija su tipo de dato: `Entero`, `Real` o `Cadena`.
- {asignar} Asignar reemplaza el valor anterior, que se pierde; una caja no se recalcula sola.
- {division-entera} `div` dice cuántas veces cabe un entero en otro y `mod` cuánto sobra.
:::

## Practica {#practica}

::: practica
- inicio.nombres.cajas
- inicio.nombres.que-tipo
- inicio.nombres.figuritas
- inicio.nombres.reparto-caramelos
- inicio.nombres.cronometro
- inicio.nombres.buen-nombre
:::

::: docentes
- **«La variable se actualiza sola, como en una planilla».** Usa la figura de las cajas que no se recalculan y pide predecir qué guarda `porciones` antes del tercer paso.
- **«Sumarle 1 a una caja usando la misma caja es imposible».** Lee `x <- x + 1` en voz alta como «nuevo `x` es el viejo `x` más 1».
- **«Todo lo que tiene cifras es un número».** El ejercicio de los tipos lo desarma: `"23"` va entre comillas, así que es texto.
:::

::: siguiente
Para cada fiesta todavía hay que abrir el programa y cambiar un número. ¿Y si quien lo usa no sabe programar?
:::

---
id: imperativo.arreglos
numero: "1.5"
tipo: leccion
titulo: Muchos datos con un solo nombre
duracion: 30
problema_breve: Los días más calurosos de la semana
necesita: [imperativo.contado]
introduce: [arreglo, indice, recorredor, fuera-de-rango]
usa: [bucle-contado, acumulador, contador, rol-de-variable, error-de-ejecucion, caso-borde]
---

::: frase
Un arreglo guarda muchos datos del mismo tipo bajo un solo nombre, y cada uno se encuentra por su posición.
:::

## El problema {#problema}

::: problema
El kiosco anota la temperatura máxima de cada día de la semana, de lunes a domingo. Quiere saber **qué días fueron más calurosos que el promedio de la semana**.

**¿Cómo lo calcula un programa?**
:::

## Inténtalo {#intentalo}

::: intento
Resuélvelo a mano con estas máximas: 20, 23, 19, 25, 22, 18 y 26.
:::

::: respuesta
La suma es 153 y el promedio es 21,86. Superan el promedio el martes (23), el jueves (25), el viernes (22) y el domingo (26).

Fíjate en el orden: primero sumaste todo para conocer el promedio, y después volviste a mirar cada día. Tuviste que recordar las siete temperaturas.
:::

## Entender {#entender fase=1}

::: ficha
- entra: siete temperaturas, una por día, de lunes a domingo.
- sale: los nombres de los días más calurosos que el promedio, uno por línea.
- relacion: el promedio es la suma entre 7; se muestran los días cuya temperatura lo supera.
- ejemplo: 20, 23, 19, 25, 22, 18, 26 → martes, jueves, viernes, domingo.
- ejemplo: los siete días a 20 → ningún día supera el promedio.
:::

El segundo ejemplo es un caso borde: si todos los días son iguales, ninguno supera al promedio, y el programa tiene que decirlo.

## Planear {#planear fase=2}

1. Lee las siete temperaturas y súmalas para conocer el promedio.
2. Vuelve a recorrer las temperaturas y muestra los días que superan el promedio.

```figura id=ruta-dos-pasadas
pie: Hacen falta dos pasadas: la primera calcula el promedio; la segunda compara cada día con él.
paso: Primera pasada: se recorren las siete temperaturas y se juntan para el promedio.
paso: Segunda pasada: se vuelve a recorrer y se marcan los días por encima del promedio.
```

Con lo que sabes hasta ahora, guardar siete temperaturas exige siete cajas con siete nombres, y la segunda pasada sería imposible de escribir con un bucle.

## La herramienta nueva {#herramienta}

Un [[def:arreglo|arreglo]] es una fila de casillas del mismo tipo bajo un solo nombre. Cada casilla se encuentra por su posición, que es su [[def:indice|índice]]. Los índices empiezan en 0: un arreglo de 7 casillas va de 0 a 6.

```figura-especificacion seccion=tipos.arreglos figura=arreglo-casillas
```

```programa id=tres-notas titulo="Tres notas" ejecutar
Algoritmo TresNotas
  Dimension notas[3] Como Entero;
  notas[0] <- 7;
  notas[1] <- 9;
  notas[2] <- 4;
  Escribir notas[1];
FinAlgoritmo
```

```salida
9
```

Para recorrer un arreglo, un bucle contado lleva el índice de la primera casilla a la última. Ese índice tiene un rol propio:

::: roles
- recorredor | ruta-rol-recorredor | Un índice que avanza casilla por casilla, de la primera a la última.
:::

Un [[def:recorredor|recorredor]] es el índice que visita cada casilla. Cuando solo hace falta el valor de cada casilla, y no su posición, `Para Cada` recorre el arreglo sin índice:

```figura-especificacion seccion=control.para-cada figura=para-cada-recorrido
```

Usar un índice que no existe, como la casilla 7 de un arreglo de 7, es un error [[def:fuera-de-rango|fuera de rango]]: el programa se detiene. Los detalles están en [la Especificación](especificacion:tipos.arreglos).

::: especificacion
- tipos.arreglos
- control.para-cada
:::

## Escribir {#escribir fase=3}

```programa id=dias-calurosos titulo="Los días calurosos" ejecutar
Algoritmo DiasCalurosos
  Dimension dias[7] Como Cadena;
  Dimension temperaturas[7] Como Entero;
  dias[0] <- "lunes";
  dias[1] <- "martes";
  dias[2] <- "miércoles";
  dias[3] <- "jueves";
  dias[4] <- "viernes";
  dias[5] <- "sábado";
  dias[6] <- "domingo";
  Definir suma Como Entero <- 0;
  Para i <- 0 Hasta 6 Hacer
    Leer temperaturas[i];
    suma <- suma + temperaturas[i];
  FinPara
  Definir promedio Como Real <- suma / 7;
  Definir calurosos Como Entero <- 0;
  Para i <- 0 Hasta 6 Hacer
    Si temperaturas[i] > promedio Entonces
      Escribir dias[i];
      calurosos <- calurosos + 1;
    FinSi
  FinPara
  Si calurosos = 0 Entonces
    Escribir "Ningún día";
  FinSi
FinAlgoritmo
```

```entrada
20
23
19
25
22
18
26
```

```salida
martes
jueves
viernes
domingo
```

Hay dos arreglos con los mismos índices: la casilla 3 de `dias` es el nombre del día cuya temperatura está en la casilla 3 de `temperaturas`.

## Probar {#probar fase=4}

| Temperaturas | A mano | El programa |
|---|---|---|
| 20, 23, 19, 25, 22, 18, 26 | martes, jueves, viernes, domingo | martes ⏎ jueves ⏎ viernes ⏎ domingo |
| siete veces 20 | ningún día | Ningún día |

## Mejorar {#mejorar fase=5}

En una frase: «El programa guarda las temperaturas de la semana, calcula el promedio y muestra los días que lo superan».

Compáralo con una versión de siete cajas sueltas: si la semana tuviera 30 días, habría que agregar 23 cajas, 23 lecturas y 23 comparaciones. Con arreglos, alcanza con cambiar el 7 y el 6.

## Lo que aprendiste {#aprendiste}

::: resumen
- {arreglo,indice} Un arreglo guarda datos del mismo tipo; el índice es la posición y empieza en 0.
- {recorredor} Un recorredor es el índice que avanza casilla por casilla.
- {fuera-de-rango} Usar un índice que no existe es un error fuera de rango y detiene el programa.
:::

## Practica {#practica}

::: practica
- imperativo.arreglos.posiciones
- imperativo.arreglos.semana-error
- imperativo.arreglos.al-reves
- imperativo.arreglos.aprobados
- imperativo.arreglos.calurosos-ordenar
- imperativo.arreglos.rotar
:::

::: docentes
- **Índices desde 1.** La casilla 1 es la segunda. Pide que señalen la primera casilla en la figura antes de escribir.
- **Confundir la posición con el valor.** `notas[1]` es lo que está en la casilla 1, no el número 1.
- **Una sola pasada para el promedio.** No se puede comparar con el promedio antes de conocerlo: la figura de las dos pasadas lo muestra.
:::

::: siguiente
Muchos problemas con colecciones se parecen: contar, buscar, juntar. ¿Hay formas que se repiten?
:::

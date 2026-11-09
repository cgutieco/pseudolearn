---
id: imperativo.arreglos
numero: "1.5"
tipo: leccion
titulo: Many values under one name
duracion: 30
problema_breve: The hottest days of the week
necesita: [imperativo.contado]
introduce: [arreglo, indice, recorredor, fuera-de-rango]
usa: [bucle-contado, acumulador, contador, rol-de-variable, error-de-ejecucion, caso-borde]
---

::: frase
An array keeps many values of the same type under a single name, and each one is found by its position.
:::

## The problem {#problema}

::: problema
The kiosk writes down the highest temperature of each day of the week, from Monday to Sunday. It wants to know **which days were hotter than the week's average**.

**How does a program work it out?**
:::

## Try it {#intentalo}

::: intento
Solve it by hand with these highs: 20, 23, 19, 25, 22, 18 and 26.
:::

::: respuesta
The sum is 153 and the average is 21.86. Tuesday (23), Thursday (25), Friday (22) and Sunday (26) are above the average.

Look at the order: first you added everything to know the average, and then you looked at each day again. You had to remember the seven temperatures.
:::

## Understand {#entender fase=1}

::: ficha
- entra: seven temperatures, one per day, from Monday to Sunday.
- sale: the names of the days hotter than the average, one per line.
- relacion: the average is the sum divided by 7; the days whose temperature is above it are shown.
- ejemplo: 20, 23, 19, 25, 22, 18, 26 → Tuesday, Thursday, Friday, Sunday.
- ejemplo: all seven days at 20 → no day is above the average.
:::

The second example is an edge case: if all days are the same, none is above the average, and the program has to say so.

## Plan {#planear fase=2}

1. Read the seven temperatures and add them up to know the average.
2. Walk through the temperatures again and show the days above the average.

```figura id=ruta-dos-pasadas
pie: Two passes are needed: the first computes the average; the second compares each day with it.
paso: First pass: the seven temperatures are walked through and gathered for the average.
paso: Second pass: they are walked through again and the days above the average are marked.
```

With what you know so far, keeping seven temperatures takes seven boxes with seven names, and the second pass would be impossible to write with a loop.

## The new tool {#herramienta}

An [[def:arreglo|array]] is a row of cells of the same type under a single name. Each cell is found by its position, which is its [[def:indice|index]]. Indices start at 0: an array of 7 cells goes from 0 to 6.

```figura-especificacion seccion=tipos.arreglos figura=arreglo-casillas
```

```programa id=tres-notas titulo="Three marks" ejecutar
```

```salida
9
```

To walk through an array, a counted loop takes the index from the first cell to the last. That index has a role of its own:

::: roles
- walker | ruta-rol-recorredor | An index that moves cell by cell, from the first to the last.
:::

A [[def:recorredor|walker]] is the index that visits each cell. When you only need the value of each cell, and not its position, `For Each` walks through the array without an index:

```figura-especificacion seccion=control.para-cada figura=para-cada-recorrido
```

Using an index that does not exist, such as cell 7 of an array of 7, is an [[def:fuera-de-rango|out of range]] error: the program stops. The details are in [the Specification](especificacion:tipos.arreglos).

::: especificacion
- tipos.arreglos
- control.para-cada
:::

## Write {#escribir fase=3}

```programa id=dias-calurosos titulo="The hot days" ejecutar
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

There are two arrays with the same indices: cell 3 of `dias` is the name of the day whose temperature is in cell 3 of `temperaturas`.

## Test {#probar fase=4}

| Temperatures | By hand | The program |
|---|---|---|
| 20, 23, 19, 25, 22, 18, 26 | Tuesday, Thursday, Friday, Sunday | martes ⏎ jueves ⏎ viernes ⏎ domingo |
| 20 seven times | no day | Ningún día |

## Improve {#mejorar fase=5}

In one sentence: «The program keeps the week's temperatures, computes the average and shows the days above it».

Compare it with a version with seven loose boxes: if the week had 30 days, you would have to add 23 boxes, 23 reads and 23 comparisons. With arrays, changing the 7 and the 6 is enough.

## What you learned {#aprendiste}

::: resumen
- {arreglo,indice} An array keeps values of the same type; the index is the position and it starts at 0.
- {recorredor} A walker is the index that moves cell by cell.
- {fuera-de-rango} Using an index that does not exist is an out of range error and stops the program.
:::

## Practise {#practica}

::: practica
- imperativo.arreglos.posiciones
- imperativo.arreglos.semana-error
- imperativo.arreglos.al-reves
- imperativo.arreglos.aprobados
- imperativo.arreglos.calurosos-ordenar
- imperativo.arreglos.rotar
:::

::: profundizar titulo="Common pitfalls"
- **Indices from 1.** Cell 1 is the second one. Point at the first cell in the figure before writing.
- **Confusing the position with the value.** `notas[1]` is what is in cell 1, not the number 1.
- **A single pass for the average.** You cannot compare with the average before you know it: the figure of the two passes shows it.
:::

::: siguiente
Many problems with collections look alike: counting, searching, gathering. Are there shapes that repeat?
:::

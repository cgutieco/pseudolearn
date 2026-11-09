---
id: imperativo.estrategias
numero: "1.8"
tipo: leccion
titulo: More than one way
duracion: 35
problema_breve: Guessing a number in few questions
necesita: [imperativo.cuadriculas]
introduce: [estrategia, fuerza-bruta, busqueda-binaria, costo, ordenamiento-por-seleccion]
usa: [arreglo, indice, bucle, contador, invariante, caso-borde, salida-anticipada, esquema]
---

::: frase
Two correct programs can take very different times; counting their steps tells you which one suits.
:::

## The problem {#problema}

::: problema
They play a guessing game: someone thinks of a number from **1 to 100**; you say a number and they answer «higher», «lower» or «got it».

**Which way of playing guesses in the fewest attempts, even in the worst case?**
:::

## Try it {#intentalo}

::: intento
Play in pairs with paper. Try different ways of choosing the next number and write down how many attempts were needed.
:::

::: respuesta
It pays to start with 50 and always keep the half that can hold the number: you never need more than **7** attempts. Trying one by one, from 1 onwards, may need **100**.
:::

## Understand {#entender fase=1}

::: ficha
- entra: the secret number, so that the program simulates the game.
- sale: how many attempts were needed.
- relacion: each answer leaves part of the possible numbers; you count until you get it.
- ejemplo: secret 37 → you say 50, 25 and 37: 3 attempts.
- ejemplo: secret 100 → 7 attempts.
- ejemplo: secret 1 → 6 attempts.
:::

1 and 100 are the edges: they are the furthest from the first question.

## Plan {#planear fase=2}

A [[def:estrategia|strategy]] is a way of solving a problem. There is more than one for this game:

- Trying from 1 onwards, one by one, is [[def:fuerza-bruta|brute force]]: it tries every possibility until it hits the answer.
- Always saying the middle number of what is left and discarding the half that cannot hold it is a [[def:busqueda-binaria|binary search]].

```figura id=ruta-busqueda-binaria
pie: At each step you look at the middle one and cross out the half that cannot contain the searched value.
paso: You look at the middle one. The searched value is greater: the left half is crossed out.
paso: You look at the middle of what is left. The searched value is smaller: the right part is crossed out.
paso: Few are left. You look at the middle one again.
paso: It finds it. With 15 numbers, you never need more than 4 steps.
```

The plan of the binary search:

1. What is possible goes from `bajo` (low) to `alto` (high): at first, from 1 to 100.
2. Say the middle one.
3. If the secret is greater, what is possible starts after the middle; if smaller, it ends before.
4. Repeat until you get it.

## The new tool {#herramienta}

There is no new construction. What is new is measuring. The [[def:costo|cost]] of an algorithm is estimated by counting its steps in the worst case: one more counter inside the loop is enough.

```figura id=ruta-pasos-crecen
pie: With ten times more data, brute force takes ten times longer; binary search, just a few more steps.
```

Binary search needs the data to be sorted. If it is not, you have to sort it first. [[def:ordenamiento-por-seleccion|Selection sort]] brings to the front, again and again, the smallest of those left:

```figura id=ruta-seleccion
pie: Each pass of the outer loop picks the smallest of the unsorted part and brings it to the front.
paso: The five numbers, unsorted.
paso: The smallest of all, 1, moves to the front.
paso: The smallest of those left, 3, is already in second place.
paso: Then 5 to third place.
paso: And 8 to fourth. The last one is already in its place.
```

## Write {#escribir fase=3}

```programa id=adivinar titulo="Guessing by halves" ejecutar
```

```entrada
37
```

```salida
Intentos: 3
```

The same idea works to search in a sorted array. This program searches for a number among fifteen and counts the steps:

```programa id=buscar-ordenado titulo="Binary search in an array" ejecutar
```

```entrada
26
```

```salida
Posición: 8 en 4 pasos
```

And this is how five numbers are sorted with selection:

```programa id=seleccion titulo="Sorting by selection" ejecutar
```

```entrada
5
3
8
1
9
```

```salida
1
3
5
8
9
```

## Test {#probar fase=4}

| Secret | By hand | The program |
|---|---|---|
| 1 | 50, 25, 12, 6, 3, 1 | Intentos: 6 |
| 100 | 50, 75, 88, 94, 97, 99, 100 | Intentos: 7 |
| 50 | 50 | Intentos: 1 |

The invariant of binary search is the sentence that makes it right: «if the number is there, it is between `bajo` and `alto`». Each pass shrinks that interval without leaving the secret out.

## Improve {#mejorar fase=5}

In one sentence: «Guessing by halves never needs more than 7 attempts for 100 numbers, because each answer discards half».

Go back to the prime of [lesson 1.4](ruta:imperativo.contado). If a number has a divisor greater than its square root, it also has a smaller one. Trying while `d * d <= n` is enough:

```programa id=primo-rapido titulo="The prime, with fewer divisions" ejecutar
```

```entrada
97
```

```salida
true con 8 divisiones
```

With 97, from 95 divisions to 8.

## What you learned {#aprendiste}

::: resumen
- {estrategia,fuerza-bruta} A strategy is a way of solving a problem; brute force tries every possibility.
- {busqueda-binaria} Binary search discards half at each step, but it needs sorted data.
- {costo} The cost of an algorithm is estimated by counting its steps in the worst case.
- {ordenamiento-por-seleccion} Selection sort brings to the front, again and again, the smallest of those left.
:::

## Practise {#practica}

::: practica
- imperativo.estrategias.intentos-100
- imperativo.estrategias.guia-telefonica
- imperativo.estrategias.binaria
- imperativo.estrategias.binaria-romper
- imperativo.estrategias.ordenar-seis
- imperativo.estrategias.seleccion-tabla
:::

::: profundizar titulo="Common pitfalls"
- **«The fastest is the one with fewer lines».** Binary search is longer than one by one and much faster. Count the steps with 1000 values.
- **Binary search over unsorted data.** On an unsorted array, the search may not find a number that is there.
- **The middle that does not move.** When discarding leaves the middle inside the interval, the loop may never end: the breaking exercise shows it.
:::

::: siguiente
The time has come to bring together everything you learned in the kiosk till.
:::

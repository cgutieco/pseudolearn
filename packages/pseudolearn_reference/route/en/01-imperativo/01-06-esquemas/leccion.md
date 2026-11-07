---
id: imperativo.esquemas
numero: "1.6"
tipo: leccion
titulo: Search, count and filter
duracion: 35
problema_breve: The heat waves
necesita: [imperativo.arreglos]
introduce: [esquema, seguidor]
usa: [arreglo, recorredor, contador, acumulador, mejor-hasta-ahora, bandera, salida-anticipada, caso-borde]
---

::: frase
Almost every problem with a collection is a combination of a few patterns you already know.
:::

## The problem {#problema}

::: problema
The kiosk recorded the highest temperature of **14 days in a row**. A **heat wave** is **3 or more days in a row above 30 degrees**.

**How many waves were there, and how many days did the longest one last?**
:::

## Try it {#intentalo}

::: intento
Solve it by hand with these highs: 28, 31, 32, 33, 29, 31, 30, 31, 32, 31, 35, 27, 31, 32.
:::

::: respuesta
The streaks of days above 30 last 3, 1, 4 and 2 days. Only two reach 3: there were **2 waves**, and the longest lasted **4 days**.

30 does not count: it has to be **more** than 30. That is why the seventh day breaks the streak.
:::

## Understand {#entender fase=1}

::: ficha
- entra: 14 temperatures, one per day.
- sale: how many waves there were and how many days the longest lasted.
- relacion: a wave is a streak of 3 or more days in a row above 30.
- ejemplo: the one in the task → 2 waves, the longest of 4.
- ejemplo: the last three days above 30 → the wave ends with the data and it also counts.
- ejemplo: a streak of exactly 3 days → it is a wave.
:::

The last two examples are edge cases. The first one is the most often forgotten: a wave that has not broken yet when the data runs out.

## Plan {#planear fase=2}

Many problems with collections are solved with the same few shapes. Each one is a [[def:esquema|pattern]]:

```figura id=ruta-esquemas
pie: Six patterns over the same collection. Almost every problem combines two or three.
```

| Pattern | What it does | You saw it in |
|---|---|---|
| Walk | visits each value | the hot days |
| Count | counts the ones that meet something | the passes |
| Gather | joins the values into a total | the average |
| Search | finds the first one that meets something and stops | the prime |
| Filter | keeps the ones that meet something | the hot days |
| Transform | changes each value for another | — |

This problem combines three: counting the days of the streak, counting the waves and keeping the longest. For the streak you need a box that remembers what happened on the previous days:

::: roles
- follower | ruta-rol-seguidor | Remembers the previous value, or the streak being built, to compare it with the current one.
:::

A [[def:seguidor|follower]] keeps count of the streak: it goes up with each hot day and goes back to 0 when the streak breaks.

```figura id=ruta-racha
pie: The streak goes up with each day above 30 and goes back to 0 when it breaks. When it breaks, you decide whether it was a wave.
paso: Days 1 to 4: the streak reaches 3 and breaks with the 29. It is the first wave.
paso: Days 5 and 6: a 1-day streak; not a wave.
paso: Day 7: the 30 breaks the streak, because it is not more than 30.
paso: Days 8 to 11: a 4-day streak. It is the second wave, and the longest.
paso: Day 12: the 27 breaks it.
paso: Days 13 and 14: a streak of 2 that ends with the data. It is checked after the loop: not a wave.
```

## The new tool {#herramienta}

There is no new construction: you combine the ones you know. A follower can also remember just the previous value. For example, to count how many times a day was hotter than the one before:

```programa id=subidas titulo="How many times did it go up?" ejecutar
```

```salida
2
```

## Write {#escribir fase=3}

```programa id=olas titulo="The heat waves" ejecutar
```

```entrada
28
31
32
33
29
31
30
31
32
31
35
27
31
32
```

```salida
Olas: 2
La más larga: 4
```

Look at the `If` that comes **after** the loop: it closes the last streak, the one that had not broken yet when the data ran out.

## Test {#probar fase=4}

| Case | By hand | The program |
|---|---|---|
| The one in the task | 2 waves, the longest of 4 | Olas: 2 ⏎ La más larga: 4 |
| The last three days above 30 | 1 wave of 3 | Olas: 1 ⏎ La más larga: 3 |
| No day above 30 | 0 waves | Olas: 0 ⏎ La más larga: 0 |
| A streak of exactly 3 | 1 wave of 3 | Olas: 1 ⏎ La más larga: 3 |

## Improve {#mejorar fase=5}

In one sentence: «The program follows the streak of hot days, counts the ones that reach 3 and remembers the longest».

What if a wave became 4 or more days? You have to change the 3 in two places. If the 3 were in a box with a name, such as `diasDeOla`, you would change it in only one.

## What you learned {#aprendiste}

::: resumen
- {esquema} Walking, counting, gathering, searching, filtering and transforming are patterns that combine to solve problems with collections.
- {seguidor} A follower remembers the previous value or a streak to compare it with the current one.
:::

## Practise {#practica}

::: practica
- imperativo.esquemas.que-esquema
- imperativo.esquemas.primer-siete
- imperativo.esquemas.olas-romper
- imperativo.esquemas.primer-desaprobado
- imperativo.esquemas.sin-lluvia
- imperativo.esquemas.buscar-pruebas
:::

::: docentes
- **Forgetting the last streak.** It is the most common error. The breaking exercise exposes it with a wave at the end.
- **Resetting the streak in the wrong place.** Setting it to 0 before checking whether it was a wave loses it.
- **Wanting a new pattern for every problem.** Ask them to name the patterns a problem combines before writing.
:::

::: siguiente
A noughts and crosses board is not a row of values: it has rows and columns. How is it kept and walked through?
:::

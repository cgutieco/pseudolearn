---
id: imperativo.mientras
numero: "1.3"
tipo: leccion
titulo: Repeat while needed
duracion: 30
problema_breve: Lucía's money box
necesita: [imperativo.caminos]
introduce: [bucle, vuelta, rol-de-variable, contador, acumulador, tabla-por-vuelta, invariante, bucle-infinito, centinela]
usa: [variable, asignar, condicion, caso-borde, ficha-del-problema, leer-dato, ejemplo-a-mano]
pieza: 4
---

::: frase
When you do not know how many times something has to be done, but you do know when to stop, you repeat while that condition is not met.
:::

## The problem {#problema}

::: problema
Lucía wants to buy a ball that costs **50 coins**. On the first day she puts **2 coins** in her money box, and every day she saves **one coin more** than the day before.

**On which day can she buy the ball, and how many coins will she have that day?**
:::

## Try it {#intentalo}

::: intento
Solve it by hand. Make a table with one row per day: how much she saves and how much she has gathered.
:::

::: respuesta
She saves 2, 3, 4, 5… and has gathered 2, 5, 9, 14, 20, 27, 35, 44 and 54. On **day 9** she reaches **54 coins** and can buy the ball.

Look at what you did: you repeated the same two sums nine times, and stopped when the total reached the price. Before starting you did not know there would be nine.
:::

## Understand {#entender fase=1}

::: recuerda termino=ficha-del-problema
:::

::: ficha
- entra: the price of the ball. On the first day 2 coins are saved and every day one more.
- sale: the day on which she can buy it and the coins gathered that day.
- relacion: what is saved each day is added until the total reaches or passes the price.
- ejemplo: price 50 → day 9, with 54 coins.
- ejemplo: price 54 → also day 9, with 54: it is exactly the price, and it is enough.
- ejemplo: price 2 → day 1, with 2: it is enough on the first day, without waiting.
:::

The last two examples are edge cases: they sit right on the limit where a hasty program gets it wrong.

## Plan {#planear fase=2}

With what you know so far, you would have to write the sums once per day: nine times for 50 coins, forty-four for 1000. And if Lucía types the price when using the program, you would not even know how many. Look at your table by hand. In each row you did the same:

1. A day goes by.
2. That day one coin more than the day before is saved.
3. What is saved that day is added to the total.

And before each row you asked yourself the same thing: is it still not enough? If the answer is yes, you make another row. If it is no, you are done.

The three boxes you need do not change in the same way, and recognising what each one is for is half the solution. What a box is for is its [[def:rol-de-variable|role]]:

::: roles
- counter | ruta-rol-contador | Always moves the same amount every pass: the day goes up one by one, and so does what is saved each day.
- accumulator | ruta-rol-acumulador | Keeps gathering: every pass something new is added to what it already had. It is the money box.
:::

A [[def:contador|counter]] moves the same amount each time; an [[def:acumulador|accumulator]] keeps gathering. You will find them in almost every problem that repeats something.

## The new tool {#herramienta}

A [[def:bucle|loop]] is a group of instructions that repeats. Each repetition is called a [[def:vuelta|pass]]. `While` repeats its group of instructions while a condition is true. The condition is asked before each pass; when it is false, the program carries on with what comes after `EndWhile`.

```figura-especificacion seccion=control.mientras figura=mientras-ciclo
```

```programa id=cuenta-regresiva titulo="Countdown" ejecutar
```

```salida
3
2
1
¡Ya!
```

In a loop, the same instruction runs many times, each time with different values in the boxes. To follow it by hand you use a [[def:tabla-por-vuelta|pass table]]: one column per box and one row per pass, with the values at the end of that pass.

```figura id=ruta-tabla-por-vuelta
pie: Each row is a pass. The table lets you see what changes and what stays.
paso: Before the loop: on day 1, Lucía saved 2 and has 2.
paso: First pass: it moves to day 2, she saves 3 and gathers 5.
paso: Second pass: day 3, she saves 4 and gathers 9.
paso: When the total reaches the price, the condition is false and the loop ends.
```

::: especificacion
- control.mientras
:::

## Write {#escribir fase=3}

Day 1 is already done before repeating starts: Lucía saved 2 coins. The loop takes care of the following days, and the condition is the question of the plan, «is it still not enough?»:

```programa id=alcancia titulo="Lucía's money box" ejecutar
```

```salida
Lucía compra la pelota el día 9 con 54 monedas
```

The three lines inside the loop are the three steps of the plan, in the same order. The condition is the question. If the plan is clear, the program almost writes itself.

## Test {#probar fase=4}

The program says day 9 with 54 coins, the same as your worked example. To be sure it was not by chance, follow the loop with the pass table:

| Pass | Go on? | dia | guardaHoy | ahorro |
|---|---|---|---|---|
| before | — | 1 | 2 | 2 |
| 1 | yes | 2 | 3 | 5 |
| 2 | yes | 3 | 4 | 9 |
| 3 | yes | 4 | 5 | 14 |
| … | … | … | … | … |
| 8 | yes | 9 | 10 | 54 |
| — | no: ends | 9 | 10 | 54 |

Look for something that is true at the end of every pass: «what is in the money box is everything Lucía saved from day 1 to the current day». Something that holds at the end of each pass is called an [[def:invariante|invariant]]. If you find it, you know the loop is right without following it pass by pass: when it ends, the invariant is still true, and the total is already enough.

To test the other examples without touching the program, the price is read at the start:

```programa id=alcancia-leida titulo="The money box for any price" ejecutar
```

```entrada
1000
```

```salida
Día 44 con 1034 monedas
```

| Price | By hand | The program |
|---|---|---|
| 50 | day 9, 54 | Día 9 con 54 monedas |
| 54 (edge) | day 9, 54 | Día 9 con 54 monedas |
| 2 (edge) | day 1, 2 | Día 1 con 2 monedas |
| 1000 | day 44, 1034 | Día 44 con 1034 monedas |

With price 2 the condition is false from the start and the loop makes zero passes. It is not an error: Lucía does not need to wait.

If you forget to add to the money box, the total never changes, the condition stays true forever and the loop never ends. That is an [[def:bucle-infinito|infinite loop]]. This is how the engine stops it when it runs with a limit of 10 000 statements:

```programa id=alcancia-infinita titulo="The money box that never fills" ejecutar sentencias=10000 termina=limit_reached
```

```diagnosticos
statementBudgetExhausted
```

The control question for any loop: what changes on each pass that brings the condition closer to false? Here, nothing. The execution limits are in [the Specification](especificacion:motor.limites).

## Improve {#mejorar fase=5}

In one sentence: «It counts the days Lucía takes to gather the price if each day she saves one coin more».

The request changes. Lucía breaks the money box early and wants to know how much she gathered. She does not remember the rule: she dictates the coins to you one by one, and when she finishes she says -1. Now you do not know how many values there are: you stop when -1 arrives, which is not an amount of coins but a signal. A special value that warns «the data is over» is called a [[def:centinela|sentinel]], like the guard who warns that someone is coming.

1. Read the first value.
2. While the value is not the signal: add it and read the next one.

```programa id=alcancia-dictada titulo="The dictated money box" ejecutar
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

There are two `Read`, and both are needed. The first brings the first value so that the condition has something to ask. The second brings the next one at the end of each pass. If the first value is already -1, the loop makes zero passes and the program says «Juntó 0 monedas», which is right.

## What you learned {#aprendiste}

::: resumen
- {bucle,vuelta} A loop repeats a group of instructions; each repetition is a pass. `While` asks before each pass and may make zero passes.
- {rol-de-variable,contador,acumulador} The role of a variable is what it is for; a counter moves the same amount every pass and an accumulator keeps gathering.
- {tabla-por-vuelta,invariante} The pass table follows a loop by hand; an invariant is what holds at the end of each pass.
- {bucle-infinito} When nothing brings the condition closer to false, the loop is infinite.
- {centinela} A sentinel is a special value that warns that the data is over.
:::

## Practise {#practica}

::: practica
- imperativo.mientras.misterio
- imperativo.mientras.misterio-tabla
- imperativo.mientras.alcancia-tomas
- imperativo.mientras.frijol
- imperativo.mientras.promedio-profesora
- imperativo.mientras.alcancia-pruebas
:::

::: profundizar titulo="Common pitfalls"
- **«The loop checks the condition all the time».** Only before each pass. Predict what happens if the total passes the price halfway through a pass.
- **Initialising inside the loop.** Setting the money box to 0 inside the body wipes the total on every pass. The pass table shows it at once.
- **The invariant looks like theory.** Think of it as «the sentence the table repeats in every row». That is enough for seed and sprout.
:::

::: siguiente
What if you know from the start how many passes are needed? How do you know whether a number is prime?
:::

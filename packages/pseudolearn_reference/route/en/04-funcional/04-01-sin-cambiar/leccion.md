---
id: funcional.sin-cambiar
numero: "4.1"
tipo: apertura
titulo: Computing without changing anything
duracion: 30
problema_breve: The receipt that says something else
necesita: [objetos.proyecto]
introduce: [programacion-funcional, inmutabilidad, transparencia-referencial, nucleo-puro]
usa: [paradigma, paso-por-referencia, funcion-pura, efecto, programacion-imperativa, programacion-orientada-a-objetos]
---

::: frase
Functional programming builds programs from calculations that modify nothing: they receive values and give back new values. That way, to know what something is worth, it is enough to read where it comes from.
:::

## The problem {#problema}

::: problema
A kiosk customer buys **3 juices** at 3 pesos and **2 sandwiches** at 5 pesos. For every 10 pesos of purchase, 1 peso is taken off. The till charges **18** pesos, but the receipt the customer takes says **17**. Nobody touched the receipt by hand.

**What happened, and how is the till written so that it cannot happen again?**
:::

```programa id=caja-referencia titulo="The kiosk till" ejecutar
```

```salida
Cobrado: 18
Ticket: 17
```

## Try it {#intentalo}

::: intento
Find the error by reading, without running. Then answer something harder: what is `total` worth just before the last `Write`? Notice what you had to read to answer.
:::

::: respuesta
The second `AplicarDescuento` applies the discount again. Since `total` is passed by reference, each call changes the original box: 19 becomes 18 and then 17.

To know what `total` is worth before the last `Write` you had to read all the previous lines, in order, and count how many times it changed. That is the underlying problem: when a box changes many times, its value depends on the whole history of the program. With ten lines it can be followed; with a thousand, it cannot.
:::

::: recuerda termino=paso-por-referencia
:::

## A new paradigm {#paradigma}

::: recuerda termino=paradigma
:::

Until now you solved problems by giving orders that change boxes and by building objects that keep their state and change it with their methods. Both ways have something in common: the program moves forward by changing things. [[def:programacion-funcional|Functional programming]] proposes the opposite.

::: paradigma
- pregunta: what if nothing changed? What if each value were computed only once, from others, and then stayed fixed?
- metafora: a spreadsheet. The total cell is a formula over other cells: nobody takes something off the total; if a price changes, the total is computed again. It stops working at one point: a spreadsheet recomputes on its own, and a program computes once what it is asked.
- historia: from Alonzo Church's lambda calculus, in 1936, a mathematical theory about what can be computed, older than computers. John McCarthy's Lisp brought it to programming in 1958.
- costo: the world does change: reading a value, showing a receipt or saving a file are changes. They do not disappear; they are put aside, in a small place that is easy to watch.
:::

::: recuerda termino=funcion-pura
:::

You already know the piece everything is built with. This part of the route teaches you to build whole programs with it.

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The prices and the amounts go in; what is charged comes out, and the receipt shows the same.
- **What does it look like?** A formula: price times amount, the lines are added, the discount is taken off.
- **Which part is calculation and which part touches the world?** Computing the total is pure calculation. Showing it on the receipt touches the world.

The third question leads to the central idea of this part. The program is split into two zones: a [[def:nucleo-puro|pure core]], where everything that can be computed goes, and an effectful edge, as thin as possible, where things are read and shown.

```figura id=ruta-nucleo-borde
pie: Everything that can be computed goes to the centre, in pure functions. What touches the world stays on the edge, and the edge is as thin as possible.
```

## Write {#escribir fase=3}

```programa id=caja-funcional titulo="The till, functional version" ejecutar
```

```salida
Cobrado: 18
Ticket: 18
Doble descuento: 17
```

Three things changed:

- No box changes after receiving its value: `aPagar` is computed only once and nothing is ever assigned to it again. Working like this is [[def:inmutabilidad|immutability]]: instead of modifying a value, a new one is computed.
- The discount is not applied: it is computed. `ConDescuento` receives an amount and gives back another; the one it received stays the same.
- If you want two discounts, it shows. The last line asks for them on purpose; in the previous version the double discount was hidden in the order of the lines.

::: especificacion
- subprogramas.pureza
:::

## Test {#probar fase=4}

In the version with boxes that change, to know what `total` was worth you had to follow the history of the program. Here it is enough to replace each call by what it gives back, as in a maths sum:

```figura id=ruta-sustitucion
pie: Each step replaces a call by its result. It works because the functions are pure.
paso: The expression, as it is written.
paso: The two line calls are replaced by 9 and 10.
paso: 9 + 10 is 19.
paso: The discount call is replaced by its calculation, with 19.
paso: 10 fits once in 19: the discount is 1.
paso: The result: 18. There was no need to know what happened earlier in the program.
```

That a call can be replaced by its result anywhere in the program, without anything changing, is [[def:transparencia-referencial|referential transparency]]. That is why the core is easy to test: each function is tested on its own, with a table of cases.

```programa id=casos-descuento titulo="Discount cases" ejecutar
```

```salida
18 9 9 0
```

9 is the edge case: with less than 10 pesos there is no discount. 10 is the first amount with a discount.

## Improve {#mejorar fase=5}

In one sentence: «The till computes what is charged in a core of pure functions, and only the edge shows it».

Compare the two tills. Neither is better at everything: that is the point of having several paradigms.

| | Boxes that change | Pure core |
|---|---|---|
| What is the total worth on a line? | it depends on everything before | the expression that computes it says so |
| Does the order of the lines matter? | yes, a lot | only on the edge |
| Testing a part | prepare the state, run and check | a table of input and output |
| A balance that goes up and down all day | natural | it has to be thought of as a series of new values |

The last row is honest: some problems are better thought of as something that changes. Lesson 4.5 puts the three paradigms face to face.

## What you learned {#aprendiste}

::: resumen
- {programacion-funcional} Functional programming builds programs from pure functions that receive values and give back new values.
- {inmutabilidad} With immutability, instead of modifying a value, a new one is computed.
- {transparencia-referencial} With referential transparency, a call can be replaced by its result without changing the program.
- {nucleo-puro} The pure core keeps the calculation; reading and showing stay on a thin effectful edge.
:::

## Practise {#practica}

::: practica
- funcional.sin-cambiar.nucleo-o-borde
- funcional.sin-cambiar.sustituye
- funcional.sin-cambiar.ticket-puro
- funcional.sin-cambiar.caja-iva
- funcional.sin-cambiar.cual-probar
:::

::: docentes
- **«If nothing changes, it does nothing».** The program does show things: it does so from the edge. Ask them to mark in the functional till which lines are edge.
- **Confusing immutable with a constant written by hand.** `aPagar` is computed; what it does not do is change afterwards.
- **Believing you have to choose a paradigm forever.** The closing table shows that each one makes something different easy.
:::

::: siguiente
Three kiosk loops walk through the same list and only change in one operation. Can the loop be written once and be given the operation?
:::

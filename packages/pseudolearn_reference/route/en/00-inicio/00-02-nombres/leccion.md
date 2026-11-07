---
id: inicio.nombres
numero: "0.2"
tipo: leccion
titulo: Giving data a name
duracion: 20
problema_breve: Change the guests in a single place
necesita: [inicio.primer-problema]
introduce: [variable, valor, memoria, tipo-de-dato, declarar, asignar, division-entera]
usa: [programa, instruccion, ejemplo-a-mano, funcion-ya-hecha]
pieza: 2
---

::: frase
A program remembers data by keeping it in boxes with a name, and each box holds a single value at a time.
:::

## The problem {#problema}

::: problema
The kiosk writes down how many guests confirm for the party: **23** on Monday, **30** on Tuesday and **27** on Wednesday. Each one eats **3 slices** and each pizza has **8 slices**. The person in charge wants a program in which, for each day, changing the number of guests means changing **a single number**.

**How does the program have to be written?**
:::

## Try it {#intentalo}

::: intento
Go back to the party program from [the previous lesson](ruta:inicio.primer-problema). Count how many times 23 appears. What happens if you change one and forget the other?
:::

::: respuesta
23 appears twice: once for the slices and once for the pizzas. If you change only one, the program says one thing on the first line and another on the second, and gives no warning. You need to write the value once and give it a name.
:::

## Understand {#entender fase=1}

Some values change every day (the guests) and some are fixed (3 slices per person, 8 per pizza). The question is not a new sum: it is where each value is written.

First, the worked examples for the three days:

| Day | Guests | Slices | Divided by 8 | Pizzas |
|---|---|---|---|---|
| Monday | 23 | 69 | 8.625 | 9 |
| Tuesday | 30 | 90 | 11.25 | 12 |
| Wednesday | 27 | 81 | 10.125 | 11 |

## Plan {#planear fase=2}

1. Write each value once and give it a name.
2. Compute the slices from the names, not from the numbers.
3. Compute the pizzas from the slices.

## The new tool {#herramienta}

While it runs, a program keeps data in the computer's [[def:memoria|memory]]. Picture it as a shelf of boxes. Each box has a name and holds a [[def:valor|value]]: a number, a text. A box with a name is a [[def:variable|variable]].

Before using a box you have to [[def:declarar|declare]] it: say its name and what kind of value it holds. That kind is its [[def:tipo-de-dato|data type]]. For now three are enough: `Integer` for numbers without decimals, `Real` for numbers with decimals and `String` for texts.

```figura-especificacion seccion=declaraciones.definir figura=cajas-variables
```

Putting a value in a box is to [[def:asignar|assign]] it, and it is written with an arrow `<-`. The new value replaces the previous one, which is lost: each box holds a single value at a time.

```programa id=cumple titulo="One year older" ejecutar
```

```salida
10
11
```

`edad <- edad + 1` (`edad` means age) is not an impossible equation. Read it from right to left: «compute with the old value of `edad` and store the result in `edad`». The old value, 10, is used once and disappears.

```figura-especificacion seccion=declaraciones.asignacion figura=intercambio
```

A second tool is for sharing out. `div` says how many times a whole number fits in another, without decimals; `mod` says how much is left over after sharing. Together they make [[def:division-entera|integer division and its remainder]].

```programa id=caramelos titulo="Sharing sweets" ejecutar
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

## Write {#escribir fase=3}

```programa id=fiesta-nombres titulo="The party with names" ejecutar
```

```salida
Pizzas que hay que pedir: 9
```

The names say what each box holds. `p` would also work, but in a week nobody would remember whether `p` was slices, people or pizzas. `porcionesPorPizza`, slices per pizza, leaves no doubt.

## Test {#probar fase=4}

Change only the first line: 30 guests give 12 pizzas and 27 guests give 11, the same as the worked examples. There is no need to hunt for numbers inside the sums any more.

Be careful with the order. A box holds a value, not a formula: it does not recompute itself.

```figura id=ruta-caja-no-se-recalcula
pie: Assigning copies a value at the moment it runs. If a value changes later, you have to compute again.
paso: The slices are computed with 23 guests: the box holds 69.
paso: The guests box changes to 30. The slices stay at 69: nobody computed them again.
paso: Only when the sum runs again do the slices become 90.
```

## Improve {#mejorar fase=5}

In one sentence: «The program keeps each value once, with a name, and computes the pizzas from those names».

One problem remains. Every day someone has to open the program and change the first line, and the person in charge of the kiosk does not program.

## What you learned {#aprendiste}

::: resumen
- {variable,valor,memoria} Memory is boxes with names; each variable holds one value at a time.
- {declarar,tipo-de-dato} Declaring creates the box and fixes its data type: `Integer`, `Real` or `String`.
- {asignar} Assigning replaces the previous value, which is lost; a box does not recompute itself.
- {division-entera} `div` says how many times a whole number fits in another and `mod` how much is left over.
:::

## Practise {#practica}

::: practica
- inicio.nombres.cajas
- inicio.nombres.que-tipo
- inicio.nombres.figuritas
- inicio.nombres.reparto-caramelos
- inicio.nombres.cronometro
- inicio.nombres.buen-nombre
:::

::: docentes
- **«The variable updates itself, like a spreadsheet».** Use the figure of the boxes that do not recompute and ask them to predict what the slices box holds before the third step.
- **«Adding 1 to a box using the same box is impossible».** Say `x <- x + 1` aloud as «new `x` is old `x` plus 1».
- **«Everything with digits is a number».** The types exercise takes it apart: `"23"` is between quotes, so it is text.
:::

::: siguiente
For each party someone still has to open the program and change a number. What if the person using it cannot program?
:::

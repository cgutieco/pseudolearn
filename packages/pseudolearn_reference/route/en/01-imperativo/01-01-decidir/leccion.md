---
id: imperativo.decidir
numero: "1.1"
tipo: apertura
titulo: Deciding
duracion: 25
problema_breve: The price of a cinema ticket
necesita: [inicio.errores]
introduce: [paradigma, programacion-imperativa, condicion, valor-logico, comparacion, decision, instruccion-actual, particion-de-casos]
usa: [caso-borde, caso-de-prueba, ficha-del-problema, leer-dato, error-de-ejecucion]
pieza: 3
---

::: frase
A program decides by asking a question that can only be answered true or false, and follows a path according to the answer.
:::

## The problem {#problema}

::: problema
At the school cinema, people under **12 years** pay **5 pesos** and everyone else pays **8**.

**How much does each person pay, according to their age?**
:::

## Try it {#intentalo}

::: intento
Say how much people aged 10, 11, 12 and 30 pay.
:::

::: respuesta
They pay 5, 5, 8 and 8. 12 is the one people get wrong most: «under 12» does not include 12.
:::

## A new paradigm {#paradigma}

What you have been doing since Unit 0 has a name. A [[def:paradigma|paradigm]] is a way of organising a program: which pieces it uses and how the person writing it thinks. The first one you will study is [[def:programacion-imperativa|imperative programming]]: the program is a list of orders that keep changing what is in memory.

::: paradigma
- pregunta: what if a program were a list of orders that keep changing what is in memory?
- metafora: a cooking recipe, with steps in order that transform the ingredients. It stops working at one point: a recipe asks nothing, and a program can.
- historia: in 1945, John von Neumann described a computer that keeps the program in its memory, together with the data. In 1957, John Backus's team published FORTRAN, one of the first languages that let you write those orders as formulas.
- costo: to know what a box holds you have to follow the orders in sequence, one by one.
:::

## Understand {#entender fase=1}

The age goes in; the price comes out. The possible ages split into two regions: those who pay 5 and those who pay 8. Between them there is an edge, between 11 and 12.

```figura id=ruta-particion-edad
pie: Two regions and an edge. Each region needs a case; the edge, one on each side.
```

Splitting the inputs like this is making a [[def:particion-de-casos|case partition]]: each region is tested with a worked example, and each edge with two, one on each side.

::: ficha
- entra: the age, in whole years.
- sale: the price of the ticket.
- relacion: if the age is less than 12, the price is 5; otherwise, 8.
- ejemplo: 10 → 5 (region of those who pay 5).
- ejemplo: 11 → 5 and 12 → 8 (both sides of the edge).
- ejemplo: 30 → 8 (region of those who pay 8).
:::

## Plan {#planear fase=2}

1. Ask for the age.
2. If it is less than 12, the price is 5.
3. Otherwise, the price is 8.

## The new tool {#herramienta}

A [[def:condicion|condition]] is a question the program asks itself that has only two possible answers. Each answer is a [[def:valor-logico|boolean value]]: `True` or `False`. The most common questions are [[def:comparacion|comparisons]]: `<`, `<=`, `>`, `>=`, `=` and `<>` (different).

With a condition, the program takes a [[def:decision|decision]]: `If` the condition is true, it runs one path; `Else`, the other. Never both.

```figura-especificacion seccion=control.si figura=si-ordinograma
```

```programa id=alcanza titulo="Is there enough money?" ejecutar
Algoritmo Enough
  Definir money Como Entero <- 10;
  Si money >= 12 Entonces
    Escribir "Enough";
  Sino
    Escribir "Not enough";
  FinSi
FinAlgoritmo
```

```salida
Not enough
```

To follow a program with decisions it helps to picture a finger pointing at the [[def:instruccion-actual|current instruction]], the one being run. In a decision, the finger jumps over the path that is not taken.

```figura id=ruta-dedo-decision
pie: The branch that does not run is dimmed: the finger never goes through it.
paso: The finger starts at the first instruction: the age box is declared.
paso: The age is read: 30 arrives.
paso: The finger reaches the condition. Is 30 less than 12? False.
paso: The finger skips the `Then` branch and enters the `Else` one.
paso: «Pays 8» is shown and the finger leaves the decision.
```

::: especificacion
- control.si
- expresiones.comparacion
- tipos.primitivos
:::

## Write {#escribir fase=3}

```programa id=cine titulo="The cinema price" ejecutar
Algoritmo Cinema
  Definir age Como Entero;
  Leer age;
  Si age < 12 Entonces
    Escribir "Pays 5";
  Sino
    Escribir "Pays 8";
  FinSi
FinAlgoritmo
```

```entrada
11
```

```salida
Pays 5
```

## Test {#probar fase=4}

| Age | Region | By hand | The program |
|---|---|---|---|
| 10 | pay 5 | 5 | Pays 5 |
| 11 | edge, side of 5 | 5 | Pays 5 |
| 12 | edge, side of 8 | 8 | Pays 8 |
| 30 | pay 8 | 8 | Pays 8 |

Four cases cover both regions and both sides of the edge. Testing with 40, 50 and 60 would add nothing: they are in the same region as 30.

## Improve {#mejorar fase=5}

In one sentence: «The program charges 5 to anyone under 12 and 8 to everyone else».

Now the tip calculator from [the previous lesson](ruta:inicio.errores) can stop crashing with 0 friends:

```programa id=propina-segura titulo="The tip, without crashing" ejecutar
Algoritmo Tip
  Definir bill Como Entero;
  Definir friends Como Entero;
  Leer bill;
  Leer friends;
  Si friends = 0 Entonces
    Escribir "Nobody to pay";
  Sino
    Escribir "Each one pays: ", techo((bill + bill div 10) / friends);
  FinSi
FinAlgoritmo
```

```entrada
100
0
```

```salida
Nobody to pay
```

Before, the odd case was a crash. Now it is an answer.

## What you learned {#aprendiste}

::: resumen
- {paradigma,programacion-imperativa} A paradigm is a way of organising a program; in imperative programming, the program is a list of orders that change memory.
- {condicion,valor-logico,comparacion} A condition is a question whose answer is a boolean value: `True` or `False`. Comparisons are conditions.
- {decision,instruccion-actual} A decision runs only one of the paths; the current instruction skips the other.
- {particion-de-casos} A case partition splits the inputs into regions; you test one case per region and both sides of each edge.
:::

## Practise {#practica}

::: practica
- imperativo.decidir.par-impar-predecir
- imperativo.decidir.par-impar
- imperativo.decidir.cine-romper
- imperativo.decidir.zonas-cine
- imperativo.decidir.cine-pruebas
- imperativo.decidir.estacionamiento
:::

::: profundizar titulo="Common pitfalls"
- **«Both branches run».** Use the finger figure and follow it with a pencil on the cinema program.
- **«Under 12 includes 12».** The partition takes it apart: 12 is on the other side of the edge.
- **A number used as a condition.** The engine rejects it with a diagnostic; the details are in [the section](especificacion:control.si).
:::

::: siguiente
On Thursdays everyone pays 4. How do you combine two questions, and in what order do you ask them?
:::

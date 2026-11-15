---
id: procedimental.dividir
numero: "2.1"
tipo: apertura
titulo: Splitting the problem
duracion: 35
problema_breve: The teacher's report card
necesita: [imperativo.proyecto]
introduce: [programacion-procedimental, descomposicion, arbol-de-descomposicion, subprograma, llamada, parametro, valor-de-retorno]
usa: [paradigma, programacion-imperativa, mejor-hasta-ahora, ficha-del-problema, caso-borde]
---

::: frase
A big problem becomes easy when it is split into small problems, each one with its own name.
:::

## The problem {#problema}

::: problema
The teacher has the three marks of each of her **4 pupils**. She wants a report card with each pupil's **average**, whether they **passed** (an average of 6 or more) and who had the **best average**.

**How do you organise a program like that without getting lost?**
:::

## Try it {#intentalo}

::: intento
Work out the report card by hand with these marks: Ana 8, 9 and 10; Beto 5, 6 and 4; Caro 6, 6 and 6; Dani 7, 8 and 6.
:::

::: respuesta
The averages are 9, 5, 6 and 7. Ana, Caro and Dani pass; Caro right on the edge, with 6. The best average is Ana's.

Look at how you did it: you did not think about the report card all at once. First you averaged, then you decided who passed and finally you looked for the best.
:::

## A new paradigm {#paradigma}

Until now you wrote programs as a single list of orders. [[def:programacion-procedimental|Procedural programming]] builds a program from smaller pieces, each one with a name and a job, that ask one another for help.

::: paradigma
- pregunta: what if a big program were built from small pieces, each one with a name and a job?
- metafora: a recipe book that says «make the sauce (page 12)». It stops working at one point: a piece of program receives different data each time it is used.
- historia: in 1949, on the EDSAC computer in Cambridge, David Wheeler devised how to jump to a piece of program and come back, the basis of subprograms. In 1960, ALGOL 60 formalised them with parameters.
- costo: you have to decide where to cut and which data to pass to each piece.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The name and three marks of each pupil go in; one line per pupil and the best average come out.
- **What does it look like?** The average is the money box of [lesson 1.3](ruta:imperativo.mientras); the best is the best so far of [lesson 1.4](ruta:imperativo.contado).
- **Which parts does it split into?** Four jobs that can be thought about separately.

Splitting a problem into subproblems is a [[def:descomposicion|decomposition]]. Drawn from the general to the particular, it is a [[def:arbol-de-descomposicion|decomposition tree]]:

```figura id=ruta-arbol-boletin
pie: Each branch is a smaller problem that is solved separately.
paso: The whole problem: the report card.
paso: It splits into four jobs: read the marks, compute the average, decide the status and find the best.
paso: Each job is so small that you already know how to solve it.
```

## The new tool {#herramienta}

A [[def:subprograma|subprogram]] is a piece of program with a name. Asking it to run is making a [[def:llamada|call]]. The data it receives are its [[def:parametro|parameters]], and what it gives back is its [[def:valor-de-retorno|return value]], given with `Return`.

```figura-especificacion seccion=subprogramas.declaracion figura=subprograma-caja
```

```programa id=doble titulo="Double" ejecutar
SubProceso Double(x Como Entero) Como Entero
  Retornar x * 2;
FinSubProceso

Algoritmo Main
  Escribir Double(21);
FinAlgoritmo
```

```salida
42
```

The subprogram is written before the main algorithm. The call `Double(21)` passes 21 as `x`, and what it returns takes its place.

::: especificacion
- subprogramas.declaracion
- subprogramas.parametros
- subprogramas.llamada
- subprogramas.retornar
:::

## Write {#escribir fase=3}

```programa id=boletin titulo="The report card" ejecutar
SubProceso Average(a Como Entero, b Como Entero, c Como Entero) Como Real
  Retornar (a + b + c) / 3;
FinSubProceso

SubProceso Status(average Como Real) Como Cadena
  Si average >= 6 Entonces
    Retornar "passed";
  FinSi
  Retornar "failed";
FinSubProceso

Algoritmo ReportCard
  Definir name Como Cadena;
  Definir m1, m2, m3 Como Entero;
  Definir bestName Como Cadena <- "";
  Definir bestAverage Como Real <- -1.0;
  Para i <- 1 Hasta 4 Hacer
    Leer name;
    Leer m1;
    Leer m2;
    Leer m3;
    Definir avg Como Real <- Average(m1, m2, m3);
    Escribir name, ": ", avg, " ", Status(avg);
    Si avg > bestAverage Entonces
      bestAverage <- avg;
      bestName <- name;
    FinSi
  FinPara
  Escribir "Best average: ", bestName;
FinAlgoritmo
```

```entrada
Ana
8
9
10
Beto
5
6
4
Caro
6
6
6
Dani
7
8
6
```

```salida
Ana: 9.0 passed
Beto: 5.0 failed
Caro: 6.0 passed
Dani: 7.0 passed
Best average: Ana
```

The main algorithm reads almost like the tree: read, average, decide and find the best. The details of each job are in its subprogram.

## Test {#probar fase=4}

Each subprogram can be tested on its own, before the whole report card:

```programa id=probar-partes titulo="Testing each part" ejecutar
SubProceso Average(a Como Entero, b Como Entero, c Como Entero) Como Real
  Retornar (a + b + c) / 3;
FinSubProceso

SubProceso Status(average Como Real) Como Cadena
  Si average >= 6 Entonces
    Retornar "passed";
  FinSi
  Retornar "failed";
FinSubProceso

Algoritmo Tests
  Escribir Average(6, 6, 6);
  Escribir Status(6.0);
  Escribir Status(5.9);
FinAlgoritmo
```

```salida
6.0
passed
failed
```

`Status(6.0)` and `Status(5.9)` are both sides of the edge. Then the whole report card with the data from the task gives the same as your worked example.

## Improve {#mejorar fase=5}

In one sentence: «The program computes each pupil's average and status with two subprograms and remembers the best».

The school raises the pass mark to 7. A single line changes, inside `Status`, and the rest of the program does not notice.

| | A single list of orders | With subprograms |
|---|---|---|
| To understand it | read everything from top to bottom | read the main one and go into each part when needed |
| To test it | only the whole program | each part on its own |
| To change it | search the whole program | change one part |

## What you learned {#aprendiste}

::: resumen
- {programacion-procedimental} Procedural programming builds a program from subprograms that call one another.
- {descomposicion,arbol-de-descomposicion} Decomposing is splitting a problem into subproblems; the decomposition tree draws them from the general to the particular.
- {subprograma,llamada} A subprogram is a piece of program with a name; calling it is asking it to run.
- {parametro,valor-de-retorno} The parameters are the data it receives; the return value is what it gives back.
:::

## Practise {#practica}

::: practica
- procedimental.dividir.excursion
- procedimental.dividir.sumar-tres
- procedimental.dividir.area
- procedimental.dividir.propina-partes
- procedimental.dividir.buen-nombre-sub
- procedimental.dividir.boletin-chico
:::

::: profundizar titulo="Common pitfalls"
- **A subprogram that does two things.** Describe it in one sentence without «and»; if you cannot, it is two subprograms.
- **Names that do not say what they do.** `Calculate` or `Process` do not help: the name is half of the documentation.
- **Forgetting the return.** A subprogram with a return type and no `Return` does not compile; the diagnostic says so.
:::

::: siguiente
A subprogram receives the balance of a card and doubles it. When it comes back, the balance is the same. What does each part of the program see?
:::

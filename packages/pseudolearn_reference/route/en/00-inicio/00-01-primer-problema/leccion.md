---
id: inicio.primer-problema
numero: "0.1"
tipo: leccion
titulo: Your first problem
duracion: 15
problema_breve: How many pizzas should we order for the party?
introduce: [problema, ejemplo-a-mano, programa, instruccion, ejecutar, salida, funcion-ya-hecha, ciclo-pseudolearn]
pieza: 1
---

::: frase
Programming is solving a problem and then explaining the solution to a computer so clearly that it cannot get it wrong.
:::

## The problem {#problema}

::: problema
Year five is organising the end-of-year party at the school kiosk. **23 people** are coming. Each one eats **3 slices** of pizza, and each pizza has **8 slices**.

**How many pizzas do we have to order?**
:::

## Try it {#intentalo}

::: intento
Before reading on, solve it with pencil and paper. You do not need to know how to program: you need to think.
:::

::: respuesta
23 people times 3 slices is 69 slices. With 8 pizzas you have 64 slices: 5 are missing. You have to order **9 pizzas**.

If you answered 8, five people go hungry. If you answered 8.6, nobody sells six tenths of a pizza. Both answers come from doing the sum right and not looking at the question.
:::

What you just solved is a [[def:problema|problem]]: a situation with values you know (23 people, 3 slices, 8 per pizza) and a question that has no answer yet. Programming always starts like this: with a problem, not with a computer.

## The PseudoLearn cycle {#ciclo}

To solve any problem you will always follow the same five steps. Together they make [[def:ciclo-pseudolearn|the PseudoLearn cycle]]. At first we guide you through each one; with time you will do them without thinking.

```figura id=ruta-ciclo
pie: The solid arrows are the usual path. If something fails when you test it, you do not start from scratch: you go back to planning.
```

| Step | The question you ask yourself |
|---|---|
| 1. Understand | What am I given, what am I asked, and can I solve it by hand? |
| 2. Plan | Which steps do I follow, and in what order? |
| 3. Write | How do I tell the computer? |
| 4. Test | Does the computer answer the same as I did by hand? |
| 5. Improve | Can I explain it in one sentence? What if the request changes? |

Now go through the five steps with the pizza problem.

## Understand {#entender fase=1}

Understanding means separating what you know from what you are asked, and checking that you could solve it without a computer.

- **What you know:** 23 people, 3 slices per person, 8 slices per pizza.
- **What you are asked:** how many pizzas. Notice a detail in the question: pizzas are ordered **whole**.

The best way to understand a problem is to solve concrete cases with pencil and paper. Each one is a [[def:ejemplo-a-mano|worked example]]. It helps twice: now, to discover how to solve it, and in step 4, to know what the computer must answer. Always do at least two.

| People | Slices | Divided by 8 | Pizzas |
|---|---|---|---|
| 23 | 69 | 8 with 5 left over | 9 |
| 8 | 24 | exactly 3 | 3 |

The second example teaches something: when the division is exact, you must not order an extra pizza.

## Plan {#planear fase=2}

Look at what you did in the examples and write it as steps, in your own words:

1. Multiply the people by the slices each one eats.
2. Divide that result by the slices in one pizza.
3. If the result has decimals, round up.

That is already the solution. What is left is telling it to the computer.

## Write {#escribir fase=3}

A [[def:programa|program]] is a list of orders written for a computer. Each order is an [[def:instruccion|instruction]]. The computer reads them from top to bottom, one at a time, and does exactly what each one says: no more, no less, and not what you meant.

```figura id=ruta-instrucciones-en-orden
pie: Each step runs a single instruction and adds one line to the output, always from top to bottom.
paso: The first instruction shows the text between quotes.
paso: The second computes 2 + 3 and shows the result.
paso: The third shows the text as it is, because it is between quotes.
```

This is a complete program:

```programa id=hola titulo="My first program" ejecutar
```

```salida
Hola
5
2 + 3
```

- `Algorithm Hola` and `EndAlgorithm` are the envelope of the program: they say where it starts, what it is called and where it ends.
- `Write` shows something on the screen. What the program shows is its [[def:salida|output]].
- What goes between quotes is shown as it is. What goes without quotes is computed first: that is why `5` appears and then `"2 + 3"` as it is.
- Each instruction ends with a semicolon.

Asking the computer to do what the program says is to [[def:ejecutar|run]] it. In the app it is the ▶ button.

Sums are written almost as at school: `+`, `-`, `*` to multiply and `/` to divide. A single `Write` can show several things in a row if you separate them with commas. With that you can already write steps 1 and 2 of the plan:

```programa id=fiesta-1 titulo="Party, first attempt" ejecutar
```

```salida
Porciones que hacen falta: 69
Pizzas: 8.625
```

The computer did exactly what you asked: divide. It does not know that pizzas are ordered whole, because nobody told it. Step 3 of the plan is missing.

PseudoLearn comes with ready-made calculations. `ceil` is a [[def:funcion-ya-hecha|built-in function]]: it receives a number between brackets and returns the whole number above it if the number has decimals, or the same number if it has none.

```programa id=fiesta-2 titulo="Party, solution" ejecutar
```

```salida
Porciones que hacen falta: 69
Pizzas que hay que pedir: 9
```

The first line of the body does step 1 of the plan; the second does steps 2 and 3 together. If you want to know exactly how each thing you used is written, it is in the Specification. You do not need to read it now: it is the place to look up a doubt.

::: especificacion
- programas.estructura
- biblioteca.consola
- expresiones.aritmeticos
- biblioteca.matematicas
:::

## Test {#probar fase=4}

A program showing a number does not mean the number is right. Testing is comparing what the computer answers with your worked examples. For the second example, change 23 to 8 and run it again:

```programa id=fiesta-8 titulo="Party with 8 people" ejecutar
```

```salida
Pizzas que hay que pedir: 3
```

| People | By hand | The program | Do they match? |
|---|---|---|---|
| 23 | 9 | 9 | yes |
| 8 | 3 | 3 | yes |

The 8-people example was the important one: it is the case where a hurried solution orders one pizza too many. The exercises in this lesson teach you to look for those cases on purpose.

## Improve {#mejorar fase=5}

Explain it in one sentence. If you cannot, you do not fully understand it yet: «The program works out how many whole pizzas are enough for everybody to eat their slices».

What if the request changes? Tomorrow they confirm **30 people** who eat **2 slices** each. To adapt it you have to find the 23 and the 3 inside the instructions and change them on every line where they appear. In a program of a hundred lines, missing one would be easy to do, and the program would give a wrong result without warning.

## What you learned {#aprendiste}

::: resumen
- {problema} A problem has known values and a question; before programming, you read the question carefully.
- {ejemplo-a-mano} A worked example is a case solved with pencil and paper; it helps you discover the solution and check it.
- {programa,instruccion,ejecutar} A program is a list of instructions that the computer runs from top to bottom, exactly as they are written.
- {salida} The output is what the program shows; what goes between quotes is shown as it is and the rest is computed.
- {funcion-ya-hecha} A built-in function, such as `ceil`, receives a value and returns another.
- {ciclo-pseudolearn} The PseudoLearn cycle has five steps: understand, plan, write, test and improve.
:::

## Practise {#practica}

No exercise tells you what to write. It gives you a problem, and the cycle is yours.

::: practica
- inicio.primer-problema.que-aparece
- inicio.primer-problema.mesas
- inicio.primer-problema.bus-excursion
- inicio.primer-problema.ana-y-beto
- inicio.primer-problema.ascensor
- inicio.primer-problema.pintar-aula
:::

::: docentes
- **«The computer understands what I meant».** The first party attempt shows 8.625. Ask the group to predict the output before running it: almost nobody expects decimals.
- **Forgotten quotes.** Many write `Write Hola;` without quotes. The engine message mentions things not seen yet: just say «the quotes are missing» and move on.
- **Skipping step 1.** Demand the two worked examples before opening the editor. The 8-people one is what breaks Beto's solution in the exercises.
:::

::: por-dentro
Before running, the engine reads the text, checks that it is well written and turns it into smaller orders the machine knows how to do. That journey is told, with figures, in the Specification.

::: especificacion
- vision.viaje
:::
:::

::: siguiente
How do we write the party so that changing the number of guests means changing a single number?
:::

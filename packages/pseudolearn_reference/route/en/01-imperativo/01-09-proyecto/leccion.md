---
id: imperativo.proyecto
numero: "P·I"
tipo: proyecto
titulo: "Project: the kiosk till"
duracion: 60
problema_breve: The day's receipt
necesita: [imperativo.estrategias]
introduce: []
usa: [ficha-del-problema, centinela, arreglo, acumulador, contador, mejor-hasta-ahora, caso-borde, esquema]
---

::: frase
A project is a big problem that you solve with the tools you already have.
:::

## The problem {#problema}

::: problema
During break, the kiosk till writes down each sale as a **product code** and an **amount**. When closing, it writes the code **0**. The products are: 1 Juice at 3 pesos, 2 Sandwich at 5, 3 Biscuit at 2, 4 Water at 1 and 5 Fruit at 2. For every 10 pesos of purchase, 1 peso is taken off.

You have to show the day's receipt: one line per sale with the product, the amount and the price; the total; the total with discount; and the product that sold the most units. A code that does not exist is reported and ignored.

**What does the till program look like?**
:::

## Try it {#intentalo}

::: intento
Build by hand the receipt of a break with these sales: 3 juices, 2 sandwiches, 1 biscuit and 1 more juice.
:::

::: respuesta
The prices are 9, 10, 2 and 3. The total is **24**; with the 2-peso discount it comes to **22**. The best seller is **Juice**, with 4 units.
:::

## Understand {#entender fase=1}

This problem has a lot of data, and not all of it matters equally. Before writing anything, fill in the problem card: it is the first exercise of the project.

::: recuerda termino=ficha-del-problema
:::

The format of the receipt has to be exact. The product names are written as the program writes them. For the example in the task:

- `Juice x 3 = 9`
- `Sandwich x 2 = 10`
- `Cookie x 1 = 2`
- `Juice x 1 = 3`
- `Total: 24`
- `With discount: 22`
- `Best seller: Juice`

If a sale brings a code that does not exist, for example 7, the line says «Code 7 does not exist» and the amount is read but ignored. A day without sales shows total 0, with discount 0 and «Best seller: Nobody». If two products tie in units, the one with the lowest code wins.

## Plan {#planear fase=2}

The plan is yours too: the second exercise asks you to put its steps in order. Think of the patterns you already know: what is gathered, what is counted, what is searched for?

::: recuerda termino=esquema
:::

## Write {#escribir fase=3}

The third exercise is the complete program. Write it step by step, running after each part: first read the sales until 0, then the lines of the receipt, then the totals and finally the best seller.

## Test {#probar fase=4}

Before declaring the program finished, test it with:

| Case | Why |
|---|---|
| The example in the task | the normal case |
| A 0 straight away | the day without sales: total 0 and «Nobody» |
| An invalid code in the middle | it is reported and does not break the rest |
| Two products tied | the one with the lowest code wins |
| A single sale | the shortest receipt |

## Improve {#mejorar fase=5}

In one sentence: «The program reads the sales until 0, writes each line of the receipt and closes with the total, the discount and the best seller».

What if the kiosk adds a sixth product? If the names and prices are in arrays, making them bigger is enough. If they are spread across decisions, you have to touch the program in many places.

## What you learned {#aprendiste}

::: resumen
- A big problem is solved by combining decisions, loops, arrays and patterns you already know.
- The card and the plan, made before writing, put the work in order and say what to test.
:::

## Practise {#practica}

::: practica
- imperativo.proyecto.caja-ficha
- imperativo.proyecto.caja-plan
- imperativo.proyecto.caja
:::

::: profundizar titulo="Common pitfalls"
- **Opening the editor before planning.** Make the card and the plan on paper; the editor opens afterwards.
- **Not testing the day without sales.** It is the case that breaks most programs: the best seller does not exist.
- **The tie-break.** When the best seller is also replaced with equal units, the one with the highest code wins.
:::

::: siguiente
The till program is already long and hard to read in one go. How do you split a big program into pieces with names?
:::

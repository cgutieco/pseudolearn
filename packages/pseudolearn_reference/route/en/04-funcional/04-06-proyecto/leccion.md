---
id: funcional.proyecto
numero: "P·IV"
tipo: proyecto
titulo: "Project: the functional kiosk"
duracion: 60
problema_breve: The day's report
necesita: [funcional.cara-a-cara]
introduce: []
usa: [nucleo-puro, funcion-pura, mapear, filtrar, reducir, clausura, fabrica-de-funciones, registro, vector]
---

::: frase
When all the calculation lives in a pure core, the report is built by composing pieces that are tested on their own.
:::

## The problem {#problema}

::: problema
At the end of the day, the till has the list of sales: product code and amount, until a 0. The prices are the kiosk's. A **report** has to be shown: the total, the total with discount, how many sales were over **5 pesos** and the **star product**, the one that sold the most units. The sums neither read nor show anything: that is left for the start and the end.

**What does the report look like?**
:::

## Try it {#intentalo}

::: intento
Build by hand the report of a day with these sales: 3 juices, 2 sandwiches, 1 biscuit and 1 more juice.
:::

::: respuesta
The amounts are 9, 10, 2 and 3. The total is **24**; with discount, **22**. **2** sales are over 5 pesos, the one of 9 and the one of 10. The star product is **Juice**, with 4 units.
:::

## Understand {#entender fase=1}

The format of the report is exact; the texts are exactly those the program writes. For the example in the task:

- `Total: 24`
- `With discount: 22`
- `Sales over 5 pesos: 2`
- `Star product: Juice`

A day without sales shows everything at 0 and `Star product: None`. If two products tie in units, the one with the lowest code wins.

The first exercise asks you to separate the jobs of the core and of the edge.

::: recuerda termino=nucleo-puro
:::

## Plan {#planear fase=2}

The second exercise asks you to order the steps of the plan. Think about what is computed with each of the three pieces of [lesson 4.2](ruta:funcional.orden-superior): the amounts, the big sales and the total.

## Write {#escribir fase=3}

The third exercise is the complete program. Start with the small functions, which are tested on their own: the price, the amount and the discount. Then `Map`, `Filter` and `Reduce`. For the star product, a function factory that counts the units of a code, as in [lesson 4.3](ruta:funcional.clausuras).

## Test {#probar fase=4}

| Case | Why |
|---|---|
| The example in the task | the normal case |
| A day without sales | the total at 0 and no star product |
| All sales of 5 pesos or less | no big sale |
| Two products with the same units | the tie-break |

## Improve {#mejorar fase=5}

In one sentence: «The report reads the sales on the edge and computes everything else by composing pure functions».

What if tomorrow they ask for the average per sale? It is another function on the same amounts: the rest of the report does not change.

## What you learned {#aprendiste}

::: resumen
- A whole report is built by composing pure functions that are tested separately.
- The edge only reads and shows; the core does all the sums.
:::

## Practise {#practica}

::: practica
- funcional.proyecto.reporte-nucleo
- funcional.proyecto.reporte-plan
- funcional.proyecto.reporte
:::

::: profundizar titulo="Common pitfalls"
- **Showing from a function.** The engine rejects it; use it to remember where each thing goes.
- **Walking through the sales four times by hand.** It is right, but the exercise asks for the three pieces of Part IV.
- **The tie-break.** With a strict `>` the first one checked wins, which is the one with the lowest code.
:::

::: siguiente
Three people work at the same time in the kiosk kitchen. How do you write a program where several things move forward at the same time?
:::

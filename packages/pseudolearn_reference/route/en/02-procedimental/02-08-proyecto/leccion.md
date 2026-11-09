---
id: procedimental.proyecto
numero: "P·II"
tipo: proyecto
titulo: "Project: the kiosk in parts"
duracion: 60
problema_breve: The till with stock
necesita: [procedimental.modulos]
introduce: []
usa: [descomposicion, arbol-de-descomposicion, funcion-pura, registro, vector, resultado-con-error, validar, ficha-del-problema]
---

::: frase
A program split into named pieces can be read, tested and changed one piece at a time.
:::

## The problem {#problema}

::: problema
The kiosk till now also keeps the **stock**. Each product starts with a known stock: juice **10**, sandwich **5**, biscuit **8**, water **12** and fruit **6**. The prices and the discount are the usual ones.

A sale that asks for more than is left is **rejected with its reason**, just like a code that does not exist or an amount less than 1. When closing, with code 0, the total, the total with discount and the **stock left** of each product are shown.

**What does the new till look like?**
:::

## Try it {#intentalo}

::: intento
Work out by hand a break with these sales: 3 juices, 6 sandwiches, 5 sandwiches and a sale with code 9.
:::

::: respuesta
The 3 juices are accepted: 7 are left. The 6 sandwiches are rejected, because there are only 5. The 5 sandwiches are accepted: 0 are left. Code 9 does not exist. The total is 9 + 25 = **34**; with the discount, **31**.
:::

## Understand {#entender fase=1}

Fill in the problem card: it is the first exercise of the project. The format of the receipt has to be exact; the texts stay in Spanish, as the program writes them. For the example in the task:

- `Jugo x 3 = 9`
- `Sándwich x 6 rechazado: quedan 5`
- `Sándwich x 5 = 25`
- `Código 9 no existe`
- `Total: 34`
- `Con descuento: 31`
- `Stock final:` and one line per product, such as `Jugo 7`

An amount less than 1 is rejected with the line «Cantidad 0 no válida» (with the amount that arrived).

## Plan {#planear fase=2}

The second exercise asks you to share out the jobs in a decomposition tree, and the third, to order the steps of the plan. Think about which pieces can be pure functions and which data should be grouped in a record.

::: recuerda termino=arbol-de-descomposicion
:::

## Write {#escribir fase=3}

The fourth exercise is the complete program. Write it piece by piece: first the pure functions, which are tested on their own; then the record of the products; finally the main algorithm that reads, validates and shows.

## Test {#probar fase=4}

| Case | Why |
|---|---|
| The example in the task | the normal case, with both kinds of rejection |
| A sale that leaves the stock exactly at 0 | the edge of the stock |
| A sale of 0 units | the invalid amount |
| Everything rejected | the total stays at 0 and the stock untouched |
| A 0 straight away | the day without sales |

## Improve {#mejorar fase=5}

In one sentence: «The till validates each sale, registers it if there is stock and closes with the total, the discount and what is left».

Compare it with the till of [Part I](ruta:imperativo.proyecto): if the discount changes, one function is touched; if the format of the receipt changes, the lines that write are touched; if a product is added, one line of the catalogue.

## What you learned {#aprendiste}

::: resumen
- A big problem is split into pieces: pure functions to compute, records for the data that goes together and a main algorithm that reads and shows.
- Expected errors, such as a sale without stock, are answered with their reason and the program carries on.
:::

## Practise {#practica}

::: practica
- procedimental.proyecto.kiosco-ficha
- procedimental.proyecto.kiosco-arbol
- procedimental.proyecto.kiosco-plan
- procedimental.proyecto.kiosco-partes
:::

::: profundizar titulo="Common pitfalls"
- **Writing everything in the main algorithm.** It works, but what was learned in this part is lost. Name the pieces before writing.
- **Taking off the stock before validating.** A rejected sale must not touch the stock: the «everything rejected» case uncovers it.
- **Forgetting to put the record back.** A card copied from the vector changes on its own; it has to be stored in the vector again.
:::

::: siguiente
A kiosk account has a balance, and sometimes someone leaves the balance negative by mistake. How do you bring together the data and the actions that look after it?
:::

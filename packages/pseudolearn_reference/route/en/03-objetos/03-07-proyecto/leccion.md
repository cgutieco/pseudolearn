---
id: objetos.proyecto
numero: "P·III"
tipo: proyecto
titulo: "Project: the kiosk with objects"
duracion: 75
problema_breve: The till with objects and payment methods
necesita: [objetos.responsabilidades]
introduce: []
usa: [clase, objeto, encapsulamiento, invariante-de-clase, interfaz, polimorfismo, responsabilidad, tarjeta-de-responsabilidad, colaborador]
---

::: frase
A program with well-shared objects grows by adding pieces, not by breaking the ones already there.
:::

## The problem {#problema}

::: problema
It is the till with stock of [Part II](ruta:procedimental.proyecto), now shared out into pieces that look after their own data. When closing, the customer chooses to pay in **cash** or by **card**, which has a **5 %** surcharge in whole pesos on the total with discount. The stock **never** goes negative.

**How is the work shared out among the pieces?**
:::

## Try it {#intentalo}

::: intento
Work out how much is paid by card for the sales of the previous project: 3 juices, 6 rejected sandwiches, 5 sandwiches and a code 9.
:::

::: respuesta
The total with discount is 31, as before. By card: 31 + `31 * 5 div 100`, that is, **32**. In cash, 31.
:::

## Understand {#entender fase=1}

The format of the receipt is that of Part II, with one more line after the discount: «A pagar en efectivo: 31» or «A pagar con tarjeta: 32». The payment method is read after the 0 that closes the till, as the word `efectivo` (cash) or `tarjeta` (card).

The first exercise asks you to share out the responsibilities on cards.

::: recuerda termino=tarjeta-de-responsabilidad
:::

## Plan {#planear fase=2}

The second exercise asks you to order the steps of the plan. Think about which piece has the information for each step: the product knows its price, the inventory its stock, the till its total and the payment method how it charges.

## Write {#escribir fase=3}

The third exercise is the complete program. Start with the simplest pieces, which depend on nobody: the product, the inventory and the payment methods. Then the till, and finally the main algorithm.

## Test {#probar fase=4}

| Case | Why |
|---|---|
| The sales of Part II by card | the surcharge |
| The same in cash | no surcharge |
| A day without sales, with both methods | a total of 0 is also charged as 0 |
| A sale that uses up the stock and another rejected | the inventory's invariant |

## Improve {#mejorar fase=5}

In one sentence: «Each kiosk piece looks after its data, and the till coordinates the sale and the payment without knowing how each method charges».

Adding a new payment method, such as the voucher, is one more class that meets the contract. No other piece changes.

## What you learned {#aprendiste}

::: resumen
- Sharing out by information leaves each change in a single piece.
- A contract lets you add new cases, such as a payment method, without touching whoever uses them.
:::

## Practise {#practica}

::: practica
- objetos.proyecto.objetos-tarjetas
- objetos.proyecto.objetos-plan
- objetos.proyecto.kiosco-objetos
:::

::: profundizar titulo="Common pitfalls"
- **A piece that does everything, under another name.** When the till computes amounts and takes off stock, it is the piece that does everything of lesson 3.6.
- **Public stock.** When the main algorithm can change the stock, the invariant depends on nobody making a mistake.
- **A payment method chosen with many paths.** The choice happens once, when closing; the payment is done by the method.
:::

::: siguiente
One day the kiosk's total came out different depending on the order in which the discounts were added. Can it be computed without changing anything?
:::

---
id: objetos.responsabilidades
numero: "3.6"
tipo: leccion
titulo: Whose job is it?
duracion: 30
problema_breve: The kiosk class that does everything
necesita: [objetos.componer]
introduce: [responsabilidad, tarjeta-de-responsabilidad, colaborador]
usa: [clase, objeto, metodo, encapsulamiento, composicion, interfaz]
---

::: frase
Each job belongs to the class that has the information to do it.
:::

## The problem {#problema}

::: problema
A single piece of the kiosk, `Kiosco`, reads the sales, computes the amounts, takes off the stock, applies the discount and writes the receipt. Every change, however small, touches that piece, and it already has **600 lines**.

**How is the work shared out?**
:::

## Try it {#intentalo}

::: intento
Make a list of the jobs of `Kiosco` and write next to each one which data it needs to be done.
:::

::: respuesta
Computing an amount needs the price of the product. Taking off the stock needs how much is left. Gathering the total and applying the discount need what was sold. Writing the receipt needs the lines of each sale. Each job needs different data: that is the clue that there are different pieces.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The same as before: what changes is who does each part.
- **What does it look like?** The modules of [lesson 2.7](ruta:procedimental.modulos): bringing together what changes for the same reason.
- **Who has the information to do this?** That question, asked for each job, shares out the work.

```figura id=ruta-tarjetas
pie: Each card says what a class knows or does and whom it asks for help.
```

## The new tool {#herramienta}

There is no new construction. There is a way of thinking. A [[def:responsabilidad|responsibility]] is something a class knows or does. To do it, it sometimes asks others for help: those are its [[def:colaborador|collaborators]]. A [[def:tarjeta-de-responsabilidad|responsibility card]] writes down, for each class, its job and whom it works with, before writing code.

| Class | Its job | Works with |
|---|---|---|
| `Producto` | knowing its name and price; computing the amount of a quantity | — |
| `Inventario` | knowing how much is left of each product; taking away if there is enough | — |
| `Ticket` | noting lines and printing them | — |
| `Caja` | registering a sale and gathering the total | `Producto`, `Inventario`, `Ticket` |

## Write {#escribir fase=3}

```programa id=kiosco-repartido titulo="The kiosk shared out" ejecutar
```

```salida
Jugo x 3 = 9
Sándwich x 6 rechazado
Sándwich x 5 = 25
Total: 34
```

## Test {#probar fase=4}

The outputs are the same that the single class gave for the same sales: the behaviour did not change, the sharing out did. And now each piece can be tested on its own: `Producto.Importe` with a table of cases, `Inventario.Quitar` with an exact stock and one that is not enough.

## Improve {#mejorar fase=5}

In one sentence: «Each kiosk class does what its information allows, and the till coordinates the sale by asking them for help».

Changing the format of the receipt touches only `Ticket`. Adding a tax to the amount touches only `Producto`. With a single class, each of those changes touched the same file of 600 lines.

## What you learned {#aprendiste}

::: resumen
- {responsabilidad,colaborador} A responsibility is something a class knows or does; its collaborators are the classes it asks for help.
- {tarjeta-de-responsabilidad} A responsibility card writes down a class, its job and whom it works with.
:::

## Practise {#practica}

::: practica
- objetos.responsabilidades.a-quien-le-toca
- objetos.responsabilidades.dos-disenos
- objetos.responsabilidades.colaboracion
- objetos.responsabilidades.mover-metodo
- objetos.responsabilidades.clase-dios
:::

::: profundizar titulo="Common pitfalls"
- **Classes named after verbs.** A «Calculator» is usually a job that belongs to another class.
- **Sharing out by size and not by information.** Splitting a big class into two halves does not help if both need the same data.
- **Cards with ten responsibilities.** A card that does not fit on the paper is a class that does too much.
:::

::: siguiente
The kiosk, now with objects.
:::

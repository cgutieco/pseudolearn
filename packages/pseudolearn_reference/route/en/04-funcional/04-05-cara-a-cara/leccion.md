---
id: funcional.cara-a-cara
numero: "4.5"
tipo: leccion
titulo: Face to face
duracion: 30
problema_breve: Three changes for three kiosks
necesita: [funcional.tipos-dominio]
introduce: []
usa: [paradigma, programacion-imperativa, programacion-orientada-a-objetos, programacion-funcional, interfaz, funcion-pura, nucleo-puro]
---

::: frase
No paradigm always wins: each one makes one kind of change easy.
:::

## The problem {#problema}

::: problema
The kiosk is going to receive three change requests: adding a **new tax**, adding a **way of paying** and adding a **daily sales report**. The till is written in three ways: with orders that change boxes, with pieces that keep their state and with calculations that change nothing.

**Which one suits each change?**
:::

## Try it {#intentalo}

::: intento
Choose by eye, before looking at the code, which version you would change with the least effort for each request.
:::

::: respuesta
The tax is a new operation on the same data: the functional version adds it with a function. The payment method is a new kind of thing that meets a contract: the object version adds it with a class. The report is another transformation of the sales: again, the functional one. The imperative one works while the program is short.
:::

## Understand and plan {#entender-planear fase=1-2}

::: recuerda termino=paradigma
:::

- **What goes in and what comes out?** The same in all three versions: the test order, 3 juices and 2 sandwiches, and its total.
- **What does it look like?** The three tills of [Part I](ruta:imperativo.proyecto), [Part III](ruta:objetos.proyecto) and [lesson 4.1](ruta:funcional.sin-cambiar).
- **Which part is calculation and which part touches the world?** The total and the discount are calculation; showing them touches the world.

```figura id=ruta-tres-kioscos
pie: The same receipt, thought of in three ways.
paso: Orders that change boxes: the total keeps accumulating.
paso: Pieces that work together: the till keeps its total and knows the discount.
paso: Functions that transform: the total comes out of an expression.
```

## Write {#escribir fase=3}

All three versions show the same:

```programa id=kiosco-imperativo titulo="The imperative kiosk" ejecutar
```

```salida
Total: 19
Con descuento: 18
```

```programa id=kiosco-objetos titulo="The kiosk with objects" ejecutar
```

```salida
Total: 19
Con descuento: 18
```

```programa id=kiosco-funcional titulo="The functional kiosk" ejecutar
```

```salida
Total: 19
Con descuento: 18
```

## Test {#probar fase=4}

For each change, how many parts have to be touched in each version:

| Change | Imperative | With objects | Functional |
|---|---|---|---|
| A new tax | the total line and those that use it | a till method, and maybe another | a new function and the total expression |
| A payment method | a decision in the payment | a new class that meets the contract | a new function and a decision to choose it |
| A daily report | another walk with more boxes | one more till method | one more function on the same sales |

## Improve {#mejorar fase=5}

In one sentence: «The paradigm is chosen by the kind of change expected, not by taste».

A real program usually mixes them: a functional core for the calculations, objects for what has state, such as the inventory, and a short imperative edge that reads and shows.

## What you learned {#aprendiste}

::: resumen
- Objects make it easy to add new kinds of things that share a contract.
- Functions make it easy to add new operations on the same data.
- The imperative style is direct for short programs that do one thing.
:::

## Practise {#practica}

::: practica
- funcional.cara-a-cara.que-paradigma
- funcional.cara-a-cara.mismo-ticket
- funcional.cara-a-cara.impuesto
- funcional.cara-a-cara.medio-nuevo
- funcional.cara-a-cara.mezcla
:::

::: profundizar titulo="Common pitfalls"
- **«Functional is the modern one».** The three paradigms are decades old; what matters is which change each one makes easy.
- **Choosing by taste.** Name the change you expect before choosing.
:::

::: siguiente
The functional kiosk.
:::

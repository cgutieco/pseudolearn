---
id: objetos.contratos
numero: "3.4"
tipo: leccion
titulo: Contracts
duracion: 35
problema_breve: The till's payment methods
necesita: [objetos.identidad]
introduce: [interfaz, polimorfismo, despacho-dinamico]
usa: [clase, objeto, metodo, seleccion-multiple, subprograma, parametro]
---

::: frase
If the code depends on what an object promises and not on which object it is, cases can be added without touching it.
:::

## The problem {#problema}

::: problema
The till charges in **cash** (no surcharge), by **card** (5 % surcharge, in whole pesos) and with a **voucher** (it pays up to what the voucher holds). Today the till asks which way of paying it is and has one path for each, and next week **bank transfer** is added.

**How is the till written so that a new way of paying does not force you to change it?**
:::

## Try it {#intentalo}

::: intento
Work out how much is charged for 20 pesos with each method, if the voucher is for 15.
:::

::: respuesta
In cash, 20. By card, 21: 20 plus `20 * 5 div 100`. With the voucher, 15, and 5 are missing that will have to be paid another way.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The method and the amount go in; what was charged comes out.
- **What does it look like?** The kiosk menu of [lesson 1.2](ruta:imperativo.caminos): a `Switch` with one case per option. It works, but each new option changes it.
- **Who has the information to do this?** Every payment method knows how it charges. What does not change is that the till asks it to charge.

## The new tool {#herramienta}

An [[def:interfaz|interface]] is a contract: the methods a class promises to have, without saying how it does them. A class meets it with `Implements`.

```figura id=ruta-enchufe
pie: The till is a socket; each payment method, an appliance with the same plug. The analogy fails at one point: an appliance does not change what it does depending on who plugs it in, and an object can do different things with the same request.
```

```figura-especificacion seccion=objetos.interfaces figura=interfaz-promesa
```

Using objects of different classes through the same contract is [[def:polimorfismo|polymorphism]]. When the till asks `medio.Cobrar(monto)`, the engine chooses, while running, the method of the real class of the object it received: that is [[def:despacho-dinamico|dynamic dispatch]].

In PseudoLearn an interface is not used as the type of a variable: it is used as the condition on the type of a parameter. `CobrarCon<T: MedioDePago>` accepts any class that meets the contract. The details are in [the Specification](especificacion:objetos.interfaces).

::: especificacion
- objetos.interfaces
:::

## Write {#escribir fase=3}

```programa id=medios-de-pago titulo="The till that accepts any method" ejecutar
```

```salida
Efectivo: 20
Tarjeta: 21
Vale: 15
```

`CobrarCon` does not know which methods exist: it only knows that the one it receives meets the contract `MedioDePago`.

## Test {#probar fase=4}

| Method | Amount | Expected | Why |
|---|---|---|---|
| Cash | 20 | 20 | no surcharge |
| Card | 20 | 21 | 5 % surcharge |
| Voucher of 15 | 20 | 15 | the voucher is not enough |
| Any | 0 | 0 | edge: there is nothing to charge |

## Improve {#mejorar fase=5}

In one sentence: «The till asks a payment method that meets the contract to charge, without knowing which one it is».

Adding the transfer is writing a new class that implements `MedioDePago`. `CobrarCon` does not change. With the `Switch`, instead, you had to add a case in the till and anywhere else that chose by payment method.

## What you learned {#aprendiste}

::: resumen
- {interfaz} An interface is a contract: the methods a class promises to have.
- {polimorfismo,despacho-dinamico} Polymorphism is using objects of different classes through the same contract; dynamic dispatch chooses while running the method of the real class.
:::

## Practise {#practica}

::: practica
- objetos.contratos.cumple-contrato
- objetos.contratos.que-metodo
- objetos.contratos.transferencia
- objetos.contratos.figuras-area
- objetos.contratos.por-que-contrato
:::

::: docentes
- **An interface with methods nobody uses.** The contract has to be what the till needs, no more and no less.
- **The choice by method that reappears somewhere else.** When choosing the method needs a decision, let it be a single one at the start of the program.
- **Confusing an interface with sharing code.** An interface promises methods; it does not share code. The next lesson shows how code is shared.
:::

::: siguiente
Some products expire, others are on offer and others both. A child class for each combination?
:::

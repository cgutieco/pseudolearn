---
id: objetos.invariantes
numero: "3.2"
tipo: leccion
titulo: Protecting what must be true
duracion: 35
problema_breve: The card with a negative balance
necesita: [objetos.cosas]
introduce: [encapsulamiento, invariante-de-clase]
usa: [clase, objeto, atributo, metodo, constructor, invariante, visibilidad, validar, caso-borde]
---

::: frase
A well-made object does not let anyone put it in an impossible state.
:::

## The problem {#problema}

::: problema
The canteen card has a **balance** that anyone can change from outside. A program charged **50 pesos** to a card with **30** and left the balance at **-20**. Another one loaded **-100** onto it.

**How is the card written so that this cannot happen, whoever uses it?**
:::

## Try it {#intentalo}

::: intento
Write in one sentence what always has to be true of a canteen card.
:::

::: respuesta
The balance is never negative. Also, loading and charging only make sense with positive amounts.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** Requests to charge and to load go in; whether it worked, and the balance, come out.
- **What does it look like?** The checks of [lesson 2.6](ruta:procedimental.fallos), but now they live inside the object.
- **Who has the information to do this?** The card: it knows its balance, so it is the only one that can decide whether a charge is enough.

## The new tool {#herramienta}

::: recuerda termino=invariante
:::

What has to be true of every object of a class, before and after each method, is a [[def:invariante-de-clase|class invariant]]. For the card: the balance is never negative.

To protect it you have to [[def:encapsulamiento|encapsulate]]: hide the attributes, marking them `Private`, and let only the methods change them. Each method checks the invariant before touching anything.

```figura id=ruta-caja-fuerte
pie: The attributes stay inside; the methods are windows that decide what goes in and what comes out.
```

::: recuerda termino=visibilidad
:::

::: especificacion
- objetos.clase
- objetos.metodos
:::

## Write {#escribir fase=3}

```programa id=tarjeta titulo="The card that looks after itself" ejecutar
```

```salida
false 30
false 30
true 0
```

The charge of 50 is rejected and changes nothing; so is the load of -100. The charge of exactly 30 is accepted and leaves the balance at 0, which still meets the invariant.

## Test {#probar fase=4}

| Request | Balance before | Expected | Why |
|---|---|---|---|
| Charge 30 | 30 | true, 0 left | edge: just enough |
| Charge 31 | 30 | false, 30 left | edge: one short |
| Load 0 | 30 | false, 30 left | an amount that is not positive |
| Load -5 | 30 | false, 30 left | a negative amount |

## Improve {#mejorar fase=5}

In one sentence: «The card keeps its balance private and only changes it with charges and loads that keep the balance free of negatives».

Compare it with the public attribute version: there the rule had to be repeated in every program that used the card, and one that forgot it was enough. Now it lives in a single place.

## What you learned {#aprendiste}

::: resumen
- {encapsulamiento} Encapsulating is hiding the attributes and letting only the methods change them.
- {invariante-de-clase} A class invariant is what has to be true of every object before and after each method.
:::

## Practise {#practica}

::: practica
- objetos.invariantes.tarjeta-negativa
- objetos.invariantes.no-alcanza
- objetos.invariantes.atributo-privado
- objetos.invariantes.tarjeta-pruebas
- objetos.invariantes.termostato
- objetos.invariantes.invariantes-ascensor
:::

::: docentes
- **«Private is for hiding errors».** It is so that nobody can break the invariant from outside.
- **Checking outside instead of in the method.** It works until someone uses the card from another program.
- **A public method to set each attribute.** With a method that sets any balance, the protection disappears.
:::

::: siguiente
I copied an order to put together a similar one, added a biscuit to the copy and the original has it too. What happened?
:::

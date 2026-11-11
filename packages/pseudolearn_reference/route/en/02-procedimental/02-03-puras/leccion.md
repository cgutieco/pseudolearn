---
id: procedimental.puras
numero: "2.3"
tipo: leccion
titulo: Functions that touch nothing
duracion: 30
problema_breve: A price that cannot be added up
necesita: [procedimental.ambito]
introduce: [efecto, funcion-pura]
usa: [subprograma, parametro, valor-de-retorno, paso-por-referencia, caso-de-prueba, diagnostico]
---

::: frase
A pure function only receives data and gives back a result: it does not ask, does not show and does not change anything outside.
:::

## The problem {#problema}

::: problema
The kiosk has a piece of program, `FinalPrice`, that **asks** for the discount, applies it and **shows** the price. Now the final price of **three products** has to be added up. Each call asks for the discount again, the screen fills up with messages and the result cannot be added.

**How is it written so that it can be used in any calculation and tested with a table?**
:::

## Try it {#intentalo}

::: intento
In this subprogram, mark which lines ask, which ones show and which ones compute.

```programa id=precio-final-mezclado titulo="A subprogram that does everything"
SubProceso FinalPrice(price Como Entero)
  Definir percent Como Entero;
  Escribir "What discount?";
  Leer percent;
  Escribir price * (100 - percent) div 100;
FinSubProceso
```
:::

::: respuesta
It asks in the lines of the message's `Write` and of the `Read`. It shows in the last `Write`. It computes only inside that last `Write`: the calculation is mixed with what it shows. To add up three prices, the calculation would have to give back a number instead of showing it.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The price and the discount percentage go in; the discounted price comes out.
- **What does it look like?** Like `Average` in the report card of [lesson 2.1](ruta:procedimental.dividir): it receives data and returns a number.
- **Which parts does it split into?** A piece that only computes, and another, the main algorithm, that asks and shows.

## The new tool {#herramienta}

An [[def:efecto|effect]] is something a subprogram does besides giving back a result: reading, showing or changing something outside, like a lent box. A [[def:funcion-pura|pure function]] has no effects: with the same data it always gives back the same.

```figura id=ruta-maquina-pura
pie: The pure machine has a single input and a single output. The other one has side doors through which things go in and out that you cannot see in the call.
```

In PseudoLearn, a `Function` has to be pure, and the engine checks it. It is written with the name of the result box before the name of the function, and it gives back whatever that box holds at the end:

```programa id=cuadrado titulo="The square" ejecutar
Funcion r <- Square(x Como Entero)
  Definir r Como Entero;
  r <- x * x;
FinFuncion

Algoritmo Main
  Escribir Square(3) + Square(4);
FinAlgoritmo
```

```salida
25
```

If a `Function` tries to show something, the program does not even start:

```programa id=funcion-que-muestra titulo="A function that shows" ejecutar
Funcion r <- Square(x Como Entero)
  Definir r Como Entero;
  Escribir "computing";
  r <- x * x;
FinFuncion

Algoritmo Main
  Escribir Square(3);
FinAlgoritmo
```

```diagnosticos
pureFunctionSideEffect
```

```figura-especificacion seccion=subprogramas.pureza figura=pureza-grafo
```

::: especificacion
- subprogramas.pureza
:::

## Write {#escribir fase=3}

```programa id=precio-final-puro titulo="The discounted price, pure" ejecutar
Funcion finalPrice <- WithDiscount(price Como Entero, percent Como Entero)
  Definir finalPrice Como Entero;
  finalPrice <- price * (100 - percent) div 100;
FinFuncion

Algoritmo Kiosk
  Definir percent, price Como Entero;
  Definir total Como Entero <- 0;
  Escribir "What discount?";
  Leer percent;
  Para i <- 1 Hasta 3 Hacer
    Leer price;
    total <- total + WithDiscount(price, percent);
  FinPara
  Escribir "Total: ", total;
FinAlgoritmo
```

```entrada
10
30
50
20
```

```salida
What discount?
Total: 90
```

The discount is asked only once, in the main algorithm. `WithDiscount` only computes, so its result can be added up.

## Test {#probar fase=4}

A pure function is tested without preparing anything: calling it with data and comparing is enough.

```programa id=probar-descuento titulo="A table of cases" ejecutar
Funcion finalPrice <- WithDiscount(price Como Entero, percent Como Entero)
  Definir finalPrice Como Entero;
  finalPrice <- price * (100 - percent) div 100;
FinFuncion

Algoritmo Tests
  Escribir WithDiscount(100, 10);
  Escribir WithDiscount(100, 0);
  Escribir WithDiscount(100, 100);
  Escribir WithDiscount(15, 10);
FinAlgoritmo
```

```salida
90
100
0
13
```

| Price | Discount | Expected | Why |
|---|---|---|---|
| 100 | 10 | 90 | normal case |
| 100 | 0 | 100 | edge: no discount |
| 100 | 100 | 0 | edge: all free |
| 15 | 10 | 13 | the result is rounded down |

## Improve {#mejorar fase=5}

In one sentence: «`WithDiscount` computes the discounted price without asking or showing anything».

The same calculation now serves the receipt and the day's summary without changes: whoever calls decides where the data comes from and what to do with the result.

## What you learned {#aprendiste}

::: resumen
- {efecto} An effect is reading, showing or changing something outside the subprogram.
- {funcion-pura} A pure function has no effects: with the same data it always gives back the same, and the engine checks it.
:::

## Practise {#practica}

::: practica
- procedimental.puras.puro-o-no
- procedimental.puras.suma-cuadrados
- procedimental.puras.funcion-que-escribe
- procedimental.puras.separar
- procedimental.puras.es-bisiesto
- procedimental.puras.por-que-pura
:::

::: profundizar titulo="Common pitfalls"
- **«Pure means without variables».** `WithDiscount` declares a box and is pure: what matters is that it has no effects.
- **Showing something inside «to see what happens».** The engine rejects it. To look at a value, show it from whoever calls.
- **Confusing pure with short.** A long function can be pure, and a one-line one can have an effect.
:::

::: siguiente
To move a tower of discs from one post to another you first have to move a smaller tower. Can a subprogram use itself?
:::

---
id: inicio.preguntar
numero: "0.3"
tipo: leccion
titulo: Ask before computing
duracion: 20
problema_breve: Splitting the bill at the canteen
necesita: [inicio.nombres]
introduce: [entrada, leer-dato, ficha-del-problema]
usa: [variable, declarar, ejemplo-a-mano, salida, funcion-ya-hecha]
---

::: frase
A useful program does not carry its data written inside: it asks for it every time it runs.
:::

## The problem {#problema}

::: problema
A group of friends eats at the canteen. A **10 %** tip is added to the bill and it is split in equal parts. Since nobody carries coins, each one pays a **whole** number of pesos, rounding up so that it is enough. The bill and the number of friends change every time.

**How much does each one pay?**
:::

## Try it {#intentalo}

::: intento
Work out by hand how much each one pays if the bill is 120 pesos and there are 4 friends.
:::

::: respuesta
The tip is a tenth of 120: 12. The total is 132. Among 4 friends, each one pays **33**.
:::

## Understand {#entender fase=1}

This time the person who writes the program does not know the data: the person who uses it knows them, at the canteen. Before thinking about instructions it pays to write the problem on a [[def:ficha-del-problema|problem card]]: what goes in, what comes out, how they relate and several worked examples.

```figura id=ruta-ficha
pie: The card is filled in before writing. If you cannot fill in a zone, you have not understood the problem yet.
```

::: ficha
- entra: the bill, in whole pesos, and the number of friends.
- sale: what each one pays.
- relacion: the total is the bill plus a tenth of it; each one pays the total divided among the friends, rounded up.
- ejemplo: 120 and 4 → total 132 → 33.
- ejemplo: 100 and 3 → total 110 → 36.67 → 37.
- ejemplo: 100 and 1 → total 110 → 110.
:::

The tip is computed as `bill div 10`, so as to always work with whole numbers.

::: profundizar titulo="Why not multiply by 1.1?"
Numbers with decimals are stored in the computer approximately, and `100 * 1.1` may give a value slightly different from 110. With whole numbers that does not happen. The full explanation is in [the Specification](especificacion:tipos.primitivos).
:::

## Plan {#planear fase=2}

1. Ask for the bill.
2. Ask how many friends pay.
3. Compute the total with the tip.
4. Divide among the friends and round up.
5. Show the result.

## The new tool {#herramienta}

The [[def:entrada|input]] of a program is the data it receives while it runs. `Read` is used to [[def:leer-dato|read a value]]: it stops the program until someone types a value and stores it in a box that is already declared.

```figura-especificacion seccion=biblioteca.consola figura=leer-escribir
```

```programa id=saludo titulo="A greeting" ejecutar
Algoritmo Greeting
  Definir name Como Cadena;
  Escribir "What is your name?";
  Leer name;
  Escribir "Hello, ", name;
FinAlgoritmo
```

```entrada
Lucía
```

```salida
What is your name?
Hello, Lucía
```

`Read` shows nothing: that is why, before each `Read`, a `Write` tells the person what to type.

::: especificacion
- biblioteca.consola
:::

## Write {#escribir fase=3}

```programa id=propina titulo="Splitting the bill" ejecutar
Algoritmo Tip
  Definir bill Como Entero;
  Definir friends Como Entero;
  Escribir "How much is the bill?";
  Leer bill;
  Escribir "How many friends are paying?";
  Leer friends;
  Definir total Como Entero <- bill + bill div 10;
  Escribir "Each one pays: ", techo(total / friends);
FinAlgoritmo
```

```entrada
120
4
```

```salida
How much is the bill?
How many friends are paying?
Each one pays: 33
```

## Test {#probar fase=4}

| Bill | Friends | By hand | The program |
|---|---|---|---|
| 120 | 4 | 33 | 33 |
| 100 | 3 | 37 | 37 |
| 100 | 1 | 110 | 110 |

Look at the second one: three friends pay 37 each, 111 in total, one peso more than the bill. Rounding up always leaves a bit extra, and that is exactly what the problem asked for.

## Improve {#mejorar fase=5}

In one sentence: «The program asks for the bill and the friends, and says how much each one pays with the tip included».

An awkward question remains: what if someone types 0 friends? Do not run it yet; it is the problem of the next lesson.

## What you learned {#aprendiste}

::: resumen
- {entrada,leer-dato} When reading a value, the program stops until someone types a value, and stores it in a variable.
- {ficha-del-problema} The problem card writes down what goes in, what comes out, how they relate and worked examples.
:::

## Practise {#practica}

::: practica
- inicio.preguntar.orden-inverso
- inicio.preguntar.en-2030
- inicio.preguntar.ficha-vuelto
- inicio.preguntar.vuelto
- inicio.preguntar.bici
- inicio.preguntar.que-calcula
:::

::: profundizar titulo="Common pitfalls"
- **A value of the wrong type.** Answering «twelve» when an `Integer` is expected stops the program. Try it once and link it to the types of the previous lesson.
- **Forgetting to read the value.** The box is declared but, without `Read`, it never receives the value: the program computes with its initial value.
- **Believing that reading shows something.** `Read` shows nothing; the message is written by the `Write` before it.
:::

::: siguiente
Your classmate tried the tip calculator with 0 friends and something went very wrong. What kinds of failures exist and how do you find them before someone else does?
:::

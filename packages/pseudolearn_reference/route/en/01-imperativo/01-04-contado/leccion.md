---
id: imperativo.contado
numero: "1.4"
tipo: leccion
titulo: Repeat a known number of times
duracion: 30
problema_breve: Is this number prime?
necesita: [imperativo.mientras]
introduce: [bucle-contado, bucle-posterior, bandera, mejor-hasta-ahora, salida-anticipada]
usa: [bucle, vuelta, rol-de-variable, contador, acumulador, valor-logico, caso-borde, tabla-por-vuelta]
---

::: frase
Choosing the loop is answering two questions: do I know how many passes there will be? Does the first pass always happen?
:::

## The problem {#problema}

::: problema
The maths club wants a program that says whether a number is **prime**: a number greater than 1 that can only be divided exactly by 1 and by itself.

**How does the program find out?**
:::

## Try it {#intentalo}

::: intento
Decide by hand whether 7, 9, 2 and 1 are prime.
:::

::: respuesta
7 yes. 9 no: 9 = 3 × 3. 2 yes: it is the only even prime. 1 no: by definition, a prime has to be greater than 1.
:::

## Understand {#entender fase=1}

::: ficha
- entra: a whole number.
- sale: «Es primo» (it is prime) or «No es primo».
- relacion: it is prime if it is greater than 1 and no number from 2 to the one before it divides it exactly.
- ejemplo: 7 → prime.
- ejemplo: 9 → not prime (3 divides it).
- ejemplo: 2 → prime (there are no divisors to try).
- ejemplo: 1 → not prime (it is not greater than 1).
:::

2 and 1 are the edge cases: with 2 there is no divisor to try, and 1 is left out by the definition.

## Plan {#planear fase=2}

1. Try each possible divisor, from 2 to the number before.
2. If any divides exactly, the number is not prime.

You have to remember whether any divided exactly, and that box has a new role:

::: roles
- flag | ruta-rol-bandera | Starts at a boolean value and changes only once, when something happens: that is how it remembers it happened.
:::

A [[def:bandera|flag]] starts, for example, at «is prime» and goes down the first time a divisor appears. Once down, it never goes back up.

This time you know beforehand how many passes there will be: one for each possible divisor. That changes which loop suits.

## The new tool {#herramienta}

A [[def:bucle-contado|counted loop]] is used when you know how many passes there will be. `For` carries its own counter, which starts at one value and moves up to another:

```figura-especificacion seccion=control.para figura=para-contador
```

```programa id=tabla-del-7 titulo="The 7 times table" ejecutar
```

```salida
7
14
21
```

A [[def:bucle-posterior|loop that checks at the end]] always makes at least one pass: `Repeat` runs its body and only then asks `Until`. It is useful, for example, to ask for a value until it is valid:

```figura-especificacion seccion=control.repetir figura=repetir-ciclo
```

```programa id=uno-a-diez titulo="A number from 1 to 10" ejecutar
```

```entrada
0
15
7
```

```salida
Aceptado: 7
```

Two questions are enough to choose among the three loops:

```figura id=ruta-elegir-bucle
pie: First, do I know how many passes? Then, does the first pass always happen?
```

With counted loops another very common role appears: the [[def:mejor-hasta-ahora|best so far]], which keeps the highest (or lowest) value seen up to that moment.

::: roles
- best so far | ruta-rol-mejor-hasta-ahora | Keeps the highest value seen; when a greater one arrives, it replaces it. It starts with the first value.
:::

```programa id=maxima titulo="The week's maximum" ejecutar
```

```entrada
20
23
19
25
22
```

```salida
Máxima: 25
```

Finally, sometimes you already know the answer before finishing the passes. An [[def:salida-anticipada|early exit]] with `Exit` cuts the loop at that moment:

```figura-especificacion seccion=control.salir figura=salir-corte
```

::: especificacion
- control.para
- control.repetir
- control.salir
:::

## Write {#escribir fase=3}

```programa id=primo titulo="Is it prime?" ejecutar
```

```entrada
9
```

```salida
No es primo
```

The flag starts at `n >= 2`: that way 1, 0 and the negatives already start as not prime. With 2, the loop goes from 2 to 1 and makes zero passes: the flag stays true, which is right.

## Test {#probar fase=4}

| Number | By hand | The program | Passes |
|---|---|---|---|
| 7 | prime | Es primo | 5 |
| 9 | no | No es primo | 2 |
| 2 | prime | Es primo | 0 |
| 1 | no | No es primo | 0 |

With 97, which is prime, the loop tries the 95 divisors from 2 to 96. Keep that number: in the strategies lesson you will improve it.

## Improve {#mejorar fase=5}

In one sentence: «The program tries the divisors one by one and stops at the first one that divides exactly».

Without `Exit`, 9 would make the 7 passes even though from the second one the answer is known. With `Exit` it makes 2. With large numbers, the difference shows.

## What you learned {#aprendiste}

::: resumen
- {bucle-contado} A counted loop is used when you know how many passes there will be.
- {bucle-posterior} A loop that checks at the end always makes at least one pass.
- {bandera} A flag is a boolean value that changes only once to remember that something happened.
- {mejor-hasta-ahora} The best so far keeps the highest (or lowest) value seen; it starts with the first value.
- {salida-anticipada} An early exit cuts the loop when the answer is already known.
:::

## Practise {#practica}

::: practica
- imperativo.contado.suma-cinco
- imperativo.contado.hay-par
- imperativo.contado.primo-romper
- imperativo.contado.nota-mas-alta
- imperativo.contado.que-bucle
- imperativo.contado.uno-a-diez-resolver
- imperativo.contado.suma-digitos
:::

::: profundizar titulo="Common pitfalls"
- **The maximum that starts at 0.** It works with summer temperatures and fails with negative data. Try it with -3, -5 and -1.
- **The flag that changes again on every pass.** Assigning it the result of the division on every pass leaves only the answer for the last divisor. The pass table shows it.
- **Using a counted loop when you do not know how many passes there will be.** Answer the two questions of the figure before writing.
:::

::: siguiente
To know which days were hotter than the average, you first need the average, and by then the data has gone. Where do you keep many values?
:::

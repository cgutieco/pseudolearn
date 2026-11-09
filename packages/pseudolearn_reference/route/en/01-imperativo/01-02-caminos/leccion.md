---
id: imperativo.caminos
numero: "1.2"
tipo: leccion
titulo: Many paths
duracion: 30
problema_breve: Is this a leap year?
necesita: [imperativo.decidir]
introduce: [condicion-compuesta, tabla-de-decision, seleccion-multiple, anidar]
usa: [condicion, decision, particion-de-casos, caso-borde, comparacion]
---

::: frase
When there are many cases, a decision table puts the questions in order before you write the first one.
:::

## The problem {#problema}

::: problema
A year is a leap year if it divides exactly by **4**, unless it also divides by **100**; but those that divide exactly by **400** are leap years.

**How does a program know whether a year is a leap year?**
:::

## Try it {#intentalo}

::: intento
Decide by hand whether 2024, 2023, 1900 and 2000 are leap years.
:::

::: respuesta
2024 yes (it divides by 4 and not by 100). 2023 no. 1900 no: it divides by 4 and by 100, but not by 400. 2000 yes: it divides by 400.
:::

## Understand {#entender fase=1}

::: ficha
- entra: the year.
- sale: «Es bisiesto» (it is a leap year) or «No es bisiesto» (it is not).
- relacion: the rule in the statement, with its two exceptions.
- ejemplo: 2024 → leap year.
- ejemplo: 2023 → not a leap year.
- ejemplo: 1900 → not a leap year (the exception of 100).
- ejemplo: 2000 → leap year (the exception of 400).
:::

The four years are a partition: each one falls in a different region of the rule. 1900 and 2000 are the edges of the exceptions, and they are the ones a hasty solution forgets.

## Plan {#planear fase=2}

There are three questions: does it divide by 4? by 100? by 400? Before writing, it pays to put them in a [[def:tabla-de-decision|decision table]]: one row per question, one column per case and, at the bottom, the result.

```figura id=ruta-tabla-decision-bisiesto
pie: Each column is a worked example. The table shows which questions change the result.
```

The order of the questions matters. If you ask «does it divide by 4?» first and answer straight away, 1900 comes out wrong. You have to start with the most specific question.

```figura id=ruta-orden-preguntas
pie: The questions go from the most specific to the most general.
paso: In the wrong order, 1900 goes in through «does it divide by 4?» and comes out as a leap year.
paso: In the right order, 1900 goes through «by 400?» and «by 100?» and comes out as not a leap year.
```

## The new tool {#herramienta}

A [[def:condicion-compuesta|compound condition]] combines several conditions into one with `And`, `Or` and `Not`. `a And b` is true if both are; `a Or b`, if at least one is; `Not a`, if `a` is false.

```figura-especificacion seccion=expresiones.logicos figura=cortocircuito
```

You can also [[def:anidar|nest]]: put a decision inside a branch of another. And when you have to choose among many possible values of the same piece of data, a [[def:seleccion-multiple|multiple selection]] with `Switch` avoids a staircase of `If`:

```figura-especificacion seccion=control.segun figura=segun-ramas
```

```programa id=menu titulo="The kiosk menu" ejecutar
```

```entrada
2
```

```salida
Sándwich 5
```

::: especificacion
- expresiones.logicos
- expresiones.precedencia
- control.segun
- control.si
:::

## Write {#escribir fase=3}

Two solutions. The first nests three decisions in the order of the table: 400, 100, 4.

```programa id=bisiesto-anidado titulo="Leap year, with nested decisions" ejecutar
```

```entrada
1900
```

```salida
No es bisiesto
```

The second states the rule in a single compound condition:

```programa id=bisiesto-compuesto titulo="Leap year, with a compound condition" ejecutar
```

```entrada
2000
```

```salida
Es bisiesto
```

## Test {#probar fase=4}

| Year | By hand | Nested | Compound |
|---|---|---|---|
| 2024 | yes | Es bisiesto | Es bisiesto |
| 2023 | no | No es bisiesto | No es bisiesto |
| 1900 | no | No es bisiesto | No es bisiesto |
| 2000 | yes | Es bisiesto | Es bisiesto |

The brackets in the compound version are not decoration: `And` and `Or` have an order of their own, and without brackets the condition groups something else. The rule is in [the Specification](especificacion:expresiones.precedencia).

## Improve {#mejorar fase=5}

In one sentence: «The program applies the leap year rule by asking from the most specific exception to the general rule».

Back to the cinema of [the previous lesson](ruta:imperativo.decidir): on Thursdays everyone pays 4. The program reads the day (from 1 to 7; 4 is Thursday) and the age. There are two possible orders for the questions:

| Case | Day 4, age 10 | Day 4, age 30 | Day 2, age 10 | Day 2, age 30 |
|---|---|---|---|---|
| Thursday first | 4 | 4 | 5 | 8 |
| Age first | 5 | 4 | 5 | 8 |

If you ask the age first, the 10-year-old pays 5 on a Thursday. The order «Thursday first» wins.

```programa id=cine-jueves titulo="The cinema with Thursdays" ejecutar
```

```entrada
4
10
```

```salida
Paga 4
```

## What you learned {#aprendiste}

::: resumen
- {condicion-compuesta} `And`, `Or` and `Not` combine conditions into one.
- {tabla-de-decision} A decision table puts each condition in a row and each case in a column, before writing.
- {anidar} Nesting is putting a decision inside another; the order of the questions matters.
- {seleccion-multiple} Multiple selection chooses among many possible values of the same piece of data.
:::

## Practise {#practica}

::: practica
- imperativo.caminos.compuesta
- imperativo.caminos.menu-kiosco
- imperativo.caminos.bisiesto-romper
- imperativo.caminos.triangulo
- imperativo.caminos.bisiesto-ordenar
- imperativo.caminos.descuentos
:::

::: profundizar titulo="Common pitfalls"
- **«One or the other, but not both».** The opposite happens: `a Or b` is also true when both are. Try it with `True Or True`.
- **Forgetting the brackets.** Try the compound version without brackets and look for a year that breaks it.
- **The general condition before the specific one.** The figure of the two orders shows it with 1900.
:::

::: siguiente
Lucía is saving for a ball and does not know how many days it will take. How do you repeat something without knowing how many times?
:::

---
id: inicio.errores
numero: "0.4"
tipo: leccion
titulo: When something goes wrong
duracion: 25
problema_breve: Three tip calculators that fail
necesita: [inicio.preguntar]
introduce: [error-de-compilacion, error-de-ejecucion, error-de-logica, diagnostico, caso-de-prueba, caso-borde]
usa: [entrada, ficha-del-problema, ejemplo-a-mano, programa, ejecutar]
---

::: frase
A program can fail in three ways, and the most dangerous one gives no warning at all.
:::

## The problem {#problema}

::: problema
Your classmate wrote three versions of the tip calculator. The engine does not even accept the first one. The second works until someone types **0 friends**. The third always shows a number, but with a bill of **120** and **4 friends** it says each one pays **3**.

**What is wrong with each one, and how would you have found out?**
:::

## Try it {#intentalo}

::: intento
Read the three versions shown further down, under «Write», before running them. Note what you suspect about each one.
:::

::: respuesta
The first is missing a semicolon at the end of a line. The second divides by the number of friends, and dividing by 0 has no answer. The third computes only the tip, `cuenta div 10`, and forgot to add the bill: 12 divided by 4 gives 3.
:::

## Understand {#entender fase=1}

What is asked is not a new program. It is to classify the failures and find a method to discover them before someone else does.

## Plan {#planear fase=2}

For each version, three questions in order:

1. Does the engine accept it?
2. Does it finish, or does it stop on the way?
3. Does what it shows match the worked example?

## The new tool {#herramienta}

Each question of the plan uncovers a different kind of failure.

- A [[def:error-de-compilacion|compile error]] is a text the engine cannot understand: the program never gets to start.
- A [[def:error-de-ejecucion|runtime error]] appears on the way: the program starts, but stops at an instruction it cannot carry out.
- A [[def:error-de-logica|logic error]] stops nothing: the program finishes and shows a wrong result. The engine cannot see it, because it did exactly what the text says.

```figura id=ruta-tres-errores
pie: The engine reports the first two. Only you discover the third one, by comparing with your examples.
paso: The bus does not start: a compile error. The engine reports it before starting.
paso: The bus breaks down on the way: a runtime error. The engine reports it when it happens.
paso: The bus arrives, but in another town: a logic error. Nobody warns you.
```

When the engine finds an error, it writes a [[def:diagnostico|diagnostic]]: it says where the problem is (line and column), with a code and a message.

```figura-especificacion seccion=diagnosticos.anatomia figura=anatomia-diagnostico
```

::: especificacion
- vision.errores
- diagnosticos.anatomia
- vision.terminacion
:::

## Write {#escribir fase=3}

There is no new solution: the three versions are run.

```programa id=propina-a titulo="Version A" ejecutar
```

```diagnosticos
missingStatementTerminator
```

The diagnostic points at line 6, where the semicolon is missing, and the program never gets to ask anything.

```programa id=propina-b titulo="Version B, with 0 friends" ejecutar termina=failed
```

```entrada
100
0
```

```salida
¿Cuánto es la cuenta?
¿Cuántos amigos pagan?
```

```diagnosticos
divisionByZero
```

Version B starts well: it asks for both values. It stops at the last instruction, when dividing by 0.

```programa id=propina-c titulo="Version C" ejecutar
```

```entrada
120
4
```

```salida
¿Cuánto es la cuenta?
¿Cuántos amigos pagan?
Cada uno paga: 3
```

Version C finishes without complaining. If you did not have the worked example (33), you would accept the 3.

## Test {#probar fase=4}

A [[def:caso-de-prueba|test case]] is an input with the output you expect, taken from a worked example. Choosing them well is a craft: the most useful ones are the [[def:caso-borde|edge cases]], which sit right on the limit where a hasty program gets it wrong.

```figura id=ruta-recta-casos
pie: One case from each zone: the normal one uncovers logic errors; the edge and the odd one, those waiting at the borders.
```

| Case | Bill and friends | Expected | Version B | Version C |
|---|---|---|---|---|
| Normal | 120 and 4 | 33 | 33 | 3 ✗ |
| Edge | 100 and 1 | 110 | 110 | 10 ✗ |
| Odd | 100 and 0 | a warning | stops ✗ | stops ✗ |

The normal case uncovers version C. The odd one uncovers B, and C too.

## Improve {#mejorar fase=5}

In one sentence: «Before accepting a program, I test it with a normal case, an edge case and an odd one, and compare with my worked examples».

The odd case has no fix yet: to warn «nobody is paying» instead of stopping, the program would have to decide. It stays open.

## What you learned {#aprendiste}

::: resumen
- {error-de-compilacion,error-de-ejecucion,error-de-logica} A compile error stops the program from starting; a runtime error stops it on the way; a logic error gives a wrong result without warning.
- {diagnostico} A diagnostic says where the problem is, with a code and a message.
- {caso-de-prueba,caso-borde} A test case is an input with its expected output; an edge case sits right on the limit where a hasty program gets it wrong.
:::

## Practise {#practica}

::: practica
- inicio.errores.tres-cajones
- inicio.errores.se-detiene
- inicio.errores.promedio-dos
- inicio.errores.buses-romper
- inicio.errores.buses-pruebas
- inicio.errores.donde-arreglo
:::

::: docentes
- **«If it compiles, it is right».** Version C compiles and finishes. Ask them to test it before showing the worked example.
- **«The error is on the line the engine points at».** Sometimes it is just before: in version A, the semicolon is missing at the end of line 6.
- **Testing only with the example in the statement.** Always ask for an edge case and an odd one.
:::

::: siguiente
Until now every program always does the same thing. What if, depending on the data, it has to do different things, such as warning that you cannot divide among 0 friends?
:::

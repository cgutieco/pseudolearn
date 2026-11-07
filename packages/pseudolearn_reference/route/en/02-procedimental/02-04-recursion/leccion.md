---
id: procedimental.recursion
numero: "2.4"
tipo: leccion
titulo: Problems that contain themselves
duracion: 35
problema_breve: The tower of Hanoi
necesita: [procedimental.puras]
introduce: [recursion, caso-base, caso-recursivo]
usa: [subprograma, llamada, parametro, pila-de-llamadas, marco, funcion-pura, bucle, costo]
---

::: frase
A recursive subprogram solves a problem by asking itself for a smaller version, until it reaches one it already knows how to solve.
:::

## The problem {#problema}

::: problema
The tower of Hanoi: **three discs** of different sizes are stacked on post **A**, from the biggest at the bottom to the smallest at the top. They have to go to post **C**, moving **one disc at a time** and never putting a big disc on a small one. Post **B** helps.

**Which moves do you have to make, and how many are there?**
:::

## Try it {#intentalo}

::: intento
Solve it with three coins of different sizes on three pieces of paper marked A, B and C.
:::

::: respuesta
There are **7** moves: small from A to C, middle from A to B, small from C to B, big from A to C, small from B to A, middle from B to C and small from A to C.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The number of discs goes in; the moves come out, in order.
- **What does it look like?** Itself. To move 3 discs from A to C you first have to move the top 2 to B, and that is the same problem with one disc less.
- **Which parts does it split into?** It splits into three: move 2 discs from A to B, move the big one from A to C and move the 2 from B to C. Moving a single disc is direct.

```figura id=ruta-hanoi
pie: To move the tower of three, a tower of two is first moved out of the way.
paso: The small disc goes from A to C.
paso: The middle one goes from A to B.
paso: The small one goes from C to B: the tower of two is on B.
paso: The big one goes from A to C.
paso: The small one goes from B to A.
paso: The middle one goes from B to C.
paso: The small one goes from A to C: the whole tower is on C.
```

## The new tool {#herramienta}

A subprogram that calls itself uses [[def:recursion|recursion]]. It has two parts: the [[def:caso-base|base case]], solved without calling itself, and the [[def:caso-recursivo|recursive case]], which calls itself with a smaller problem and has to get closer to the base case.

```figura id=ruta-munecas
pie: Each doll holds a smaller one, down to the last, which no longer opens: it is the base case.
paso: The big doll is opened: inside there is a smaller one.
paso: The next one is opened: another smaller one.
paso: The smallest does not open: it is the base case.
paso: They close from the inside out, with the result.
```

```programa id=factorial titulo="The factorial" ejecutar
```

```salida
120
```

Each call opens its own frame on the stack, and the frames close from the top down when the base case gives back its result:

```figura-especificacion seccion=subprogramas.recursion figura=recursion-pila
```

::: especificacion
- subprogramas.recursion
- motor.limites
:::

## Write {#escribir fase=3}

```programa id=hanoi titulo="The tower of Hanoi" ejecutar
```

```salida
Mover disco 1 de A a C
Mover disco 2 de A a B
Mover disco 1 de C a B
Mover disco 3 de A a C
Mover disco 1 de B a A
Mover disco 2 de B a C
Mover disco 1 de A a C
```

The base case is a tower of 0 discs: there is nothing to move. The recursive case moves a tower of `n - 1` discs, which gets closer to the base case with each call.

## Test {#probar fase=4}

With 1 disc there is a single move; with 0, none: it is the edge case the base case solves. Counting moves:

| Discs | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Moves | 1 | 3 | 7 | 15 | 31 |

Each extra disc doubles the moves and adds one.

## Improve {#mejorar fase=5}

In one sentence: «To move a tower, the top tower is moved out of the way, the big disc is moved and the top tower is put back on top».

The cost grows fast: with 20 discs there are more than a million moves. Recursion is not always the best option: the factorial does not branch, and a loop solves it just as clearly without opening a frame for each number.

## What you learned {#aprendiste}

::: resumen
- {recursion} A recursive subprogram calls itself with a smaller problem.
- {caso-base,caso-recursivo} The base case is solved without calling itself; the recursive case has to get closer to it.
:::

## Practise {#practica}

::: practica
- procedimental.recursion.factorial-4
- procedimental.recursion.suma-sin-fin
- procedimental.recursion.potencia
- procedimental.recursion.cifras
- procedimental.recursion.fibonacci
- procedimental.recursion.munecas
:::

::: docentes
- **Forgetting the base case.** The program calls itself endlessly until the engine stops it by depth. The find-the-error exercise shows it.
- **A recursive case that does not shrink.** Ask them to say, for each call, which number gets closer to zero.
- **«Recursion is always better».** Hanoi needs it; the factorial does not. Compare both versions.
:::

::: siguiente
The contacts of the group have a name, a phone number and a birthday month. How do you keep something that has several parts?
:::

:::parte pregunta

Before writing a single keyword, it is worth asking what an algorithm actually is, because "some
instructions that solve the problem" is not enough of an answer: a recipe is also instructions, and a
badly written recipe gets followed two different ways by two different people. An algorithm does not
allow that. This module does not teach syntax yet: it teaches what has to be true of a sequence of
steps for it to deserve the name algorithm.

:::parte modelo-maquina

An algorithm is a **finite**, **precise** and **unambiguous** sequence of steps that begins at a
declared point and ends after a determined number of steps. Every word in that sentence rules
something out: finite rules out "repeat forever with no exit condition"; precise rules out a step that
two people could read two different ways; unambiguous rules out a result that depends on the order in
which someone chooses to read the steps. The order the steps are written in **is** the order they
happen in. There is no second possible order, and that is the difference between an algorithm and a
list of suggestions.

:::parte desarrollo

## What makes a sequence precise

Three conditions, and all three can be checked by reading the text without running it:

1. **Each step has a single meaning.** "Compute the total" is not a step: it does not say with which
   data or with which operation. "Add the price and the tax" is.
2. **The next step is always determined.** You never have to guess which one comes next; you read from
   top to bottom and there is no alternative until the text itself declares one.
3. **It starts and ends at a marked point.** An algorithm with no declared start or end is not an
   incomplete algorithm: it is not an algorithm, because there is no way to say where to begin or when
   to stop.

{{ejemplo:example-a1-vuelto}}

That program meets the three conditions: each step does exactly one thing, the order they appear in is
the order they happen in, and the `algorithm` / `endAlgorithm` frame declares, without ambiguity, where
it starts and where it ends.

## Order is not a matter of style

{{ejemplo:example-a1-promedio}}

The average of `n1`, `n2` and `n3` cannot be computed before the full sum exists. Writing the division
line before the sum line would not be a stylistic variant: it would be a different algorithm, and
probably one that cannot even run yet, because `sum` would not have the value the division needs. The
order things are written in and the order they run in are the same thing.

:::parte prediccion

Before looking at the result, decide in which order the three things in the **Average of three grades**
example are computed: the sum of the three grades, the division by three, and the writing of the
result. Write it down as a numbered list on paper. Then compare your list with the real order of the
they have to match exactly, because in an algorithm there is no order other than the one the text
declares.

:::parte errores-frecuentes

## Starting without declaring where the algorithm starts

An algorithm needs its frame. Without the word that opens it, there is no way to tell whether what
follows is part of an algorithm or a loose instruction outside any program.

```pseudo
define n as integer;
n <- 5;
write n;
```

{{diagnostico:expectedAlgorithmStart}}

:::parte especificacion

- esp-i-lexico How a program's start and end are recognised

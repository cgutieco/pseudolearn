:::parte pregunta

So far every program does exactly the same steps no matter what data it receives. That is not enough
for almost anything useful: passing or not depends on the grade, and the right message depends on
which day it is. This module introduces the two ways of branching the path a program follows based on
what its data says.

:::parte modelo-maquina

Branching does not change the memory model: it is still the same row of boxes. What changes is that
**not every statement in the text runs every time** now. Which body runs depends on the value of an
expression, evaluated exactly once, at the instant execution reaches the branch. Tracing a program with
branches needs the same trace table as always, with one new column: which branch was taken, and why.

:::parte desarrollo

## The conditional: two paths, only one taken

{{ejemplo:example-b3-aprobado}}

{{diagrama:example-b3-aprobado#ordinograma}}

{{lexema:ifKeyword}} evaluates an expression that has to be of boolean type. If it is true the
{{lexema:then}} body runs; if not, the {{lexema:elseKeyword}} body, which is optional. Absent, doing
nothing is the opposite branch. The middle word {{lexema:then}} is always required: it gives a clean
synchronisation point, and without it the error would be generic instead of naming exactly what is
missing.

The same conditional, as a structogram:

{{diagrama:example-b3-aprobado#estructograma}}

**There is no construction of its own for "else if".** Chaining conditions is nesting a conditional
inside the previous one's opposite branch, each with its own closing. The tree has no chain node: what
there is, is one conditional inside another, as many times as needed.

## Multiple selection: one expression, several labels

{{ejemplo:example-b3-dia-semana}}

{{lexema:switchKeyword}} evaluates its expression **exactly once** and compares it against each
branch's labels, in order. Labels are literals, never expressions: that is what makes it possible to
detect a repeated label without having to evaluate anything. Once a branch matches, its body runs and
execution continues after the closing keyword: there is no falling through from one branch to the
next. The {{lexema:defaultCase}} branch is optional and, if present, has to be last.

:::parte prediccion

- example-b3-dia-semana#3# With input 6, what exact line does the program write?

Before checking, decide which label the value 6 is compared against first, and which one it matches.

:::parte errores-frecuentes

## A condition that is not boolean

The expression of {{lexema:ifKeyword}} has to produce true or false. A number is not that, even though
in other languages anything non-zero "feels" true: here there is no such implicit conversion.

```pseudo
algorithm NonBooleanCondition
    define grade as integer;
    grade <- 5;
    if grade then
        write "Passed";
    endIf
endAlgorithm
```

{{diagnostico:nonBooleanCondition}}

## A conditional that never closes

Every {{lexema:ifKeyword}} needs its {{lexema:endIf}}. Without it, the analyser cannot tell where the
body ends and the rest of the program continues.

```pseudo
algorithm UnclosedConditional
    define grade as integer;
    grade <- 5;
    if grade >= 5 then
        write "Passed";
endAlgorithm
```

{{diagnostico:unclosedIfStatement}}

## A label that appears twice

Each value can only belong to one branch. If two different branches name the same label, the second
one can never be reached.

```pseudo
algorithm DuplicateLabel
    define day as integer;
    day <- 3;
    switch day do
        1, 7:
            write "Weekend";
        7:
            write "Again";
    endSwitch
endAlgorithm
```

{{diagnostico:duplicateSwitchCaseLabel}}

:::parte especificacion

- esp-i-control The conditional, multiple selection and the three loops
- esp-i-operadores The boolean type and its operators

:::parte ejercicios

- CON-B3-E1 Even or odd
- CON-B3-E2 Weekend or weekday
- CON-B3-E3 Classifying a grade
- CON-B3-E4 Larger of two numbers
- CON-B3-E5 Operations menu
- CON-B3-E6 Age category

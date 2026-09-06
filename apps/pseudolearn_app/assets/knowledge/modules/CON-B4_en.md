:::parte pregunta

Repeating a step ten times by writing it ten times works, until you need a hundred, or until you do
not know in advance how many times you will need. This module introduces the three ways to repeat a
body of statements without repeating its text, and the rule for choosing which of the three fits each
case.

:::parte modelo-maquina

A loop adds no new box and no new rule about what an assignment does: it is still the same memory as
always. What changes is that the trace table stops having one row per statement and starts having one
row **per pass**, because the same statement runs with different values every time control comes back
to it. Tracing a loop by hand, pass by pass, is the only way to see for certain when it ends and what
value each box is left holding.

:::parte desarrollo

## While: the condition is checked before entering

{{ejemplo:example-b4-mientras}}

{{diagrama:example-b4-mientras#ordinograma}}

{{lexema:whileKeyword}} evaluates its condition **before** every pass, including the first one. If it
is false from the start, the body does not run even once, and that is not an error: it is exactly what
should happen when the input data no longer satisfies what the loop needs.

As a structogram, the condition sits at the top of the block, before the body:

{{diagrama:example-b4-mientras#estructograma}}

## Repeat: the condition is checked after leaving

{{ejemplo:example-b4-repetir}}

{{diagrama:example-b4-repetir#ordinograma}}

{{lexema:repeat}} runs the body and **then** evaluates the exit condition. That is why the body runs
**at least once**, always, no exceptions: there is no way for the condition to stop the first pass,
because it does not exist yet when that pass happens. It is the right shape for "ask for data until one
of them says to stop", because the first piece of data has to be asked for no matter what.

The same loop, as a structogram, with the condition at the bottom:

{{diagrama:example-b4-repetir#estructograma}}

## For: when the number of passes is already known

{{ejemplo:example-b4-para}}

{{lexema:forKeyword}} fixes the initial value, the final value and the step — one, if not written — in
advance, and all three are evaluated **exactly once**, before the first pass. The direction of travel
is decided by the sign of the step, never by the relationship between the initial and final values:
with a positive step it advances while the control variable is less than or equal to the final value,
and with a negative step while it is greater than or equal. On exit, the control variable **keeps the
first value that no longer satisfied the condition**, not the last one that did.

## Which loop fits which case

Three questions, in this order, decide which construction to use: is the number of passes known before
starting? Then {{lexema:forKeyword}}. If it is not known, does the body have to run at least once no
matter the condition? Then {{lexema:repeat}}. If not even that is guaranteed, then
{{lexema:whileKeyword}}, the only one of the three that can finish without having run the body even
once.

:::parte prediccion

- example-b4-para#7#i With this example's input, what value does `i` hold right after the loop ends?

Before checking, decide what the last value of `i` was that **did** satisfy the condition, and what was
the first one that **did not**. The control variable keeps one of the two: it is not the one most
people expect at first glance.

:::parte errores-frecuentes

## A While loop that never closes

Every {{lexema:whileKeyword}} needs its {{lexema:endWhile}}. Without it, the analyser cannot tell where
the loop body ends and the rest of the algorithm continues.

```pseudo
algorithm UnclosedLoop
    define i as integer;
    i <- 3;
    while i > 0 do
        write i;
        i <- i - 1;
endAlgorithm
```

{{diagnostico:unclosedWhileStatement}}

## A Repeat loop with no exit condition

{{lexema:repeat}} has no closing word of its own: it is the {{lexema:until}} clause that closes the
block. Without it, the loop is left open just as if it were missing any other closing keyword.

```pseudo
algorithm UnclosedRepeat
    define n as integer;
    repeat
        read n;
        write n;
endAlgorithm
```

{{diagnostico:unclosedRepeatStatement}}

## A For loop that never closes

Just like the other two, {{lexema:forKeyword}} needs its {{lexema:endFor}}.

```pseudo
algorithm UnclosedFor
    define i as integer;
    for i <- 1 to 5 do
        write i;
endAlgorithm
```

{{diagnostico:unclosedForStatement}}

## A bound that is not an integer

The final value of {{lexema:forKeyword}} has to be of integer type, just like the initial value and the
step: the control variable advances in integer steps, and comparing it against a real bound has no
exact meaning.

```pseudo
algorithm NonIntegerBound
    define i as integer;
    define bound as real;
    bound <- 5.5;
    for i <- 1 to bound step 1 do
        write i;
    endFor
endAlgorithm
```

{{diagnostico:nonIntegerForBound}}

:::parte especificacion

- esp-i-control The conditional, multiple selection and the three loops

:::parte ejercicios

- CON-B4-E1 Countdown
- CON-B4-E2 Count of readings until the sentinel
- CON-B4-E3 Sum of a range
- CON-B4-E4 Sum of multiples of three
- CON-B4-E5 Digit count of a number
- CON-B4-E6 Countdown with a variable step

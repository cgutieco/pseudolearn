:::parte pregunta

An algorithm that only computes with numbers typed into its own text solves one case and no other: to
add two different numbers you would have to rewrite it. A useful program takes its data from outside
and hands its result back out. This module formalises those two directions: how a value is requested,
and how it is shown.

:::parte modelo-maquina

Reading does not invent a new box: it writes into one that already existed, exactly like an
assignment, except the value does not come from the program's own text but from outside it. Writing
does not read the program's memory into a box of its own either: it only looks at the value a box
already holds, or the value an expression evaluates to, and translates it to text. Neither one creates
or destroys a box: both request or hand over something that already exists.

:::parte desarrollo

## Reading: one at a time, in the order they are written

{{ejemplo:example-b2-lectura-multiple}}

A single {{lexema:read}} statement can request several values, separated like the items of any list,
but it does not request them all at once: it requests them **one at a time**, in the order they appear.
The type each value has to satisfy is the type of the designator receiving it: asking for an integer
into a text box makes no sense, and the engine keeps asking for the same value until the one it gets
matches.

## Writing: a list of expressions, with no automatic separator

{{ejemplo:example-b2-saludo}}

{{lexema:write}} accepts a list of expressions that are evaluated exactly once, left to right, and
concatenated **with no space or separator the language adds on its own**. Whatever space you want to
see between two values is written as a third expression, a literal piece of text. By default every
{{lexema:write}} ends in a line break; the {{lexema:withoutNewline}} modifier, always written at the
end of the list, suppresses it, and two consecutive writes end up on the same line.

## A designator is not just any expression

What receives a value read from outside has to be a name that can be assigned to: a variable, not a
computation. `a + 1` is a valid expression to write, but there is no box to store the result of adding
one to something in, so it is not a valid target to read into.

:::parte prediccion

- example-b2-lectura-multiple#5#b With inputs 6 and 4, what value does `b` hold right after the `read a, b;` statement finishes?

Before checking, decide in which order `a` and `b` are requested, and what would happen if that
statement were given only one value instead of two.

:::parte errores-frecuentes

## Reading into something that is not a name

To the right of {{lexema:read}} there has to be a designator: a name to store the incoming value in.
A computation has nowhere to be stored.

```pseudo
algorithm InvalidRead
    define n as integer;
    read n + 1;
endAlgorithm
```

{{diagnostico:invalidReadTarget}}

:::parte especificacion

- esp-i-entrada-salida What the output emits, what reading requires, and how each value is written

:::parte ejercicios

- CON-B2-E1 Introduction with name and age
- CON-B2-E2 Sum of two values in a single read
- CON-B2-E3 Product record in one line
- CON-B2-E4 Average of four readings
- CON-B2-E5 Label and value with no line break
- CON-B2-E6 Temperature conversion with formatting

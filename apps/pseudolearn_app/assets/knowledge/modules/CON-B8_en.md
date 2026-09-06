:::parte pregunta

Reading a program is not the same as writing it: it means following the flow of control without being
able to run it, and a long text hides that structure among lines that look alike. This module adds no
new construction of the language: it teaches how to read the ones that already exist through their
drawing, with the flowchart and with the structogram.

:::parte modelo-maquina

The flowchart draws the flow with arrows: every symbol is a step and every arrow says which one comes
next, including the ones that loop back to close a loop. The structogram has no arrows: every
construction is a box containing other boxes, nested exactly the way the text itself nests them. That
difference is not a matter of style. A structogram **cannot draw a jump that breaks the nesting** —
there is no arrow that can be drawn out of one box into any other point of the drawing — and that is
why it is the visual proof that a program is made entirely of this language's five structured
constructions: nothing jumps into the middle of another construction, and nothing drawn twice
represents the same code twice.

:::parte desarrollo

## The same program, two drawings

{{ejemplo:example-b8-clasificar}}

{{diagrama:example-b8-clasificar#ordinograma}}

This program's flowchart shows the counted loop as an arrow looping back from the end of the body to
the counter check, with the conditional hanging inside the loop's body. Reading the flowchart means
following that arrow: the path execution takes on every pass depends on whether the grade that was read
reached 5 or not.

{{diagrama:example-b8-clasificar#estructograma}}

The same program as a structogram has no arrow to follow: the counted loop's box contains the
conditional's box, which contains its two branches, and reading the diagram means reading the boxes from
the outside in. Both forms describe exactly the same behaviour because they describe exactly the same
tree: they are two drawings of the same structure, never two different programs.

## Why "structured" is a promise you can draw

A language with no {{lexema:whileKeyword}} and no {{lexema:forKeyword}} could simulate a loop with an
unconditional jump backwards, and that jump can be drawn on a flowchart with a loose arrow. On a
structogram there is nowhere to put it: every box is either completely inside another or completely
outside, never crossing one's edge. This language has no jump statement at all — not even to exit a
loop early — precisely so the promise of "structured program" always holds, not only when whoever wrote
it happens not to use the jump that does exist.

:::parte prediccion

- example-b8-clasificar#10#passing With count 4 and grades 3, 6, 5 and 2, how many grades passed?

Before checking, follow the flowchart step by step — or count the structogram's boxes that activate —
and decide how many times the conditional's condition holds.

:::parte errores-frecuentes

## A construction the language recognises and rejects on purpose

An unconditional jump would break the promise that every structogram can be drawn with no loose arrows.
The language recognises the word and rejects it explicitly, instead of treating it as an ordinary name.

```pseudo
algorithm UnconditionalJump
    define i as integer;
    i <- 0;
    goto ending;
endAlgorithm
```

{{diagnostico:unsupportedStructuredConstruct}}

## A multiple selection that never closes

Like any other block construction, a multiple selection with no closing keyword leaves the analyser
unable to decide where the structogram's box ends and the rest of the program continues.

```pseudo
algorithm UnclosedSelection
    define day as integer;
    day <- 3;
    switch day do
        1:
            write "Monday";
endAlgorithm
```

{{diagnostico:unclosedSwitchStatement}}

:::parte especificacion

- esp-i-control The conditional, multiple selection and the three loops

:::parte ejercicios

- CON-B8-E1 Count passing grades
- CON-B8-E2 Sum of the even numbers
- CON-B8-E3 Largest of a series
- CON-B8-E4 From counting passing to counting failing
- CON-B8-E5 Count weekend days
- CON-B8-E6 Passing and failing on two lines

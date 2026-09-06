:::parte pregunta

An algorithm that only computes with numbers typed by hand is useless: it solves one case and no
other. To make it work for every case you need to be able to say "the number I am given", and for that
you need to store values under a name. This module is about exactly that: what kinds of values exist,
how they are named, and what happens when a name is given a new value.

:::parte modelo-maquina

The memory of a program is a row of boxes. Each box has a name, admits values of a single kind, and
holds one value at a time. Declaring is asking for a box and deciding what kind of values it admits.
Assigning is writing inside it, erasing whatever was there.

{{figura:cajas-memoria}}

That is the whole idea, and it is worth keeping in mind: almost everything that surprises you about a
program is explained by looking at which boxes exist and what each one held one step earlier.

:::parte desarrollo

## Five kinds of values

Every value belongs to one of five types, and the type decides which operations make sense with it.

{{tabla:primitiveTypes}}

## Declaring and assigning are two things

You declare with {{lexema:declare}} and assign with {{lexema:assignment}}. Declaring reserves the box
and fixes its type. Assigning writes inside it. They cannot be written together, and that separation is
not a whim: it makes it obvious at a glance where a name is born and where its value changes.

{{ejemplo:example-sum}}

That program declares three boxes, writes into two of them, computes with both and stores the result in
the third. Nothing else happens, and nothing else is needed.

## The order of operations is not the reading order

Inside an expression, operations are not applied left to right but by priority. This is the table the
language uses, from highest to lowest:

{{tabla:precedence}}

{{ejemplo:example-b1-expresiones}}

The two lines of that program are written almost identically and are not worth the same. The first one
multiplies before adding because multiplication sits in a higher row; the second adds first because
parentheses win over the table.

## Assigning is erasing

An assignment does not add a value: it replaces the one that was there. That is why swapping the
contents of two boxes cannot be done in two steps, and a third box is needed to remember the value that
is about to be lost.

{{diagrama:example-b1-intercambio#ordinograma}}

:::parte prediccion

Before running anything, write down on paper which values `a` and `b` hold right after the last
assignment of this program:

{{ejemplo:example-b1-intercambio}}

Now run it step by step and compare. If your prediction matches, your model of the machine works. If it
does not, you have just found exactly where it did not work, which is worth far more.

- example-b1-intercambio#5#a Value of `a` and `b` right after the last assignment

:::parte errores-frecuentes

## Giving an initial value inside the declaration

The type is written at the end of the declaration, so an initial value does not fit there. You declare
on one line and assign on the next.

```pseudo
algorithm InitialValue
  define n as integer <- 5;
endAlgorithm
```

{{diagnostico:initializationInDeclarationNotAllowed}}

## Assigning to something that is not a box

To the left of an assignment there must be a name, not a number and not a computation. Writing it the
other way round is the mistake of someone coming from mathematics, where equality has no direction.

```pseudo
algorithm InvalidTarget
  define n as integer;
  n <- 3;
  5 <- n;
endAlgorithm
```

{{diagnostico:invalidAssignmentTarget}}

## Storing a value of another kind in a box

A box of integers does not admit text. The warning is not a quirk of the language: it is what stops the
program from carrying on and computing with something that is not a number.

```pseudo
algorithm IncompatibleType
  define n as integer;
  n <- "five";
  write n;
endAlgorithm
```

{{diagnostico:incompatibleTypesInAssignment}}

:::parte especificacion

- esp-i-tipos-primitivos The five types, their values and their range
- esp-i-operadores The complete precedence table and short-circuiting
- esp-i-declaracion The exact shape of a declaration and of an assignment

:::parte ejercicios

- CON-B1-E1 Sum of two numbers
- CON-B1-E2 Area of a rectangle
- CON-B1-E3 Swapping two values
- CON-B1-E4 Average of three marks
- CON-B1-E5 Complete the perimeter
- CON-B1-E6 From sum to difference
- CON-B1-E7 Discounted price, as a sequence

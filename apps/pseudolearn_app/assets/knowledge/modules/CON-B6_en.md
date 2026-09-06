:::parte pregunta

An algorithm that solves three similar problems by writing nearly the same code three times cannot be
fixed in a single place when something changes. This module introduces the subprogram: a named piece
of code that takes data through its parameters and can be called again and again from anywhere in the
algorithm.

:::parte modelo-maquina

Every call to a subprogram opens its **own frame** of memory, with its own boxes, separate from the
algorithm's frame and from any other call. The algorithm's variables are not visible inside a
subprogram: all communication goes through the parameters, which are new boxes created on entry, and
through the return value, if the subprogram declares one. When the call ends, that whole frame
disappears.

:::parte desarrollo

## A function returns a value; a procedure does not

{{ejemplo:example-b6-funcion}}

{{lexema:subroutine}} is a single construction for both. If it declares a return type with
{{lexema:typeConnector}}, it is called inside an expression and has to end with
{{lexema:returnKeyword}} on every path. If it does not declare one, it is called as a statement on its
own and returns nothing.

## By value copies; by reference shares the same box

{{ejemplo:example-b6-referencia}}

A **by value** parameter — the default mark — receives a copy: whatever the subprogram does with it is
not visible outside. A {{lexema:byReference}} parameter does not receive a copy, it receives **the same
box** the argument names, so a change inside the subprogram is a change in the caller's variable. That
is why swapping two values only works if both parameters are by reference: with a copy there is no way
for the change to leave the subprogram.

## Arrays are always passed by reference

{{ejemplo:example-b6-arreglo-parametro}}

An array is not a value, so there is nothing to copy: passing it by value makes no sense and the
language rejects it. An array parameter is written with empty brackets — `data[]` for one dimension —
because the size already comes with the array that was passed; the subprogram does not declare it
again.

:::parte prediccion

- example-b6-referencia#8#x With inputs 3 and 9, what value does `x` hold right after the call to `Swap` ends?

Before checking, decide what would happen if `Swap` received both its parameters by value instead of by
reference: would `x` change in the calling algorithm?

:::parte errores-frecuentes

## Calling with fewer or more arguments than the subprogram expects

The number of arguments in a call has to match exactly the number of declared parameters. There are no
optional parameters.

```pseudo
subroutine Add(a as integer, b as integer) as integer
    return a + b;
endSubroutine

algorithm CallWithExtraArguments
    write Add(1, 2, 3);
endAlgorithm
```

{{diagnostico:argumentCountMismatch}}

## An argument of a type that does not match

The type of every argument has to be compatible with the type of the parameter it receives.

```pseudo
subroutine Double(n as integer) as integer
    return n * 2;
endSubroutine

algorithm CallWithWrongType
    write Double("five");
endAlgorithm
```

{{diagnostico:incompatibleArgumentType}}

## Passing a literal to a by-reference parameter

A by-reference parameter needs somewhere to write into; a literal or the result of a computation has
nowhere to store anything.

```pseudo
subroutine Increment(n as integer by reference)
    n <- n + 1;
endSubroutine

algorithm ReferenceWithoutDesignator
    Increment(5);
endAlgorithm
```

{{diagnostico:byReferenceArgumentRequiresDesignator}}

## Returning outside a subprogram

{{lexema:returnKeyword}} only makes sense inside a subprogram's body: the algorithm does not return
anything to anyone.

```pseudo
algorithm ReturnOutsideSubprogram
    define n as integer;
    n <- 5;
    return n;
endAlgorithm
```

{{diagnostico:returnOutsideSubroutine}}

:::parte especificacion

- esp-i-subprogramas A single construction, parameters, passing, return, scope and recursion

:::parte ejercicios

- CON-B6-E1 Square function
- CON-B6-E2 Maximum of two numbers function
- CON-B6-E3 Procedure that swaps two variables
- CON-B6-E4 Procedure that doubles a vector
- CON-B6-E5 Function that counts elements larger than a bound
- CON-B6-E6 Procedure that orders two variables

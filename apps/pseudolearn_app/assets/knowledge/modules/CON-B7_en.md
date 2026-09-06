:::parte pregunta

Some problems are solved naturally by describing them in terms of a smaller version of themselves: the
factorial of 5 is 5 times the factorial of 4. This module introduces recursion, a subprogram that calls
itself, and the call stack that makes it possible to trace.

:::parte modelo-maquina

{{figura:pila-de-llamadas}}

Every recursive call opens a new frame, exactly like any other call from the previous section, and
those frames stack up: the most recent one is the only one active, and the ones below wait for it to
finish so they can pick up where they left off. The call stack is that structure of frames, one on top
of another. It is not a loose metaphor: it is literally the mechanism that decides which boxes are
alive at each step.

:::parte desarrollo

## Base case and recursive case

{{ejemplo:example-b7-factorial}}

Every recursion that terminates has two parts: a **base case**, which answers without calling itself
again, and a **recursive case**, which answers in terms of a call with smaller data. `Factorial` stops
at `n <= 1` without calling itself again; for any other `n`, it calls itself with `n - 1`, which is
closer to the base case than `n` was. Without the base case, the call stack grows without stopping.

## Every call has its own `n`

{{ejemplo:example-b7-suma}}

`SumUpTo(5)` does not share its `n` with `SumUpTo(4)`: every frame on the stack has its own, with its
own value, even though both calls run the same subprogram text. Tracing a recursion by hand requires
drawing the whole stack, frame by frame, and reading a variable's value always means "in the frame that
is active right now".

## The depth limit

This language stops a recursion that calls itself a thousand times in a row without finishing, with a
runtime diagnostic instead of exhausting the machine's memory. A recursion with no base case, or with a
base case that is never reached, hits that limit almost immediately.

:::parte prediccion

- example-b7-factorial#12#n With input 4, when `Factorial` calls itself for the last time — the one that actually reaches the base case —, what value does `n` hold in that frame?

Before checking, draw on paper the four calls `Factorial(4)`, `Factorial(3)`, `Factorial(2)` and
`Factorial(1)`, stacked one on top of another, and mark which one is the only one with a base case that
does not call itself again.

:::parte errores-frecuentes

## A subprogram with a return type that never returns

A subprogram that declares what it returns has to return that value on some path through its body. A
base case that only writes the result instead of returning it leaves the subprogram with no return
statement at all.

```pseudo
subroutine FactorialWithoutReturn(n as integer) as integer
    if n <= 1 then
        write 1;
    endIf
endSubroutine

algorithm MissingReturn
    write FactorialWithoutReturn(3);
endAlgorithm
```

{{diagnostico:subroutineWithoutReturn}}

:::parte especificacion

- esp-i-subprogramas A single construction, parameters, passing, return, scope and recursion

:::parte ejercicios

- CON-B7-E1 Recursive factorial
- CON-B7-E2 Recursive sum from 1 to n
- CON-B7-E3 Recursive power
- CON-B7-E4 Recursive digit count
- CON-B7-E5 Sum of a vector, recursively
- CON-B7-E6 Recursive Fibonacci

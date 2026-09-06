# Subroutines and functions

A subroutine is a named piece of program, with its own inputs and its own memory. It is what allows
writing once what is used many times, and what enables reading a long program without having it all in
mind.

## A single construct, two roles

It opens with {{lexema:subroutine}}, its name, and its parentheses, optionally
{{lexema:typeConnector}} with a return type, and closes with {{lexema:endSubroutine}}.

A subroutine that **declares** a return type returns a value and is called within an expression; one
that **does not declare it** returns nothing and is called as a statement. There are not two keywords or
two grammars: there is an optional clause.

This is chosen because languages students jump to later have **one** construct whose return type can be
void, and because the distinction that truly matters —whether a call is a statement or an expression— is
not syntactic in any real language: it depends on whether a value is returned.

Parentheses are **mandatory**, also without parameters and also at call sites. They are not decoration:
they distinguish a call from reading a variable without consulting any table, and therefore allow a
misspelled name to have a diagnostic saying whether something is extra or missing.

The return type is one of the five primitive types or a class. **An array cannot be returned**, because
an array is not a value.

{{ejemplo:example-esp-subprogramas-dos-papeles}}

## Where a subroutine lives

A source text contains **exactly one algorithm and zero or more subroutines and classes**, in any order,
all at the top level. A subroutine is not declared inside another or inside the algorithm body.

Order does not matter because name resolution gathers all headers in an earlier pass; requiring
declaration to precede use would force reordering text to write mutually calling subroutines. And there
is no nesting because a subroutine inside another would only make sense with nested scopes, which the
language does not have.

{{ejemplo:example-esp-subprogramas-donde-vive}}

## Parameters

Each parameter is a name, optionally {{lexema:typeConnector}} with its type, and optionally a passing
marker as suffix. An array parameter is marked with {{lexema:leftBracket}} and
{{lexema:rightBracket}} and as many {{lexema:comma}} as dimensions minus one: **sizes do not appear**,
because the array already exists when it arrives and the subroutine does not dimension it.

The type is optional in the grammar and the mandatory declaration flag makes it required. There is no
new flag: a parameter is the input variable of the subroutine, and the flag that already requires
declaring every variable reaches it.

{{ejemplo:example-esp-subprogramas-parametros}}

## Pass by value and pass by reference

The marker goes **as suffix**, after the type, and absent passing is **by value**. Writing
{{lexema:byValue}} is admissible and redundant; {{lexema:byReference}} makes the parameter name the same
slot as the argument.

**The marker is per parameter and does not carry over.** Writing it once and applying it to subsequent
parameters is expressly rejected: under that rule, whoever reads an unmarked parameter cannot know how
it is passed without looking upward, and that is a silent failure.

An argument corresponding to a pass-by-reference parameter **must be a designator**: a name, an array
element, or an object member. A literal, an expression, or a call to another subroutine has nowhere to
store anything.

When the argument is an array element, its index **is evaluated once, at the moment of the call**, and
the position remains fixed throughout the subroutine execution. Passing the same variable to two
pass-by-reference parameters is **permitted** and produces what it produces: both parameters name the
same slot. It is not diagnosed, because the project teaches aliasing instead of hiding it.

{{ejemplo:example-esp-subprogramas-paso}}

## Arrays are always passed by reference

This is not a capricious exception: it follows from an array not being a value. Passing by value is
copying a value, and here there is none to copy. Therefore, marking an array parameter by value is a
named failure —not silently ignored— and marking it by reference is admissible and redundant.

{{ejemplo:example-esp-subprogramas-paso-arreglos}}

## Return

{{lexema:returnKeyword}} is a **statement**, not a name declared in the header to which the body
assigns. It can appear **multiple times**, anywhere in the body, including inside a conditional, a
selection, and any of the three loops; upon execution, the subroutine terminates immediately and the
rest of the body does not execute.

The single exit rule is rejected: it is a style convention, not of the language, and no real language
imposes it.

It takes an expression in a subroutine with declared return type and takes none in one without type,
where it serves as an early exit. A subroutine with declared type **whose body contains no return**
fails without running; that a specific path reaches the end without passing through any is a runtime
failure, indicated at subroutine closing. The division is deliberate: a correct program is never
rejected for inability to prove it is so.

{{ejemplo:example-esp-subprogramas-retorno}}

## Invocation

A call is the name followed by its arguments in parentheses, and the same form serves as statement and
as expression. Which of the two is valid is decided by whether the subroutine declares a return type,
and is therefore a check of meaning and not of writing.

- Calling **as an expression** a subroutine without return type is a failure: there is no value to place.
- Calling **as a statement** one with return type is valid and produces a warning: the value is discarded.
- **The number of arguments matches the number of parameters.** There are no optional parameters or
  default values.
- Arguments are evaluated from left to right, once each, before entering the body.

{{ejemplo:example-esp-subprogramas-llamada}}

## No global variables

Each subroutine has its own scope, and algorithm variables **are not visible** inside any subroutine.
All communication passes through parameters and the return value.

This is the point of greatest divergence between notations, and the reason for this choice is
threefold: a subroutine reading a variable it did not receive is not reusable; step-by-step execution
can display the visible state at each moment because it is the current frame and nothing else; and no
real language makes main program variables global by default.

Subroutine names form **their own space**, unique for the whole text. Still, a subroutine and a variable
cannot share the same name in the same scope: it is forbidden not out of technical necessity but because
the program doing so cannot be read.

```pseudo
Subroutine Test()
  Write x
EndSubroutine
Algorithm GlobalError
  Define x As Integer
  x <- 5
  Test()
EndAlgorithm
```

{{diagnostico:undeclaredVariable}}

## Recursion, and the depth limit

A subroutine can call itself, directly or indirectly, and mutual recursion works without any additional
declaration because there is no declaration order.

**There is a call depth limit, belonging to the language and set to one thousand.** Reaching it produces
a runtime failure indicating the call exceeding the limit, and execution halts there.

It is not a profile datum: a program recurring nine hundred times would finish under one limit and fail
under another, changing what the program does, not whether it is valid. The number is one thousand
because it is the default limit of the interpreter most likely to be the next step, and because no
introductory course exercise approaches that depth while a recursion without base case reaches it
instantly.

The call stack is an evaluator data structure and not that of the executing machine, so **it is
impossible for infinite recursion to manifest as a stack overflow**: it is counted before creating the
next frame, resulting in a diagnostic.

{{ejemplo:example-esp-subprogramas-recursion}}

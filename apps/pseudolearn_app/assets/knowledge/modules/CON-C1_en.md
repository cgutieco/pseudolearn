:::parte pregunta

A bank account has a balance, and depositing or withdrawing only makes sense against that exact
balance. Modelling it with a loose variable and a handful of subprograms that receive that variable as
a parameter works, until there are two accounts: then every subprogram needs one more parameter, and
nothing stops passing it the wrong account's balance. This module introduces the class: a way to keep
together the state and the behaviour that belong to each other, so that mistake stops being possible.

:::parte modelo-maquina

A class is a blueprint: it declares which boxes every object of that class has and which subprograms
can touch them. The blueprint itself takes up no memory. Every time an object is created with
{{lexema:newInstance}} a fresh set of boxes is reserved, belonging to that object alone, and that set
is exactly what this course used to call "the parameters that had to be passed together because they
belonged to the same thing".

:::parte desarrollo

## From loose variables to an object

{{ejemplo:example-c1-cuenta}}

{{diagrama:example-c1-cuenta#clases}}

`define account as BankAccount` declares a reference, still with no object. `new BankAccount(100)`
creates the object — it reserves its `balance` box and runs the constructor with `100` — and the
assignment makes `account` designate that object. They are two separate steps because they are two
separate things: declaring does not create, and creating is an expression, not a statement of its own.

## Methods are subprograms with one extra object

`account.Deposit(50)` and `account.Balance()` are subprogram calls, with the only difference being that
each one receives, besides its written parameters, the object it was called on. Inside the method, that
object is named {{lexema:thisObject}}. `this.balance` is not a parameter and not a local variable: it is
the box belonging to the object the method is currently running on.

:::parte prediccion

- example-c1-cuenta#8# What value does the program write at the end, after depositing 50 on top of an initial balance of 100?

Before checking, decide whether `Balance()` could return a value other than the one `Deposit` left in
the object's box: is there any other `BankAccount` around that could get confused with this one?

:::parte errores-frecuentes

## A constructor that declares what it returns

The constructor never returns a value: it creates the object, it does not compute one. Writing a return
type on it treats it as if it were an ordinary method.

```pseudo
class Point
    private define x as integer;

    method constructor(anX as integer) as integer
        this.x <- anX;
    endMethod
endClass
```

{{diagnostico:constructorReturnTypeNotAllowed}}

## A class inside another class

Classes are siblings of the algorithm and of subprograms, all at the top level of the text. There are
no nested classes: they would only make sense with nested scopes, and this language has none.

```pseudo
class Outer
    class Inner
        private define n as integer;
    endClass
endClass
```

{{diagnostico:nestedClassNotSupported}}

:::parte especificacion

- esp-o-clases Object-oriented notation: class, attributes, methods, constructor and instantiation

:::parte ejercicios

- CON-C1-E1 Rectangle class with area
- CON-C1-E2 Counter class with increment
- CON-C1-E3 Thermometer class with conversion
- CON-C1-E4 Product class with discount
- CON-C1-E5 Single-item Stack class
- CON-C1-E6 TrafficLight class with state

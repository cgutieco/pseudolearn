:::parte pregunta

The previous module, **Inheritance and dynamic dispatch**, showed how one class inherits from another: "is a kind of". There is a second relationship
between classes, just as common and with a design question of its own: a class that **has** an object
of another, and delegates to it the work it already knows how to do. Choosing wrong between the two —
or stuffing all the responsibility into a single class that does everything — is the most common design
mistake of this block, and this module is about avoiding it.

:::parte modelo-maquina

Every piece of data and every operation belong to a single class, the one that has the information to
resolve them. `Car` does not know how to compute an engine's power; its `Engine` does, because it is
its own. `Car` does not duplicate that computation: it holds an `Engine` as an attribute and asks it.
The box that matters — `power` — lives in a single place, and any class that needs it goes through the
object that has it, never through a copy.

:::parte desarrollo

## Has-a, not is-a

{{ejemplo:example-c5-auto}}

{{diagrama:example-c5-auto#clases}}

`Car` does not extend `Engine`: a car is not a kind of engine, it has one. That is why `this.engine` is
an attribute, not a superclass, and `Car.Power()` does not repeat the computation: it just asks
`this.engine` and returns what it answers. This is the test that decides between inheritance and
composition: if the relationship can be said with "is a", it is inheritance; if it can only be said
with "has a", it is a class-typed attribute.

## Who owns each responsibility

This module's design question is not syntactic: it is "which class has the data to answer this?". A
class that answers questions about data that is not its own — reading someone else's attributes instead
of asking the object that holds them — is the sign that the responsibility is in the wrong place.
Splitting it well avoids both the class that knows too much and the class that knows nothing about its
own business.

:::parte prediccion

- example-c5-auto#7# With input 120, what value does the program write?

Before checking, decide which class actually computes that value: `Car`, or the `Engine` that `Car`
holds.

:::parte errores-frecuentes

## An interface

Interfaces are out of scope for this language. It is a real object-oriented construction, and the
analyser recognises it in order to say exactly that instead of treating it as a misspelled name.

```pseudo
algorithm Try
endAlgorithm

interface Shape
```

{{diagnostico:unsupportedInterfaceConstruct}}

## A static member

There are no static members in this language: every attribute and every method belong to an instance,
not to the class in the abstract.

```pseudo
class Counter
    static define total as integer;
endClass

algorithm Try
endAlgorithm
```

{{diagnostico:unsupportedStaticConstruct}}

:::parte especificacion

- esp-o-clases Object-oriented notation: class, attributes, methods, constructor and instantiation

:::parte ejercicios

- CON-C5-E1 Order that delegates to Customer
- CON-C5-E2 Library that delegates to Book
- CON-C5-E3 Thermostat that delegates to Sensor
- CON-C5-E4 Invoice that delegates to two Products
- CON-C5-E5 Team that delegates to two Players
- CON-C5-E6 Player that delegates to Song

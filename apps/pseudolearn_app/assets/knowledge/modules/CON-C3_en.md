:::parte pregunta

With integers and with text, two boxes holding the same value are interchangeable: it does not matter
which one you look at. With objects that stops being true. Two variables can point to the **same**
object, and then mutating one through either of them shows up through the other. This module is about
that distinction — reference versus value — and about the two ways of accidentally stopping to share an
object: the accidental alias and the shallow copy.

:::parte modelo-maquina

Every object has an identity of its own, distinct from its content, and the trace table shows it as
`Box#1`: object number 1 of class `Box`, and that number does not change while the object exists. A
class-typed variable does not hold the object: it holds **a reference** to it, the same number. When
two variables share the same reference, they are the same `Box#1` box seen under two names, not two
boxes that happen to hold the same content.

:::parte desarrollo

## Assigning an object copies the reference, not the content

{{ejemplo:example-c3-alias}}

{{diagrama:example-c3-alias#clases}}

`b <- a` does not create a new `Box`: it copies the reference `a` held, so `a` and `b` both come to
designate the same `Box#1` object. From then on, writing through `b` is writing the same box `a` sees.
This is not a special case for objects: it is the direct consequence of an object **being** its
reference (11.8), the same way an array passed to a subprogram shares its elements with whoever called
it.

## Copying breaks the alias, on purpose

{{ejemplo:example-c3-copia}}

{{firma:shallowCopy}} creates a **new** object, with the same values the original held at that instant,
and gives it its own identity — `Box#2`, not `Box#1`. Mutating the copy no longer touches the original:
that is exactly the difference from the previous example. The copy is **shallow**: if an attribute were
itself an object, that inner attribute would still be shared between the original and the copy, because
copying a reference does not copy what the reference points to.

:::parte prediccion

- example-c3-alias#7#b What object identity does the `b` box show right after the `b <- a;` statement?

Before checking, decide whether `b` will show a brand new identity or the same one `a` already had, and
why assigning an object cannot create an identity that did not exist.

:::parte errores-frecuentes

## Writing an object directly

An object has no text representation: writing it directly does not say which attribute to show, so the
language rejects it instead of inventing a conversion.

```pseudo
class Box
    public define content as integer;
endClass

algorithm WriteObject
    define box as Box;
    box <- new Box();
    write box;
endAlgorithm
```

{{diagnostico:objectCannotBeWritten}}

## A loose name inside a method that matches an attribute

Inside a method, an identifier with no `this` in front is never an attribute: it is a parameter or a
local variable. If it matches an attribute's name, the most likely cause is a missing `this.` before
it.

```pseudo
class Box
    private define content as integer;

    public method Empty()
        content <- 0;
    endMethod
endClass

algorithm TryEmpty
endAlgorithm
```

{{diagnostico:identifierMatchesFieldWithoutThis}}

:::parte especificacion

- esp-o-clases Instantiation, identity, shallow copy and classes as types

:::parte ejercicios

- CON-C3-E1 Detect whether two variables are the same object
- CON-C3-E2 Alias that mutates a shared counter
- CON-C3-E3 Copy that does not affect the original
- CON-C3-E4 Swap the content of two boxes
- CON-C3-E5 Two-element linked node
- CON-C3-E6 Copy and compare identities

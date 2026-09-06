:::parte pregunta

The previous module, **The first program with classes**, showed the general shape of a class; this module fixes its exact rules: what it means for a
member to be public or private, how a method is written, and what a constructor is — and is not.

:::parte modelo-maquina

Visibility decides who can touch each box from outside the object: a {{lexema:privateVisibility}}
attribute can only be read and written from inside a method of its own class; a
{{lexema:publicVisibility}} one, or one with no mark at all — which is the same thing, since public is
the default — can be touched from anywhere. The constructor is not just another method: it is the one
piece of code that runs exactly once, the instant {{lexema:newInstance}} finishes reserving the
object's boxes and before any other code touches them.

:::parte desarrollo

## Visibility is per member, not per block

{{ejemplo:example-c2-persona}}

{{diagrama:example-c2-persona#clases}}

Every attribute and every method carries its own visibility mark, written right in front of it. There
is no "private" section grouping several members: whoever reads a member knows its visibility without
having to search upward in the text. `name` and `age` are private; `Name()`, `Age()` and
`HaveBirthday()` are public, and they are the only path the rest of the program has to read or change
those two boxes.

## The constructor builds, it does not compute

`Person`'s constructor receives the initial data and stores it in the object's boxes, one at a time,
with {{lexema:thisObject}}. It never carries visibility or a return type: it is always public and never
returns anything, because its job is to leave the object ready, not to produce a value. A class allows
at most one constructor — there is no version with two parameters and another with three — and if none
is declared, the object is created with all its boxes unassigned.

## A method call's parentheses never go missing

`person.HaveBirthday()` needs its parentheses even though it takes no argument, exactly like an
ordinary subprogram (10.2): they are what distinguishes a call from an access to an attribute that
happened to share its name, and the language has no other way to tell.

:::parte prediccion

- example-c2-persona#10# With name "Ana" and age 29, what age does the program write after calling HaveBirthday once?

Before checking, decide whether `HaveBirthday` could, instead, change nothing visible from outside the
object if `age` were a local variable of the method instead of an attribute.

:::parte errores-frecuentes

## A constructor with visibility

The constructor is always public: there would be no point creating an object and not being able to
call the piece that builds it. Writing a visibility mark on it treats it as if its visibility could
vary.

```pseudo
class Box
    private define content as integer;

    private method constructor(aContent as integer)
        this.content <- aContent;
    endMethod
endClass
```

{{diagnostico:constructorVisibilityNotAllowed}}

## Two constructors in the same class

There is no overloading in this language (10.6), and a constructor is no exception: a class allows at
most one.

```pseudo
class Box
    private define content as integer;

    method constructor()
        this.content <- 0;
    endMethod

    method constructor(aContent as integer)
        this.content <- aContent;
    endMethod
endClass
```

{{diagnostico:duplicateConstructor}}

:::parte especificacion

- esp-o-clases Object-oriented notation: class, attributes, methods, constructor and instantiation

:::parte ejercicios

- CON-C2-E1 Circle class with perimeter and area
- CON-C2-E2 SafeBox class with password
- CON-C2-E3 Employee class with net salary
- CON-C2-E4 AgeRange class with validation
- CON-C2-E5 Book class with loan status
- CON-C2-E6 Scoreboard class with two teams

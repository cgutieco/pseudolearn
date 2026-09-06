:::parte pregunta

`Cat` and `Dog` are pets: they share a name and the ability to speak, but each one speaks differently.
Writing that relationship by copying the `name` attribute into each class duplicates what is already
common; this module introduces inheritance, to declare "this is a pet, plus its own thing" only once.

:::parte modelo-maquina

A subclass does not recreate its superclass's boxes: it inherits them whole. `Cat extends Pet` means
every `Cat` object has, besides its own boxes, `Pet`'s boxes too. When it is built, `Pet`'s constructor
runs first over those inherited boxes, and then `Cat`'s runs over its own: the object is built from the
outside of the hierarchy inward, superclass first.

:::parte desarrollo

## A construction chain, not two loose constructors

{{ejemplo:example-c4-mascotas}}

{{diagrama:example-c4-mascotas#clases}}

`Cat`'s constructor begins with `super.constructor(aName)`: it is mandatory because `Pet`'s constructor
takes a parameter, and without that call the boxes inherited from `Pet` would be left unassigned.
`this.Name()` inside `Cat`'s `Speak` calls the inherited method without declaring it again: `Cat` has
no `Name` method of its own, and it does not need one.

## Dispatch looks at the real object, not the variable that names it

{{ejemplo:example-c4-despacho}}

{{diagrama:example-c4-despacho#clases}}

`first` and `second` are declared `as Pet`, but `first.Speak()` runs `Dog`'s `Speak` and
`second.Speak()` runs `Cat`'s: a method call is always resolved against the object's real class, never
against the type the variable naming it was declared with. It is the difference between what type the
text **says** and what type the object **is** at that moment, and it is what makes it useful to declare
code that works with `Pet` without knowing in advance whether it will receive a `Dog` or a `Cat`.

## Overriding means the same name and the same signature

`Speak` in `Cat` overrides `Pet`'s `Speak` with no special mark at all: declaring it again is enough,
with the same number of parameters, the same types and the same return type. A different signature is
not a second version: it is an error, because it stops making sense to say which of the two "is" the
method the subclass overrode.

:::parte prediccion

- example-c4-despacho#12# What two lines does the program write, in order?

Before checking, decide whether the result depends on the declared type of `first` and `second` — `Pet`
in both cases — or on the real type of the object each one holds.

:::parte errores-frecuentes

## More than one superclass

This language only has single inheritance. A list of superclasses separated by a comma is exactly the
pattern of multiple inheritance, and it is rejected during the analysis itself.

```pseudo
class Flyer
endClass

class Swimmer
endClass

class RubberDuck extends Flyer, Swimmer
endClass

algorithm Try
endAlgorithm
```

{{diagnostico:multipleInheritanceNotSupported}}

## A hierarchy that inherits from itself

If `A` extends `B` and `B` extends `A`, neither one has a real base to start from: the construction
chain could never begin.

```pseudo
class A extends B
endClass

class B extends A
endClass

algorithm Try
endAlgorithm
```

{{diagnostico:circularInheritance}}

## Forgetting the mandatory call to the superclass's constructor

If the superclass has a constructor with parameters, the subclass has to call it as the first statement
of its own constructor. Without that call, the inherited boxes are left without the value the
superclass's constructor would have given them.

```pseudo
class Pet
    private define name as string;

    method constructor(aName as string)
        this.name <- aName;
    endMethod
endClass

class Cat extends Pet
    method constructor(aName as string)
        write aName;
    endMethod
endClass

algorithm Try
endAlgorithm
```

{{diagnostico:missingSuperConstructorCall}}

## Overriding with a different signature

A method with the same name as an inherited one, but with a different number or type of parameters, is
not a valid override: it is a declaration incompatible with the one that already exists.

```pseudo
class Pet
    public method Speak() as string
        return "...";
    endMethod
endClass

class Cat extends Pet
    public method Speak(volume as integer) as string
        return "Meow";
    endMethod
endClass

algorithm Try
endAlgorithm
```

{{diagnostico:incompatibleMethodOverride}}

:::parte especificacion

- esp-o-clases Inheritance, current object and superclass, and dynamic dispatch

:::parte ejercicios

- CON-C4-E1 Shape hierarchy with overridden Area
- CON-C4-E2 Employee and Manager with inherited bonus
- CON-C4-E3 Vehicle and Motorcycle with super
- CON-C4-E4 Dispatch across three different shapes
- CON-C4-E5 Savings account that extends Account
- CON-C4-E6 Three-level hierarchy

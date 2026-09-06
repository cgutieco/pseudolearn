# Object-oriented notation

**Everything stated in imperative and structured notation remains in force, without change.** This is
not a courtesy: it is a rule of this document. Lexicon, five primitive types, operator table,
declaration and assignment, input and output, five control structures, arrays, subroutines, and type
system are identical, and no rule here contradicts them. What follows **only adds**.

What it adds is a way to say that data and corresponding operations are a single named entity. An object
is not just another variable: it is a value whose identity matters, and that is the difference to keep
in mind when reading the rest.

## Class declaration

A class opens with {{lexema:classKeyword}} and its name, optionally {{lexema:inheritsFrom}} and its
superclass name, and closes with {{lexema:endClass}}. Between both words there are only members.

- **Classes are siblings of algorithm and subroutines**, at the top level of the text. There are no
  nested classes, nor a class inside a subroutine or algorithm body, and subroutines are not declared
  inside a class: what lives there are members.
- **Declaration order does not matter**, for the same reason it does not between subroutines: name
  resolution gathers all headers in an earlier pass.
- **Single inheritance only.** Multiple comma-separated superclasses have their own diagnostic.
- Initial uppercase in class names **is not required**: it is style, not grammar.

An empty class is not an error. A class inheriting from itself, or closing an inheritance cycle, is.

{{ejemplo:example-esp-clases-declaracion}}

## Attributes and visibility

**An attribute is declared with the same statement used to declare any variable or array.** There is no
second declaration syntax, intentionally so: writing one would require deciding initial values, multiple
names per statement, and arrays all over again.

Before a member may go {{lexema:publicVisibility}} or {{lexema:privateVisibility}}.

- **Visibility is a per-member prefix and does not carry over.** Block-level visibility is rejected for
  the same reason carried-over passing was rejected: reading a member without looking upward would not
  reveal its visibility.
- **Public by default**, on attributes and methods.
- **Private means private to the class, not the instance, and subclasses do not see it.** There is no
  third visibility level. A method of a class can read a private attribute of another instance of that
  same class; a subclass method cannot read a private attribute declared by the superclass.

An attribute redeclaring an inherited attribute name is a failure regardless of visibility.

{{ejemplo:example-esp-clases-atributos}}

## Methods

A method opens with {{lexema:method}}, its name, and its parentheses, optionally
{{lexema:typeConnector}} with a return type, and closes with {{lexema:endMethod}}.

**A method is a subroutine with a receiver: same form, different opening and closing words.** It
inherits without repetition all decisions made for subroutines: mandatory parentheses without parameters,
parameter list with dimensions and passing markers, return as valid multiple statement with immediate
termination, and warning on calling as statement a method returning a value. Return type is one of five
primitives or a class.

**All methods are instance methods.** There are no static methods.

{{ejemplo:example-esp-clases-metodos}}

## Constructor

The constructor is written with {{lexema:method}} followed by {{lexema:constructor}}, its parentheses,
and its body, closing like any method.

- **It is a method whose name is a reserved word.** It admits no visibility or return type: it is always
  public and never returns a value.
- **It is optional, with at most one.** Without declaring one, the class has an implicit parameterless
  constructor assigning nothing. Two constructors in the same class is an error: no overloading.
- **It is not named like the class.** That syntax —found in several languages— is rejected because it
  would force the parser to compare method and class names to determine what it is reading. A method
  declared with the exact class name produces its own diagnostic explaining how constructors are
  declared here.
- **Construction chain.** Before a class constructor body executes, that of its superclass runs. If the
  superclass has a parameterized constructor, the subclass **must** invoke it as the first statement of
  its own constructor; if it has none, or parameterless, invocation is optional.

A return without expression inside a constructor is not an error: it is an early exit. One with
expression is.

{{ejemplo:example-esp-clases-constructor}}

## Instantiation

Written with {{lexema:newInstance}}, class name, and arguments in parentheses, and is an **expression**,
not a statement.

**Declaring and creating are two statements because they are two things.** Declaring a class variable
creates an objectless reference; assigning an instantiation creates the object and points the reference
to it. Implicit creation on declaration is rejected.

**There is no writable null value.** A declared and unassigned class variable is **uninstantiated**, and
accessing a member is a named runtime failure. This matches the absence of default values for primitives:
an oversight does not turn into a program running and producing wrong output.

Instantiating a class declared later in text is not an error, nor is chaining member access on an
instantiation result.

{{ejemplo:example-esp-clases-instanciacion}}

## Current object and superclass

**{{lexema:thisObject}} is mandatory to access any member of the current object.** Inside a method or
constructor, a bare identifier **never** designates an attribute: it designates a parameter or local
variable. Attributes are accessed exclusively through member access on the current object.

With that requirement there is no shadowing rule to write: attributes are not in method scope, they are
behind an access. A bare identifier matching an attribute name has its own diagnostic, catching errors
from students accustomed to materials not requiring it.

**{{lexema:superClass}} provides access to superclass implementation, and only that.** It can only be
the receiver of a method or constructor call: it is not an expression on its own, cannot be assigned,
and **gives no access to attributes** —if the subclass cannot see private attributes of its superclass,
no loophole may expose them—.

**Superclass calls are not dynamic.** They invoke superclass implementation even if the object is of a
subclass overriding it; without that guarantee, an override calling its superclass would recurse
infinitely.

{{ejemplo:example-esp-clases-este-super}}

## Member access, method calls, and overriding

A member access is an expression followed by {{lexema:dot}} and member name; a method call is the same
followed by arguments in parentheses.

- **Member access is a designator**: serves as assignment target and read target. Method calls are not,
  just as function calls are not.
- **It chains**, including on call results. This does not reopen bracket chaining: that restriction
  exists because index count must match declared dimensions, whereas member access chaining resolves
  against each preceding result type.
- **All method calls use dynamic dispatch**, on the actual runtime class of the object and never on the
  variable's declared type.
- **Overriding carries no marker.** A subclass method sharing the name of a superclass method overrides
  it. With no overloading, a same-name method with **different signature** is a named failure: not a
  second version, but an ill-formed override. Same signature means same parameter count, types, passing
  markers, and return type.

**Existing methods are checked against declared type when known.** A variable declared with superclass
type pointing to a subclass instance does not permit methods unique to the subclass, even if at runtime
it would work. This is not an engine limitation: it teaches the distinction between declared and actual
type, central to polymorphism.

{{ejemplo:example-esp-clases-miembro-sobrescritura}}

## Classes as types, and objects as values

Where the language accepts a type, it also accepts a class name: in variable declarations, array element
types, parameter types, and subroutine or method return types. An identifier in type position not naming
a declared class is a failure of meaning, not writing, as the parser has no symbol table.

**An object is a value; an array is not.** The value is the reference, from which all else follows:

- **Assigning a whole object is valid**, copying the reference: both names designate the same object.
  Assigning a whole array remains a failure.
- **Returning an object is valid.** Returning an array remains invalid.
- **Comparing two objects with {{lexema:equal}} or {{lexema:notEqual}} compares identity**, not
  content, and only between comparable types. Comparing instances of unrelated classes is an error, as
  the result would always be false.
- **Printing an object to output is a named failure**: no automatic string conversion here either.
- Any other operator on an object is an error.

**Passing an object to a subroutine or method.** A class-typed parameter **by value** —the default—
copies the reference: the subroutine can modify the object through it, but cannot rebind the caller's
variable to another object. A **by reference** parameter also permits rebinding.

{{ejemplo:example-esp-clases-como-tipos}}

## Copying

Explicit copying is **shallow copy**: creates a new object with identical attribute values, while
attributes that are themselves objects **remain shared**.

This semantics matches real languages, exposing nested aliasing rather than hiding it. It is provided
as a **built-in function**, not a keyword: its name is translated like any other built-in function.

{{ejemplo:example-esp-clases-copia}}

## What this language does not have, and why

This section is not an appendix. It exists because whoever comes from other materials will write these
constructs, and explaining why they do not exist is more helpful than silence.

- **Multiple inheritance.** A class inherits from only one. Multiple comma-separated superclasses have a
  dedicated diagnostic.
- **Interfaces and abstract classes.** Nonexistent. Methods override without markers and dispatch is
  always dynamic, providing all polymorphism introductory courses need.
- **Static methods and attributes.** Nonexistent. All members are instance-level.
- **Overloading.** Nonexistent: two same-named members in the same class are a duplicate declaration,
  and an override with differing signature is a malformed override, not a second version.
- **Generics.** Nonexistent.
- **Exceptions.** Nonexistent. Expected failures are engine diagnostics with pinpointed locations, not
  constructs programs catch.
- **Destructors.** Nonexistent. Programmers never need to manage object deallocation.
- **A third visibility level.** Only public and private exist. Private members are invisible to
  subclasses, and that is the complete rule.

None of these absences is an omission, and none is resolved with halfway recognizable syntax: writing
any of them produces a diagnostic naming the feature and explaining what to do instead.

```pseudo
Class A
EndClass
Class B
EndClass
Class C InheritsFrom A, B
EndClass
Algorithm MultipleInheritanceError
EndAlgorithm
```

{{diagnostico:multipleInheritanceNotSupported}}

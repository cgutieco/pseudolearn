# Type system and rigour policy

This section states **what exactly a type error is** and **what changes between strict and flexible
profiles**. The language is strongly typed and opens no exception: each silent conversion rejected here
is a programmer error that, if admitted, would become a program that executes and yields a wrong result.

## The three relationships between types

Every rule in this section rests on three relationships, named so as not to redescribe them each time:

- **Identity**: they are the same primitive type, or the same class. Used when comparing a method's
  signature with that of the one it overrides.
- **Convertibility**: identical, or integer to real, or a class to a superclass of it. Governs
  assignment, call arguments, and return values.
- **Comparability**: one is convertible to the other. Governs relational operators.

**Convertibility is directed**, and that is the whole decision: that an integer is valid where a real is
expected does not imply the reverse.

{{ejemplo:example-esp-tipos-relaciones}}

## The only implicit conversion between primitives

There is only one: from {{lexema:integerType}} to {{lexema:realType}}, because it loses no information.
All others are rejected, and each rejection has its reason:

- From {{lexema:realType}} to {{lexema:integerType}} the decimal part is lost, and deciding whether to
  truncate or round belongs to whoever writes the program. There is a built-in function for each option.
- Between {{lexema:characterType}} and {{lexema:stringType}} there is no conversion in either direction:
  they are different types, and a string of length other than one has no equivalent character.
- Between {{lexema:booleanType}} and numerics there is no conversion. It is the rule that makes a
  conditional on a number an error rather than a habit.
- From any type to {{lexema:stringType}} neither. It is the automatic conversion on concatenation found
  in other languages, expressly rejected.

From a class to a superclass of it **is** implicit, enabling polymorphism. The reverse is not, and there
is no downcast operator.

## Number ranges, and what happens on overflow

{{lexema:integerType}} is a sixty-four-bit signed number. {{lexema:realType}} is a double-precision
floating-point number.

**Integer overflow is a named runtime failure, never a silent wrap to negative.** Turning a large number
into a negative one without notice is the hardest-to-explain error a language can produce, and here the
step-by-step machine can point to the offending operation. Producing a non-finite value with a real
—infinity or NaN— is likewise a runtime failure.

## The type of each operator

- Unary signs admit a numeric operand and return its same type.
- Addition, subtraction, and multiplication admit two numerics: two integers yield integer, and any pair
  with at least one real yields real.
- {{lexema:plus}} also functions as concatenation when at least one operand is a string, or when both
  are characters, returning a string.
- {{lexema:divide}} admits any numeric pair and **always returns a real**, even if both operands are
  integers.
- {{lexema:integerDivide}} and {{lexema:modulo}} admit **only** two integers and return an integer.
- {{lexema:power}} follows the multiplication rule: two integers yield integer, and a pair with at least
  one real yields real.
- Order relationals admit two numerics, two characters, or two strings, returning boolean.
- {{lexema:equal}} and {{lexema:notEqual}} admit two comparable types and return boolean.
- {{lexema:not}}, {{lexema:and}}, and {{lexema:or}} admit **only** booleans and return boolean.

## Five rules on that list that carry decisions

**Integer division yields a real.** Integer division with the same slash used in other languages is
rejected, because it turns averaging into invisible truncation and would leave integer division without
a purpose.

**Integer division and modulo accept only integers.** Truncating operands and continuing would
reintroduce through the back door the conversion rejected in this section.

**They truncate toward zero, and the remainder takes the dividend's sign.** With negative integers,
dividing −7 by 2 gives −3 and its remainder is −1. This satisfies the identity that explains both
operators as one.

**Exponentiation preserves integer, and a negative exponent is a runtime failure.** The type of an
expression cannot depend on the runtime value of an operand, so the type is preserved and the case is
handled where the value is known.

**Concatenating a number with text is a named failure.** The diagnostic has two paths to name: the
built-in conversion function, and the fact that output already accepts a list of expressions, so writing
label and number as two list items needs no conversion.

Two more rules that are not about types but are observable: logical operators **evaluate in
short-circuit**, and comparing two reals for equality is valid and produces a warning. Comparing two
booleans with less-than or greater-than, however, is a failure: truth values have no order.

{{ejemplo:example-esp-tipos-cinco-reglas}}

## Who checks what: the two-level rule

A check is performed **without running** if it is decidable without running and without constructing a
path graph; in any other case it is performed **at runtime**, pinpointing the exact location. **A
correct program is never rejected for inability to prove it is so.**

This is not an invented rule: it is the same rule used to decide who checks that all paths in a function
return, and the same used to decide member visibility.

## Type inference in the flexible profile

**The type of an undeclared variable is fixed by the first action that gives it a value**, and those
actions are exactly two: assignment and reading. It is not the first occurrence in the text: a variable
appearing for the first time inside an expression without receiving a value is an uninitialized use, not
an inference.

With assignment, the type is that of the right-hand expression and is known without running. With
reading, the type depends on input and is fixed **at runtime**, classifying input text in this order
with the first match winning: integer literal, real literal, one of the two boolean lexemes of the
active profile, and otherwise string.

**A character is never inferred.** Single-character text is classified as a string of length one: from
input text the two readings are indistinguishable, and string loses no information. Whoever needs a
character declares it.

In the strict profile there is no inference, because the mandatory declaration flag leaves no variable
without a type. Inference is not a new flag: it is what happens when that flag is off.

{{ejemplo:example-esp-tipos-inferencia}}

## Acceptable widening and real conflict

**Acceptable widening, one and only one.** If the inferred type is integer and later a real is assigned,
the variable's type becomes real. It is acceptable because every previous integer value is representable
as real, so no already-checked line becomes invalid.

**Real conflict, everything else.** Any assignment whose type is not convertible to the fixed type fails
**on that line**, not at declaration or end of program.

Three properties make the rule checkable: widening occurs **at most once per variable**, because there
is only one implicit conversion between primitives; **it does not back-propagate**, so earlier lines are
not re-checked; and **there is no widening between classes**, so assigning a sister class instance to a
variable is a conflict even if they share a superclass.

```pseudo
Algorithm InferenceConflict
  x <- 10
  x <- "Text"
EndAlgorithm
```

{{diagnostico:typeConflictOnInferredVariable}}

## Variable used uninitialized, and absence of default values

Reading the value of a variable never assigned one is a failure **under both policies**. What the flag
decides is **when it is detected**, not whether it is one: without running when decidable without
running, and at runtime in any other case.

**There are no default values.** A declared and unassigned variable **exists but has no value**, and the
environment distinguishes the two states so the trace table displays it. Reasons are threefold: a
default value turns an oversight into a program that runs and produces a wrong result; the step-by-step
machine can point to the offending read, whereas a default zero has nothing to highlight; and it matches
what already occurs with class-typed variables, which start uninstantiated.

```pseudo
Algorithm Uninitialized
  Define x As Integer
  Write x
EndAlgorithm
```

{{diagnostico:variableUsedUninitialized}}

## Variable declared and unused, and assigned and unread

**Using is reading the value. Assigning is not using.** From this come two distinct notices, both
warnings in both policies: a variable declared and never used is dead code, and a variable assigned and
never read catches misspelled names —and under the flexible profile it is the only remaining net,
because no declaration gives it away.

Three cases count as use, documented because each would otherwise produce a false notice: a variable
passed as a pass-by-reference argument, the control variable of a counted loop, and an attribute read
from any method of its class even if that method is never called.

```pseudo
Algorithm DeclaredUnused
  Define total As Integer
EndAlgorithm
```

{{diagnostico:variableDeclaredNeverUsed}}

## Arrays and objects in the type system

An array index is of integer type; a real index is a failure and **not** a truncation.

**Size is not part of the type.** An array type is the pair of its element type and its number of
dimensions. This is a consequence and not a choice: an array parameter declares its dimensions without
sizes, so the type against which a call is checked cannot contain them.

For objects, the subtype rule is what convertibility already anticipated: a variable of a class can
reference an instance of that class or any subclass of it, and the reverse cannot. **The consequence is
taught, not concealed**: on a variable declared with the superclass type, calling a method existing only
in the subclass is a failure even if at runtime it would have worked, and the diagnostic says exactly
that, because therein lies the distinction between declared and actual type.

{{ejemplo:example-esp-tipos-arreglos-objetos}}

## Severity policy

**A diagnostic code never changes meaning between policies.** It changes severity, or changes nothing.
If two policies required the same code to mean two things, two codes would be needed.

Each code belongs to a class, which is language data, and severity is a profile datum that can only move
within what its class permits: **structural** is error in both policies; **flag-governed** is error in
strict and warning in flexible; **hygiene** is warning in both; **informational** is info in both; and
**recoverable execution** is warning in both and does not halt the program.

Two invariants check themselves: the flexible policy is always equally or more permissive than the
strict one, and no structural code drops below error in any policy.

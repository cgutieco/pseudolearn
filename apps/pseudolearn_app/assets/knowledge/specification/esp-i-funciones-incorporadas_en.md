# Built-in functions

These are operations built into the language that no program needs to declare. Their semantics belongs
to the language; their visible name is profile data and changes with the language.

## Complete catalog

{{tabla:builtinFunctions}}

## Function names are not reserved words

The name of a built-in function **consumes no token from the inventory**, so it can be used as a
variable or subroutine name. When that happens, the declaration **shadows** the built-in function in its
scope, exactly as any real language does.

It is not diagnosed, and intentionally so: prohibiting it would cause an expanding catalog to invalidate
previously correct programs.

{{ejemplo:example-esp-funciones-nombre-no-reservado}}

## The ten mathematical functions

Square root, absolute value, natural logarithm, exponential, sine, cosine, arctangent, truncation,
rounding, and random. They come from the starting catalog and none is here by a type system decision:
they are here because an introductory course uses them.

Two of them do double duty: {{firma:truncate}} and {{firma:round}} are the two exits from real-to-integer
conversion, which the language never performs on its own.

{{ejemplo:example-esp-funciones-matematicas}}

## The eight functions required by the type system

Every rejected implicit conversion forces an explicit one to exist, or the language lacks a way to do
something legitimate. These eight are not arbitrary additions: they follow from earlier decisions.

- {{firma:toText}} is the exit from rejecting number-string concatenation. The text it returns and the
  text emitted by the output statement are **the same**, produced by the same piece.
- {{firma:textToInteger}} and {{firma:textToReal}} enable arithmetic on input data read as strings. They
  fail at runtime if text is not a number, because that cannot be known beforehand.
- {{firma:length}} allows string traversal. It counts **code points**, which matches what is seen on
  screen.
- {{firma:characterAt}} is the only path from string to character, declared non-convertible in the
  conversion table.
- {{firma:characterCode}} is the only path from character to number, and {{firma:characterFromCode}} is
  its inverse.
- {{firma:shallowCopy}} is shallow object copy, committed by the objects section.

{{ejemplo:example-esp-funciones-sistema-tipos}}

## On randomness and declared determinism

{{firma:random}} **does not consult the clock or any host machine generator**. The engine receives a
pseudo-random source with explicit seed, specific to the project, so execution is reproducible by
construction.

This is not an implementation detail: without it, an exercise with test cases and a random function
would be incompatible, and step-by-step execution could not repeat identically twice.

{{ejemplo:example-esp-funciones-aleatorio}}

# Input and output

A program that communicates nothing cannot be tested. These two statements are the only boundary
between the program and whoever runs it, and their form is fixed in detail because on it depends that a
test case can be compared character by character.

## Output admits zero or more expressions

After {{lexema:write}} comes a list of expressions separated by {{lexema:comma}}. The list can be
**empty**, and then the statement emits a blank line. The expressions are evaluated from left to right
and **once each**.

{{ejemplo:example-esp-io-salida-expresiones}}

## No automatic separator

Values are emitted **concatenated, with no space or comma added by the language**. The space you want
to see is written in the program, as one more text in the list. It is the rule that makes the output of
a program exactly what its text says and not what a formatter decides.

{{ejemplo:example-esp-io-separador}}

## The without newline modifier goes at the end

{{lexema:withoutNewline}} is a **modifier of the output statement**, not a second instruction. It goes
as a suffix, after the list, and is optional: absent, a newline is emitted after the values; present, it
is not emitted. Writing it before the list or repeating it is a syntax error.

That it is a modifier and not another statement has three consequences that can be verified: a single
output symbol in the flowchart, a single path in the evaluator, and no pair of sibling constructs that
could diverge in maintenance.

{{ejemplo:example-esp-io-sin-salto}}

## How each value is written

The text emitted by the output is fixed by the language and not decided by the machine where it runs.
This is what is emitted for a value of each type:

- {{lexema:integerType}}: decimal digits, with a minus sign if negative, and never a thousands separator.
- {{lexema:realType}}: positional notation, without exponent, with **at least one decimal digit** even
  when the value has no fractional part.
- {{lexema:booleanType}}: the lexeme of the active profile for true or for false.
- {{lexema:characterType}}: the character, without quotes.
- {{lexema:stringType}}: the content, without quotes.

The text emitted by the output and the text returned by the built-in string conversion function are the
same, produced by the same piece. That they differed would be the kind of inconsistency that no exercise
catches until someone crosses it.

{{ejemplo:example-esp-io-valores}}

## Reading requires at least one designator

After {{lexema:read}} comes **one or more** designators separated by {{lexema:comma}}. Unlike output,
empty reading has no possible meaning: writing nothing is a blank line, but reading nothing is nothing.

Values are prompted **one by one and in order**, not all at once, and the expected type of each value is
the type of the designator that receives it.

{{ejemplo:example-esp-io-lectura}}

## A value that does not match the expected type

Does not interrupt execution. The step indicates which type it expected, emits its diagnostic and
**remains in the same state**, asking for the same value again. It is a decision about the step-by-step
machine, not an interface detail: an expected failure is a diagnostic, never an escaping exception.

An out-of-range index in the target of a read is a runtime failure, because the place to store does not
exist.

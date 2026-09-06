# Operators, precedence and associativity

The following table orders operators from highest to lowest precedence. Those in the same row share
precedence. The table belongs to the language: no syntax profile alters it.

{{tabla:precedence}}

## Parentheses rule over the table

Parentheses alter precedence and can be nested without limit. When an expression is long, writing them
even if unnecessary does not change the result and does change who can read it.

{{ejemplo:example-esp-operadores-parentesis}}

## Two decisions worth remembering

Exponentiation associates to the right, which is the mathematical convention. Logical negation binds
stronger than any comparison, so it applies to what is immediately to its right.

{{ejemplo:example-esp-operadores-decisiones}}

## Concatenation shares a row with addition

They share a row because they share a lexeme: which operation it is is decided by the operand types, not
by the symbol. Adding two numbers and concatenating two strings are written the same; mixing a number
and a string is neither and the language rejects it.

{{ejemplo:example-esp-operadores-concatenacion}}

```pseudo
Algorithm ConcatError
  Define message As String
  message <- "Total: " + 5
EndAlgorithm
```

{{diagnostico:cannotConcatenateNumberWithText}}

## Logical operators evaluate in short-circuit

Once the first operand is evaluated, if it already determines the result, the second is not evaluated.
It is observable, and it is what allows checking a condition and using it in the same expression without
risk.

{{ejemplo:example-esp-operadores-cortocircuito}}

## This table orders, it does not type

Which type combinations each operator admits and what type it returns is another question, and it is
answered in the type system section.

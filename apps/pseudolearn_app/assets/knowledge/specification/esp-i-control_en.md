# Control structures

Five constructs decide what executes and how many times: a two-way selection, a selection by labels,
and three loops. There is no sixth, and in particular **there is no form of jump**: neither early exit
from a loop, nor continue, nor labels. This is what enables every program written in this notation to be
drawn as a gapless structogram.

## Rules common to all five

- The body of a block is a list of statements that **can be empty**, and an empty block is not an error
  in any of the five.
- Any construct nests within any other, without declared depth limit.
- The condition of a conditional or a loop **must be of boolean type**. That it is not is a failure of
  meaning, not of writing: the statement is well-formed and what fails is what type was asked about.
- A block left unclosed at the end of the file produces **one** diagnostic, not a cascade, and that
  diagnostic also indicates the line where the block opened.

## Conditional

Its form is {{lexema:ifKeyword}} condition {{lexema:then}} body, with an optional else branch
introduced by {{lexema:elseKeyword}}, and closes with {{lexema:endIf}}.

The intermediate word {{lexema:then}} is **always mandatory**, with no rigour flag to relax it: it
gives the parser a clean synchronization point and allows saying "missing intermediate word" instead of
a generic error. The absent else branch is equivalent to an empty body.

**There is no dedicated construct for chained else-if.** Writing several cascading conditions is nesting
a conditional within the else branch, each with its own closing. The tree does not have a chain node
either: that the only statement of an else branch is another conditional is a pattern that diagrams can
recognize, not a different construct.

{{ejemplo:example-esp-control-condicional}}

## Multi-way selection

Its form is {{lexema:switchKeyword}} expression {{lexema:doKeyword}}, followed by branches where each
label list is separated from its body by {{lexema:branchSeparator}}, with an optional default branch
introduced by {{lexema:defaultCase}} and always last, and closes with {{lexema:endSwitch}}.

- **The selector is a complete expression and is evaluated exactly once**, before comparing it to any
  label.
- **Labels are literals**, not expressions or variable names. That restriction allows detecting a
  duplicate label by comparing literals, without knowing types or values; with expressions as labels, a
  dead branch would go unnoticed until execution.
- **There is no fall-through from one branch to the next.** Once the matching branch executes, execution
  continues after the closing.
- **There are no range labels**, and a label of real type is forbidden in any profile: comparing reals
  by equality is a trap, not a requirement that can be relaxed.

That no branch matches and there is no default branch **is not an error**: nothing executes.

{{ejemplo:example-esp-control-seleccion}}

## While loop

Its form is {{lexema:whileKeyword}} condition {{lexema:doKeyword}} body, and closes with
{{lexema:endWhile}}.

The condition is evaluated **before each iteration, including the first**, so the body executes **zero
or more times**. A loop whose condition is false from the start executes nothing and is not an error: it
is the normal case of traversing an empty collection.

{{ejemplo:example-esp-control-mientras}}

## Repeat loop

Its form is {{lexema:repeat}} body {{lexema:until}} condition, and **has no dedicated closing word**:
the word that introduces the condition closes the block.

The condition is evaluated **after each iteration**, so the body executes **one or more times**. The
loop ends when the condition **becomes true**: it is an exit condition, not a continuation condition,
and that is the point where it is most confused with the while loop.

**There is only one post-condition construct.** A second one with a continuation condition would be the
same construct with the negated condition, and duplicating node, parser, evaluator, and tests teaches
nothing new.

{{ejemplo:example-esp-control-repetir}}

## Counted loop

Its form is {{lexema:forKeyword}} variable {{lexema:assignment}} initial value {{lexema:to}} final
value, with an optional clause {{lexema:step}} step, followed by {{lexema:doKeyword}} and the body,
and closes with {{lexema:endFor}}.

The control variable is an **identifier**, not an arbitrary designator: an array element as a control
variable has no educational reading and complicates diagnostics without buying anything.

{{ejemplo:example-esp-control-para}}

## What the counted loop guarantees, step by step

Each point is observable in the trace table, and is therefore fixed and not left to the engine:

1. The initial value, final value, and step are evaluated **exactly once and in that order**. If the
   step is omitted, it is one.
2. If the step is **zero**, a runtime error is emitted and the loop does not execute.
3. The initial value is assigned to the control variable.
4. **The test goes before the body.** With positive step it iterates while the variable is less than or
   equal to the final value; with negative step, while greater than or equal.
5. The body executes.
6. The step is added to the control variable and execution returns to point 4.
7. Upon exit, **the control variable retains the first value that failed the test**.

Three consequences follow: the three values **are frozen**, so modifying inside the body the variable
used as the final value does not change the loop; **the direction is decided by the sign of the step**
and never by the relationship between initial and final values, so a loop whose initial is greater than
its final and whose step is positive simply does not iterate; and the control variable **retains a
defined value upon exit**, because an undefined value is just what a trace table cannot show.

Modifying the control variable inside the body is a warning and not an error. Prohibiting it would
require proving it does not happen, and with pass by reference that is undecidable in general: a warning
is honest, an error that is sometimes not detected is not.

{{ejemplo:example-esp-control-para-garantias}}

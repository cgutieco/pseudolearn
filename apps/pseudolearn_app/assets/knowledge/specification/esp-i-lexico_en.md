# Lexical structure

Before there is a statement there is a text, and the language first decides how that text is split
into pieces. This section fixes what a name is, what a number is, what a quoted text is, where a
statement ends, and what is ignored.

## Identifiers

An identifier starts with a letter or an underscore, and continues with letters, digits or
underscores. Which characters count as letters is fixed by the alphabet of the active profile.

Two identifiers are compared with each other **exactly**: neither case nor accents are ever ignored in
a name written by whoever programs, so `total` and `Total` are two distinct variables.

An identifier may not coincide with a reserved word of the active profile either, and that coincidence
is decided by the case and accent policies of the profile. If the profile accepts `Segun`, `segun` and
`SEGÚN` as the same reserved word, none of the three is free to name a variable. Using one of them
where the language expects a name is a syntax error, and the message points at the word that was
written and the reserved word it collides with.

{{ejemplo:example-esp-lexico-identificadores}}

## The case and accents of the reserved lexicon are another matter

Insensitivity to case and to accents is a profile policy and reaches **only** reserved words,
operators and delimiters. In the reference profile the reserved lexicon is insensitive to both, so two
ways of writing the same reserved word are the same token.

The reason is practical and declared: on a touch keyboard almost nobody types accents, and punishing
that teaches nothing about programming.

{{ejemplo:example-esp-lexico-mayusculas}}

## Reserved words made of several words

The lexicon admits lexemes formed by more than one word, so a profile may define the same construct as
a single word or as two separated by a space. No token crosses a line break.

## Numbers

An integer literal is a sequence of digits. A real literal carries a point as the decimal separator
and **at least one digit on each side**, so neither the form without an integer part nor the form
without a decimal part is a valid literal.

The sign is not part of the literal: it is a unary operator applied to it.

{{ejemplo:example-esp-lexico-numeros}}

## Strings and characters

They are delimited with {{lexema:quote}} or with the single quote, and both forms are accepted because
the educational material students come from uses both interchangeably. The canonical form the language
emits when printing a program is the double quote.

{{ejemplo:example-esp-lexico-cadenas}}

## Comments

A comment runs from the comment marker to the end of the line. The marker is a datum of the profile,
not of the language.

{{ejemplo:example-esp-lexico-comentarios}}

## End of statement

A statement ends at the end of the line. The explicit terminator {{lexema:semicolon}} is **always**
accepted as a separator, which allows several statements to be written on one line; that it is also
mandatory is a rigour flag of the profile, not a rule of the language.

{{ejemplo:example-esp-lexico-fin-sentencia}}

## Whitespace

Spaces, tabs and line breaks separate tokens and are not significant, with the single exception of the
line break as end of statement. **Indentation means nothing**: indenting a block helps to read it and
does not change what the program does.

{{ejemplo:example-esp-lexico-espacios}}

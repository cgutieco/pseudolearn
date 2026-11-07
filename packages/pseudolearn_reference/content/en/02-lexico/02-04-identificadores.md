---
id: lexico.identificadores
numero: "2.4"
tipo: concepto
titulo: Identifiers
anclas: [LANG.LEXICAL.IDENTIFIER#R1, LANG.SOURCE.ENCODING#R2]
terminos: [identifier, name]
---

::: frase
An identifier is the name you choose for a variable, a subroutine or a type: it starts with a letter or an underscore and distinguishes upper case, lower case and accents.
:::

## How it works {#funciona}

An **identifier** starts with a letter (including ñ, accented vowels and ü) or an underscore. After that it may continue with letters, digits or underscores. A single-letter name is valid.

```figura id=identificadores
pie: What may go at the start of a name and what may follow. Digits may follow, never start.
```

Names are compared **exactly**: `edad` and `Edad` are two different variables, just like `ano` and `año`. Reserved words, on the other hand, ignore case: writing them in lower or upper case makes no difference.

```programa id=nombres titulo="Names that look alike"
```

::: limite
Initial alphabet: ASCII letters, ñ, Ñ, accented vowels, ü, Ü and underscore. Following alphabet: the initial one plus the digits 0 to 9. There is no maximum length. A name may not match a reserved word of the profile.
:::

::: docentes
That `edad` and `Edad` are different variables surprises many people, especially because reserved words do ignore case. Ask the class to find the mistake in a program that defines `Total` and then writes `total`.
:::

::: resumen
- Starts with a letter or underscore; continues with letters, digits or underscores.
- ñ, accents and ü are allowed.
- Names distinguish case and accents; reserved words ignore case.
:::

::: vease
- [Reserved words](#lexico.palabras-reservadas)
- [Scope](#subprogramas.ambito)
:::

---
id: lexico.palabras-reservadas
numero: "2.5"
tipo: concepto
titulo: Reserved words
anclas: [LANG.LEXICAL.KEYWORD#R1, LANG.PROFILE.VOCABULARY#R1, LANG.PROFILE.VOCABULARY#R2]
diagnosticos: [reservedLexemeUsedAsName]
terminos: [reserved word, alias, contextual word]
---

::: frase
Reserved words belong to the language itself, such as `If` or `While`; you cannot use them as the name of a variable.
:::

## How it works {#funciona}

Each profile has its list of **reserved words**: those that form the instructions (`If`, `While`, `Write`), the types (`Integer`, `String`), the values (`True`, `False`) and some operators written with letters (`And`, `Or`, `Not`, `Div`, `Mod`). Some are made of several words, such as `Step` or `By Reference`.

```figura id=familias-palabras
pie: Reserved words are grouped by family. Each family's colour is the same one the editor uses.
```

Several words have **aliases**: other spellings the engine recognises and treats the same. In the Spanish profile, `Proceso` is an alias of `Algoritmo` and `Mostrar` of `Escribir`. The engine accepts aliases, but when formatting or translating it converts them to the main form.

```programa id=alias titulo="Accepted aliases"
```

## Contextual words {#contextuales}

Some words are only special in one particular place. For example, `each` only means something inside a for-each loop, and `append` only as a method of a vector. Outside that position they are ordinary names. They are called **contextual words** and do not reserve the name.

::: errores
Using a reserved word as a name produces an error that says which one it is:

```programa id=reservada titulo="A variable named like a reserved word"
```
:::

::: resumen
- Reserved words make up the language and cannot be used as names.
- They ignore case.
- Aliases are accepted and normalised to the main form.
- Contextual words are only special in their position.
:::

::: vease
- [Reserved words in Spanish and English](#apendice.palabras)
- [Identifiers](#lexico.identificadores)
:::

---
id: lectura.perfiles
numero: "0.5"
tipo: concepto
titulo: "Syntax profiles: Spanish and English"
anclas: [LANG.PROFILE.MODEL#R1, LANG.PROFILE.TRANSLATION#R1]
terminos: [profile, vocabulary, translation]
---

::: frase
PseudoLearn has two vocabularies with exactly the same rules: you can program in Spanish or in English and the result is the same.
:::

## How it works {#funciona}

A **syntax profile** is the language of the words of the language. In the Spanish profile you write `Si … Entonces … FinSi`; in the English one, `If … Then … EndIf`. The vocabulary changes and nothing else: precedence, types, index base and the order in which everything is evaluated are the same.

```figura id=perfiles-espejo
pie: The same program in both profiles. Each word has its exact partner; names and texts do not change.
```

The engine can **translate** a program from one profile to the other. Translation changes only the words of the language; it keeps the names you invented, the quoted texts and the comments.

```programa id=saludo titulo="A program in the Spanish profile"
```

This specification can be read with either profile. Programs are written once and the engine translates them; that is why, in the English edition, quoted texts stay in Spanish.

::: nota
The interface language and the syntax profile are different things. You can read the specification in English with programs in the Spanish profile, or the other way round.
:::

## The only visible difference {#diferencia}

There is a single place where the profile changes what you see when running: writing a boolean value. In the Spanish profile `Verdadero` is written and in the English profile `true`. Everything else, numbers included, is written the same way.

::: resumen
- There are two official profiles: Spanish and English.
- They have the same rules; only the words change.
- The engine translates between them without touching names, texts or comments.
- Boolean values are written with the profile's vocabulary.
:::

::: vease
- [Modules and projects](#programas.modulos)
- [Reserved words in Spanish and English](#apendice.palabras)
:::

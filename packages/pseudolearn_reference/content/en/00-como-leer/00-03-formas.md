---
id: lectura.formas
numero: "0.3"
tipo: concepto
titulo: How to read a written form
anclas: [LANG.SYNTAX.GRAMMAR#R1]
terminos: [form, anatomy, optional]
---

::: frase
A written form is the mould of a construct: it says which words are fixed, which slots you fill in and which parts you may leave out.
:::

## How it works {#funciona}

Every language construct is first shown with its form. Coloured words are written exactly as shown. Slots «like this» are replaced by code. Whatever goes between ⟦ and ⟧ is optional: you may write it or not.

```forma
While «condition» Do
  «statements»
EndWhile
```

```figura id=leer-forma
pie: A form has fixed words and slots. Filling the slots gives a line of code; whatever goes between ⟦ and ⟧ you may leave out.
```

When a form has parts that repeat or are optional, it comes with an **anatomy**: a real line of code split into pieces, with the name of each one underneath.

```anatomia
While | word that opens the loop
n <= 3 | condition: checked before every round
Do | word that ends the line
```

This program fills the `While` form with a condition and a statement:

```programa id=cuenta titulo="Filling in the form"
```

::: nota
The form shows the usual way to write a construct, with the names the text uses, such as «condition». The complete grammar, with all its variants, is in the appendix.
:::

::: resumen
- Coloured words: written as they are.
- Slots «like this»: you fill them in.
- ⟦…⟧: optional part.
- An anatomy splits a real example and names each piece.
:::

::: vease
- [Typographic conventions](#lectura.convenciones)
- [Complete grammar](#apendice.gramatica)
:::

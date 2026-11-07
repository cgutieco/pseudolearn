---
id: lectura.formas
numero: "0.3"
tipo: concepto
titulo: How to read a written form
anclas: [LANG.SYNTAX.GRAMMAR#R1]
terminos: [form, syntax diagram, optional]
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

Below the form there is usually a **syntax diagram**. You follow it like a railway track: left to right and top to bottom. Pills are fixed words; dashed boxes are slots; a track that passes underneath something means you may skip it, and a track that loops back means you may repeat it.

```railes produccion=whileLoop
```

```figura id=leer-raíles
pie: The three pieces of a syntax diagram: a fixed stretch, an optional detour and a loop for repeating.
```

This program fills the `While` form with a condition and a statement:

```programa id=cuenta titulo="Filling in the form"
```

::: nota
Syntax diagrams are generated from the official grammar of the language. That is why they sometimes show more general slot names than the form, such as «expression» instead of «condition».
:::

::: resumen
- Coloured words: written as they are.
- Slots «like this»: you fill them in.
- ⟦…⟧: optional part.
- In the rails, a detour underneath may be skipped and a loop may be repeated.
:::

::: vease
- [Typographic conventions](#lectura.convenciones)
- [Complete grammar](#apendice.gramatica)
:::

---
id: lectura.convenciones
numero: "0.2"
tipo: concepto
titulo: Typographic conventions
anclas: [LANG.PROFILE.VOCABULARY#R1]
terminos: [reserved word, slot, pill]
---

::: frase
Everything that belongs to the language looks like code; everything you have to fill in yourself looks like a slot.
:::

## How it works {#funciona}

In English, "if" is an ordinary word and `If` is a word of the language. So they are never confused, every language word inside a paragraph appears as a **pill** with a shaded background and the same colours as the editor: `If`, `While`, `Define age As Integer`.

**Slots** are the places where something you choose goes. They are written between angle quotes, like «condition» or «name». They are never copied as they are: they are replaced by real code.

```figura id=convenciones
pie: The three ways of showing the language: a code pill, a slot and a program block with its output.
```

Complete programs go in numbered blocks. Below each block you see the output the engine produced and how the run ended. The "Try in the editor" button opens it as a new document.

```programa id=edad titulo="A program with its output"
```

## Colours {#colores}

Colours follow the editor. Words that structure the program (`If`, `While`, `Algorithm`) have one colour; subroutine words (`Subroutine`, `Return`) another; object words (`Class`, `New`) a third. Numbers, texts and boolean values have their own. Colour helps, but it is never the only clue: the text always says the same thing without colour.

::: resumen
- Language words appear as code pills.
- Slots «like this» are replaced by your own code.
- Every program shows its real output below.
- The colours are the editor's.
:::

::: vease
- [How to read a written form](#lectura.formas)
- [Reserved words](#lexico.palabras-reservadas)
:::

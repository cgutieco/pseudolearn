---
id: lectura.contenido
numero: "0.1"
tipo: concepto
titulo: What you will find
anclas: [LANG.EDITION.MODEL#R1, LANG.PROGRAM.STRUCTURE#R1]
terminos: [specification, section, part]
---

::: frase
This specification describes the whole PseudoLearn language and its engine, with examples that really run every time it is built.
:::

## How it works {#funciona}

The specification is divided into thirteen parts and six appendices. Each part covers a topic and each section explains a single idea. You can read it from start to finish or jump straight to what you need.

The parts follow the order in which people usually learn to program. First the loose pieces of the text, then data, then instructions, and finally how the engine works inside.

```figura id=mapa-partes
pie: The route through the specification. The parts at the top support the ones below; the appendices are for looking things up.
```

Every program in this specification was run with the real PseudoLearn engine. Below each one you see what it wrote and how it ended. If the engine ever changed its behaviour, the specification would stop building until the text was corrected.

```programa id=hola titulo="The first program"
```

## Reading layers {#capas}

Every section has a body that makes sense without prior knowledge. Around the body there are boxes you can read or skip:

| Box | What it is for |
|---|---|
| In one sentence | The idea of the section summed up in one sentence |
| Exact limit | The precise number when it matters: ranges, sizes, depths |
| Common errors | The real engine messages and how to fix them |
| Inside | What the engine does: intermediate representation and trace |
| For teachers | Typical confusions and questions for the class |

The body never depends on the collapsible boxes. You can skip every "Inside" without losing the thread.

::: nota
This specification explains the language to people. It is not a step-by-step course: the learning path is for that. Nor is it the internal description of the engine's code.
:::

::: resumen
- Thirteen parts ordered from small to large and six reference appendices.
- One idea per section, with a figure, run examples and a summary.
- The collapsible boxes are optional.
- Every example was run with the engine when the specification was built.
:::

::: vease
- [Typographic conventions](#lectura.convenciones)
- [What PseudoLearn is](#vision.que-es)
- [Glossary](#apendice.glosario)
:::

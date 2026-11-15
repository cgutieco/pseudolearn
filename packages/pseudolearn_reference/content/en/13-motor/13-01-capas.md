---
id: motor.capas
numero: "13.1"
tipo: motor
titulo: The engine's layers
anclas: [IR.LOWERING#R1, IR.LOWERING#R2, IR.LOWERING#R3]
terminos: [intermediate representation, virtual machine, compilation]
---

::: frase
The engine processes a program in layers: each one receives the previous result, checks or transforms it and hands it to the next.
:::

## How it works {#funciona}

```figura id=capas-motor
pie: From text to execution. The first three layers analyse; the intermediate representation is where the virtual machine and native code part ways.
```

| Layer | Receives | Delivers |
|---|---|---|
| lexical | text | tokens: words, numbers, signs |
| syntax | tokens | the program tree |
| semantics | tree | tree with types and names resolved |
| intermediate representation | checked tree | blocks of simple instructions |
| virtual machine or native code | intermediate representation | the run |

The **intermediate representation** (IR) is the central piece. Every statement is marked with an entry and an exit, and every decision with its branch: that way execution can account for exactly what happens. Translating to the IR **does not change the meaning**: running it gives the same outputs, in the same order, the language prescribes.

```programa id=pequeno titulo="A small program"
```

```ri programa=pequeno
```

::: resumen
- The engine works in layers: lexical, syntax, semantics, IR and execution.
- The IR marks statements and decisions so execution is observable.
- Translating to the IR keeps the meaning.
:::

::: vease
- [A program's journey](#vision.viaje)
- [Observing execution](#motor.observacion)
- [Native code](#motor.nativo)
:::

---
id: vision.determinismo
numero: "1.4"
tipo: concepto
titulo: "Determinism: the same program always gives the same result"
anclas: [ENG.EXEC.MODEL#R2, MEM.MANAGED.UNOBSERVABLE#R2, LIB.CORE.RANDOM#R1]
terminos: [determinism, seed]
---

::: frase
With the same program, the same inputs and the same seed, the engine always produces the same output, on any computer.
:::

## How it works {#funciona}

A program is **deterministic** if exactly the same thing happens every time you run it. In PseudoLearn this is a guarantee: the output, the way it ends, the diagnostics and the trace are identical on a phone, a laptop or in the browser.

To make that possible, the engine controls everything that could vary:

- **Randomness** comes from a source with a **seed**. Same seed, same sequence of numbers.
- Concurrent **tasks** take turns in a fixed order.
- The **clock**, files and network are requested as capabilities and can be recorded and replayed.
- **Memory** is reclaimed without the program being able to notice.

```figura id=determinismo
pie: Two runs with the same seed produce the same sequence. Changing the seed changes the numbers, not the rules.
```

This specification is always built with seed 42. That is why this program writes the same numbers every time:

```programa id=dados titulo="Three dice rolls"
```

::: analogia
A seed is like the way a deck of cards is shuffled: if two people shuffle exactly the same way, they draw the same cards. The analogy stops working in that the engine shuffles nothing; it computes each number from the previous one.
:::

::: resumen
- Same program, same inputs and same seed: same result.
- Randomness comes from a seeded source.
- Tasks, clock, files and network are controlled so as not to break determinism.
- Memory reclamation cannot be observed.
:::

::: vease
- [Seeded randomness](#biblioteca.azar)
- [Task agenda](#motor.agenda)
- [Effects, host and tape](#motor.efectos)
:::

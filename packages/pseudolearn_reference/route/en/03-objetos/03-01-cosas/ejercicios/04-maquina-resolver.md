---
id: objetos.cosas.maquina-resolver
leccion: objetos.cosas
tipo: resolver
nivel: brote
obligatorio: false
titulo: The sales of the two machines
---

::: enunciado
Each machine starts with 10 cans and charges 3 pesos per can. Read machine numbers, 1 or 2, one per sale, until a 0. A sale at a machine without cans is not made and is reported with «Máquina 1 sin latas» (or 2). At the end show `Máquina 1: ` and `Máquina 2: ` with their cans and money, as in the lesson: `Máquina 1: 8 latas, 6 pesos`.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. How many objects are needed? What decides which one is asked for the sale?
2. Use the machine class of [the lesson](ruta:objetos.cosas).
3. Create two machines; in the loop, the number read chooses which one to ask for `Vender()`.
4. While the number is not 0, if it is 1 sell at the first one and otherwise at the second; at the end show both states. Close with the variant.
:::

::: variante
Add a method `Cargar(latas)` and a code 3 that loads 5 cans into the machine with fewer.
:::

::: docentes
Hidden cases: sales at a single machine, a machine that runs out of cans (the two extra sales only report) and alternating sales.
:::

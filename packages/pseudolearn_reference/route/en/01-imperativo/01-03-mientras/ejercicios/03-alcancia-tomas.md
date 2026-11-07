---
id: imperativo.mientras.alcancia-tomas
leccion: imperativo.mientras
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Tomás's money box
---

::: enunciado
Tomás wrote his version of the money box. With price 50 it shows «Día 9 con 54 monedas», the same as yours. But it is wrong. Find a price it gets wrong.
:::

```programa rol=defectuoso
```

```programa rol=referencia
```

```casos
```

```rompe
```

::: pistas
1. Go back to the problem card. Which of the worked examples is an edge case?
2. Compare Tomás's condition with yours. When do those two questions give different answers?
3. Try a price that Lucía can gather exactly.
4. With price 54 Tomás says «Día 10 con 65 monedas»; with price 2, «Día 2 con 5». Close with the variant.
:::

::: variante
Fix Tomás's condition by changing a single sign.
:::

::: docentes
The prices that are gathered exactly break Tomás's version: 2, 5, 9, 14, 20, 27, 35, 44, 54. The app runs the proposed price in both versions and accepts it if they differ.
:::

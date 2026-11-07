---
id: imperativo.decidir.cine-romper
leccion: imperativo.decidir
tipo: romperlo
nivel: brote
obligatorio: true
titulo: The other school's cinema
---

::: enunciado
Another school's cinema charges the same as ours: under 12, 5 pesos; everyone else, 8. Their program gets it right with 10 and with 30 years. Find an age it charges wrongly.
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
1. Draw the cinema partition. Which cases did they already test, and which zone was left untested?
2. Errors hide at the edges. Test both sides of the edge.
3. With 11 both programs charge 5. And with the next number?
4. With 12 years the program charges 5 and should charge 8. Close with the variant.
:::

::: variante
Fix the program by changing a single sign, without changing the texts. (With `>=`.)
:::

::: docentes
Only 12 breaks this program: it is the only whole number where `> 12` and `>= 12` differ. That is why one case on each side of the edge is compulsory.
:::

---
id: procedimental.datos.votacion
leccion: procedimental.datos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Electing delegates
---

::: enunciado
Delegates are voted for by writing names, one per vote, until the word `fin`. Show the winner and their votes, separated by a space. If there is a tie, the first in alphabetical order wins. If there were no votes, show «Sin votos».
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. What do you have to remember about each name while the votes arrive?
2. It is the contact list of [the lesson](ruta:procedimental.datos), which counted birthdays per month: here votes per name are counted.
3. First count with a dictionary; then walk through its keys looking for the greatest. What happens in a tie?
4. Replace the winner if they have more votes, or the same and a name that comes first. Close with the variant.
:::

::: variante
Show the full result: each candidate with their votes, in the order in which they got their first one.
:::

::: docentes
Hidden cases: a tie (Beto and Ana with 1: Ana wins), no votes, a tie between two with more votes and a clear winner. Frequent mistake: keeping the first one walked through in a tie, which depends on the order of arrival.
:::

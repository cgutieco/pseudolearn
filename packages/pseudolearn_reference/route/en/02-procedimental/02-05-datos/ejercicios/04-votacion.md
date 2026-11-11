---
id: procedimental.datos.votacion
leccion: procedimental.datos
tipo: resolver
nivel: brote
obligatorio: true
titulo: Electing delegates
---

::: enunciado
Delegates are voted for by writing names, one per vote, until the word `end`. Show the winner and their votes, separated by a space. If there is a tie, the first in alphabetical order wins. If there were no votes, show «No votes».
:::

```programa rol=referencia
Algoritmo Voting
  Definir votes Como Diccionario<Cadena, Entero> <- Diccionario();
  Definir name Como Cadena;
  Leer name;
  Mientras name <> "end" Hacer
    Segun votes.Buscar(name) Hacer
      Algo(count): votes[name] <- count + 1;
      Nada: votes[name] <- 1;
    FinSegun
    Leer name;
  FinMientras
  Definir winner Como Cadena <- "";
  Definir highest Como Entero <- 0;
  Para Cada candidate En votes.Claves() Hacer
    Si votes[candidate] > highest O (votes[candidate] = highest Y candidate < winner) Entonces
      winner <- candidate;
      highest <- votes[candidate];
    FinSi
  FinPara
  Si highest = 0 Entonces
    Escribir "No votes";
  Sino
    Escribir winner, " ", highest;
  FinSi
FinAlgoritmo
```

```casos
visible | Ana ; Beto ; Ana ; end | Ana 2
visible | Caro ; end | Caro 1
oculto | Beto ; Ana ; end | Ana 1
oculto | end | No votes
oculto | Dani ; Caro ; Dani ; Caro ; Beto ; end | Caro 2
oculto | Eva ; Eva ; Eva ; Ana ; end | Eva 3
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

::: explicacion
Hidden cases: a tie (Beto and Ana with 1: Ana wins), no votes, a tie between two with more votes and a clear winner. Frequent mistake: keeping the first one walked through in a tie, which depends on the order of arrival.
:::

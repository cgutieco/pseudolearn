---
id: imperativo.cuadriculas.raya-romper
leccion: imperativo.cuadriculas
tipo: romperlo
nivel: brote
obligatorio: true
titulo: A line that gets away
---

::: enunciado
This noughts and crosses program gets the lesson's board right. Find a board it gets wrong.
:::

```programa rol=defectuoso
Algoritmo NoughtsAndCrosses
  Dimension t[3, 3] Como Entero;
  Para r <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer t[r, c];
    FinPara
  FinPara
  Definir winner Como Entero <- 0;
  Para i <- 0 Hasta 2 Hacer
    Si t[i, 0] <> 0 Y t[i, 0] = t[i, 1] Y t[i, 1] = t[i, 2] Entonces
      winner <- t[i, 0];
    FinSi
    Si t[0, i] <> 0 Y t[0, i] = t[1, i] Y t[1, i] = t[2, i] Entonces
      winner <- t[0, i];
    FinSi
  FinPara
  Si t[1, 1] <> 0 Y t[0, 0] = t[1, 1] Y t[1, 1] = t[2, 2] Entonces
    winner <- t[1, 1];
  FinSi
  Segun winner Hacer
    1:
      Escribir "X wins";
    2:
      Escribir "O wins";
    De Otro Modo:
      Escribir "Nobody";
  FinSegun
FinAlgoritmo
```

```programa rol=referencia
Algoritmo NoughtsAndCrosses
  Dimension t[3, 3] Como Entero;
  Para r <- 0 Hasta 2 Hacer
    Para c <- 0 Hasta 2 Hacer
      Leer t[r, c];
    FinPara
  FinPara
  Definir winner Como Entero <- 0;
  Para i <- 0 Hasta 2 Hacer
    Si t[i, 0] <> 0 Y t[i, 0] = t[i, 1] Y t[i, 1] = t[i, 2] Entonces
      winner <- t[i, 0];
    FinSi
    Si t[0, i] <> 0 Y t[0, i] = t[1, i] Y t[1, i] = t[2, i] Entonces
      winner <- t[0, i];
    FinSi
  FinPara
  Si t[1, 1] <> 0 Y t[0, 0] = t[1, 1] Y t[1, 1] = t[2, 2] Entonces
    winner <- t[1, 1];
  FinSi
  Si t[1, 1] <> 0 Y t[0, 2] = t[1, 1] Y t[1, 1] = t[2, 0] Entonces
    winner <- t[1, 1];
  FinSi
  Segun winner Hacer
    1:
      Escribir "X wins";
    2:
      Escribir "O wins";
    De Otro Modo:
      Escribir "Nobody";
  FinSegun
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 1 ; 2 ; 1 ; 2 ; 2 ; 1 ; 1 | X wins
```

```rompe
2 ; 0 ; 1 ; 0 ; 1 ; 0 ; 1 ; 0 ; 2
0 ; 0 ; 2 ; 0 ; 2 ; 0 ; 2 ; 1 ; 1
```

::: pistas
1. Count the ways of winning this program checks. Are there eight?
2. Compare with the figure in the lesson: which line of the board does it not check?
3. Build a board where someone wins only by that line.
4. With X in cells [0, 2], [1, 1] and [2, 0], the program says «Nobody». Close with the variant.
:::

::: variante
Build a board where this program gives the right winner even though the other diagonal is complete. (One that also has a full row of the same player.)
:::

::: explicacion
The program is missing the diagonal from the top right corner to the bottom left. Any board won only by that diagonal breaks it.
:::

---
id: imperativo.esquemas.olas-romper
leccion: imperativo.esquemas
tipo: romperlo
nivel: brote
obligatorio: true
titulo: The waves that get away
---

::: enunciado
This heat wave program gets the lesson's case right. Find 14 temperatures it gets wrong.
:::

```programa rol=defectuoso
Algoritmo Waves
  Dimension t[14] Como Entero;
  Para i <- 0 Hasta 13 Hacer
    Leer t[i];
  FinPara
  Definir streak Como Entero <- 0;
  Definir waves Como Entero <- 0;
  Definir longest Como Entero <- 0;
  Para Cada temperature En t Hacer
    Si temperature > 30 Entonces
      streak <- streak + 1;
    Sino
      Si streak >= 3 Entonces
        waves <- waves + 1;
        Si streak > longest Entonces
          longest <- streak;
        FinSi
      FinSi
      streak <- 0;
    FinSi
  FinPara
  Escribir "Waves: ", waves;
  Escribir "Longest: ", longest;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Waves
  Dimension t[14] Como Entero;
  Para i <- 0 Hasta 13 Hacer
    Leer t[i];
  FinPara
  Definir streak Como Entero <- 0;
  Definir waves Como Entero <- 0;
  Definir longest Como Entero <- 0;
  Para Cada temperature En t Hacer
    Si temperature > 30 Entonces
      streak <- streak + 1;
    Sino
      Si streak >= 3 Entonces
        waves <- waves + 1;
        Si streak > longest Entonces
          longest <- streak;
        FinSi
      FinSi
      streak <- 0;
    FinSi
  FinPara
  Si streak >= 3 Entonces
    waves <- waves + 1;
    Si streak > longest Entonces
      longest <- streak;
    FinSi
  FinSi
  Escribir "Waves: ", waves;
  Escribir "Longest: ", longest;
FinAlgoritmo
```

```casos
visible | 28 ; 31 ; 32 ; 33 ; 29 ; 31 ; 30 ; 31 ; 32 ; 31 ; 35 ; 27 ; 31 ; 32 | Waves: 2 ⏎ Longest: 4
```

```rompe
28 ; 29 ; 28 ; 29 ; 28 ; 29 ; 28 ; 29 ; 28 ; 29 ; 28 ; 31 ; 32 ; 33
31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31 ; 31
```

::: pistas
1. Go back to the card in the lesson. Which edge case does the task's example not test?
2. Compare both programs. Which part of the lesson is this one missing?
3. Look for a wave that has not broken yet when the data runs out.
4. With the last three days above 30, the good one says one wave of 3 and this one says 0. Close with the variant.
:::

::: variante
What does this program show if all 14 days are above 30? (Waves: 0. The good one says a wave of 14.)
:::

::: explicacion
The program is missing the closing of the last streak after the loop. Any series whose last streak of 3 or more days reaches the end breaks it.
:::

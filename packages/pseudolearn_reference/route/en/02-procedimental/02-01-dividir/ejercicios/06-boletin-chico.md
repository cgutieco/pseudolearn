---
id: procedimental.dividir.boletin-chico
leccion: procedimental.dividir
tipo: resolver
nivel: arbol
obligatorio: false
titulo: A smaller report card
---

::: enunciado
Three pupils have two marks each. Read, for each pupil, their name and their two marks. Show one line per pupil in the format `Ana: 7.5 passed` (a pupil passes with an average of 6 or more, otherwise `failed`) and at the end `Best average: ` with the name. If there is a tie for the best average, the first one read wins.
:::

```programa rol=referencia
SubProceso Average(a Como Entero, b Como Entero) Como Real
  Retornar (a + b) / 2;
FinSubProceso

SubProceso Estado(average Como Real) Como Cadena
  Si average >= 6 Entonces
    Retornar "passed";
  FinSi
  Retornar "failed";
FinSubProceso

Algoritmo ReportCard
  Definir name Como Cadena;
  Definir m1, m2 Como Entero;
  Definir bestName Como Cadena <- "";
  Definir bestAverage Como Real <- -1.0;
  Para i <- 1 Hasta 3 Hacer
    Leer name;
    Leer m1;
    Leer m2;
    Definir avg Como Real <- Average(m1, m2);
    Escribir name, ": ", avg, " ", Estado(avg);
    Si avg > bestAverage Entonces
      bestAverage <- avg;
      bestName <- name;
    FinSi
  FinPara
  Escribir "Best average: ", bestName;
FinAlgoritmo
```

```casos
visible | Ana ; 7 ; 8 ; Beto ; 5 ; 4 ; Caro ; 9 ; 10 | Ana: 7.5 passed ⏎ Beto: 4.5 failed ⏎ Caro: 9.5 passed ⏎ Best average: Caro
visible | Eva ; 6 ; 6 ; Fede ; 5 ; 7 ; Gabi ; 6 ; 5 | Eva: 6.0 passed ⏎ Fede: 6.0 passed ⏎ Gabi: 5.5 failed ⏎ Best average: Eva
oculto | Ana ; 8 ; 8 ; Beto ; 8 ; 8 ; Caro ; 1 ; 1 | Ana: 8.0 passed ⏎ Beto: 8.0 passed ⏎ Caro: 1.0 failed ⏎ Best average: Ana
oculto | Ana ; 0 ; 0 ; Beto ; 0 ; 0 ; Caro ; 0 ; 1 | Ana: 0.0 failed ⏎ Beto: 0.0 failed ⏎ Caro: 0.5 failed ⏎ Best average: Caro
oculto | Ana ; 10 ; 10 ; Beto ; 9 ; 9 ; Caro ; 6 ; 5 | Ana: 10.0 passed ⏎ Beto: 9.0 passed ⏎ Caro: 5.5 failed ⏎ Best average: Ana
```

::: pistas
1. Draw the decomposition tree of this report card. Which branches does it have?
2. It is the report card of [the lesson](ruta:procedimental.dividir) with two marks and three pupils.
3. One subprogram for the average, another for the status and the best so far in the main one. Which sign respects the tie?
4. Replace the best only if the new average is strictly greater. Close with the variant.
:::

::: variante
If there is a tie, show all the tied names.
:::

::: explicacion
The first one wins the tie because the comparison is strict. Hidden cases: a tie for first place, everyone failing and an average of exactly 6.0 in the second visible case.
:::

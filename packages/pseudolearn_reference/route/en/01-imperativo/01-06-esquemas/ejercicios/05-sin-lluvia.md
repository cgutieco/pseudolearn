---
id: imperativo.esquemas.sin-lluvia
leccion: imperativo.esquemas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The dry streak
---

::: enunciado
Read 10 days: 1 if it rained and 0 if not. Show how many days the longest streak without rain lasted. The program shows only the number.
:::

```programa rol=referencia
Algoritmo NoRain
  Dimension days[10] Como Entero;
  Para i <- 0 Hasta 9 Hacer
    Leer days[i];
  FinPara
  Definir streak Como Entero <- 0;
  Definir longest Como Entero <- 0;
  Para Cada rained En days Hacer
    Si rained = 0 Entonces
      streak <- streak + 1;
      Si streak > longest Entonces
        longest <- streak;
      FinSi
    Sino
      streak <- 0;
    FinSi
  FinPara
  Escribir longest;
FinAlgoritmo
```

```casos
visible | 0 ; 0 ; 1 ; 0 ; 0 ; 0 ; 1 ; 1 ; 0 ; 0 | 3
visible | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 | 0
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 10
oculto | 1 ; 0 ; 0 ; 0 ; 0 ; 1 ; 0 ; 1 ; 0 ; 0 | 4
oculto | 0 ; 1 ; 0 ; 1 ; 0 ; 1 ; 0 ; 1 ; 0 ; 0 | 2
```

::: pistas
1. It is a relative of the heat waves in [the lesson](ruta:imperativo.esquemas). What changes?
2. One box follows the current streak and another remembers the longest.
3. If you update the longest on each dry day, there is no need to check anything after the loop.
4. Dry: the streak goes up and, if it passes the longest, replaces it. Rain: the streak goes back to 0. Close with the variant.
:::

::: variante
Also show on which day the longest streak started.
:::

::: explicacion
Updating the longest inside the dry branch avoids the last streak error. Hidden cases: ten dry days and the longest streak at the end.
:::

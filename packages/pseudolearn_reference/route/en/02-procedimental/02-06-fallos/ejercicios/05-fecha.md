---
id: procedimental.fallos.fecha
leccion: procedimental.fallos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Is it a valid date?
---

::: enunciado
Read a day and a month of a year that is not a leap year, in that order. Show «valid», «day out of range» or «month out of range». If the month does not exist, that is the reason, even if the day is also wrong.
:::

```programa rol=referencia
SubProceso DaysInMonth(month Como Entero) Como Entero
  Segun month Hacer
    2:
      Retornar 28;
    4, 6, 9, 11:
      Retornar 30;
    De Otro Modo:
      Retornar 31;
  FinSegun
FinSubProceso

SubProceso ValidateDate(day Como Entero, month Como Entero) Como Resultado<Entero, Cadena>
  Si month < 1 O month > 12 Entonces
    Retornar Error("month out of range");
  FinSi
  Si day < 1 O day > DaysInMonth(month) Entonces
    Retornar Error("day out of range");
  FinSi
  Retornar Exito(day);
FinSubProceso

Algoritmo DateCheck
  Definir day, month Como Entero;
  Leer day;
  Leer month;
  Segun ValidateDate(day, month) Hacer
    Exito(parsed): Escribir "valid";
    Error(reason): Escribir reason;
  FinSegun
FinAlgoritmo
```

```casos
visible | 31 ; 4 | day out of range
visible | 15 ; 13 | month out of range
oculto | 29 ; 2 | day out of range
oculto | 31 ; 12 | valid
oculto | 30 ; 4 | valid
oculto | 0 ; 5 | day out of range
oculto | 0 ; 13 | month out of range
```

::: pistas
1. How many days does each month have? Which is validated first, the day or the month?
2. They are the two filters in a row of [the lesson](ruta:procedimental.fallos).
3. One subprogram says how many days a month has; another applies the filters and returns the reason of the first one that fails.
4. First the month between 1 and 12; then the day between 1 and the days of that month. Close with the variant.
:::

::: variante
Add the year and take into account the leap years of [lesson 1.2](ruta:imperativo.caminos).
:::

::: explicacion
Hidden cases: 29 February, the edges of April and December, day 0 and a case with both values wrong, where the month rules.
:::

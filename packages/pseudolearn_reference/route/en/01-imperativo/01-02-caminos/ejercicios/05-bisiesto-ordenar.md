---
id: imperativo.caminos.bisiesto-ordenar
leccion: imperativo.caminos
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordering the leap year
---

::: enunciado
The lines of a program that decides whether a year is a leap year are mixed up. Put them in order so that it works.
:::

```programa rol=referencia
Algoritmo LeapYear
  Definir anio Como Entero;
  Leer anio;
  Si anio mod 400 = 0 Entonces
    Escribir "Leap year";
  Sino
    Si anio mod 100 = 0 Entonces
      Escribir "Not a leap year";
    Sino
      Si anio mod 4 = 0 Entonces
        Escribir "Leap year";
      Sino
        Escribir "Not a leap year";
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | 2024 | Leap year
visible | 2023 | Not a leap year
oculto | 1900 | Not a leap year
oculto | 2000 | Leap year
```

::: explicacion
The questions go from the most specific to the most general: 400 first, then 100 and 4 at the end. Each `If` is closed by its own `EndIf`, from the inside out.
:::

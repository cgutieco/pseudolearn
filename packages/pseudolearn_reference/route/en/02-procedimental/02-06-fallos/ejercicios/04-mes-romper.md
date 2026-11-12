---
id: procedimental.fallos.mes-romper
leccion: procedimental.fallos
tipo: romperlo
nivel: brote
obligatorio: true
titulo: One month too many
---

::: enunciado
This program validates a month number: it shows «valid» or «invalid». It gets 5 and 13 right. Find a number it gets wrong.
:::

```programa rol=defectuoso
Algoritmo MonthCheck
  Definir month Como Entero;
  Leer month;
  Si month >= 0 Y month <= 12 Entonces
    Escribir "valid";
  Sino
    Escribir "invalid";
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Algoritmo MonthCheck
  Definir month Como Entero;
  Leer month;
  Si month >= 1 Y month <= 12 Entonces
    Escribir "valid";
  Sino
    Escribir "invalid";
  FinSi
FinAlgoritmo
```

```casos
visible | 5 | valid
visible | 13 | invalid
```

```rompe
0
```

::: pistas
1. Which numbers are months? Draw the partition and mark the edges.
2. They tested a case in the middle and one outside at the top. Which edge did they not test?
3. Test both sides of the bottom edge.
4. With 0 the program says «valid», and there is no month 0. Close with the variant.
:::

::: variante
Fix the validation by changing a single number.
:::

::: explicacion
Only 0 breaks this program: the negatives are already left out. It is the edge error of [lesson 1.1](ruta:imperativo.decidir), now inside a validation.
:::

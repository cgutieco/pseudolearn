---
id: imperativo.caminos.bisiesto-romper
leccion: imperativo.caminos
tipo: romperlo
nivel: brote
obligatorio: true
titulo: A leap year that is too simple
---

::: enunciado
This program gets 2024 and 2023 right. Find a year it gets wrong.
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
1. Look at the decision table in the lesson. Which columns does this program not test?
2. The program asks a single question. Which part of the rule is missing?
3. Look for a year that divides by 4 and also by 100, but not by 400.
4. With 1900 it says «Es bisiesto» and it is not. Close with the variant.
:::

::: variante
Is there a year this program marks as not a leap year that actually is one? (No: every leap year divides by 4.)
:::

::: docentes
The years that divide by 100 and not by 400 break the program: 1900, 2100, 2200. 2000 does not break it, because the program gets it right by chance.
:::

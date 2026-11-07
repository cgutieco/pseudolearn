---
id: imperativo.caminos.bisiesto-romper
leccion: imperativo.caminos
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Un bisiesto demasiado simple
---

::: enunciado
Este programa acierta con 2024 y con 2023. Encuentra un año con el que se equivoque.
:::

```programa rol=defectuoso
Algoritmo Bisiesto
  Definir anio Como Entero;
  Leer anio;
  Si anio mod 4 = 0 Entonces
    Escribir "Es bisiesto";
  Sino
    Escribir "No es bisiesto";
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Bisiesto
  Definir anio Como Entero;
  Leer anio;
  Si (anio mod 4 = 0 Y anio mod 100 <> 0) O anio mod 400 = 0 Entonces
    Escribir "Es bisiesto";
  Sino
    Escribir "No es bisiesto";
  FinSi
FinAlgoritmo
```

```casos
visible | 2024 | Es bisiesto
visible | 2023 | No es bisiesto
```

```rompe
1900
2100
```

::: pistas
1. Mira la tabla de decisión de la lección. ¿Qué columnas no prueba este programa?
2. El programa hace una sola pregunta. ¿Qué parte de la regla falta?
3. Busca un año que se divida entre 4 y también entre 100, pero no entre 400.
4. Con 1900 dice «Es bisiesto» y no lo es. Cierra con la variante.
:::

::: variante
¿Hay algún año que este programa marque como no bisiesto y sí lo sea? (No: todo bisiesto se divide entre 4.)
:::

::: docentes
Rompen el programa los años que se dividen entre 100 y no entre 400: 1900, 2100, 2200. 2000 no lo rompe, porque el programa acierta por casualidad.
:::

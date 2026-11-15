---
id: imperativo.caminos.bisiesto-ordenar
leccion: imperativo.caminos
tipo: ordenar
nivel: brote
obligatorio: false
titulo: Ordenar el bisiesto
---

::: enunciado
Las líneas de un programa que decide si un año es bisiesto están mezcladas. Ordénalas para que funcione.
:::

```programa rol=referencia
Algoritmo Bisiesto
  Definir anio Como Entero;
  Leer anio;
  Si anio mod 400 = 0 Entonces
    Escribir "Es bisiesto";
  Sino
    Si anio mod 100 = 0 Entonces
      Escribir "No es bisiesto";
    Sino
      Si anio mod 4 = 0 Entonces
        Escribir "Es bisiesto";
      Sino
        Escribir "No es bisiesto";
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | 2024 | Es bisiesto
visible | 2023 | No es bisiesto
oculto | 1900 | No es bisiesto
oculto | 2000 | Es bisiesto
```

::: explicacion
Las preguntas van de la más específica a la más general: primero 400, después 100 y al final 4. Cada `Si` se cierra con su propio `FinSi`, de adentro hacia afuera.
:::

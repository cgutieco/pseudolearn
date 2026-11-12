---
id: imperativo.caminos.compuesta
leccion: imperativo.caminos
tipo: predecir
nivel: semilla
obligatorio: false
titulo: Both or just one?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
Algoritmo Compound
  Si 5 > 3 Y 2 > 4 Entonces
    Escribir "A";
  Sino
    Escribir "B";
  FinSi
  Si 5 > 3 O 2 > 4 Entonces
    Escribir "A";
  Sino
    Escribir "B";
  FinSi
FinAlgoritmo
```

```salida
B
A
```

::: explicacion
`5 > 3` is true and `2 > 4` is false. With `And` both are needed: the first decision goes through `Else`. With `Or` one is enough: the second goes through `Then`.
:::

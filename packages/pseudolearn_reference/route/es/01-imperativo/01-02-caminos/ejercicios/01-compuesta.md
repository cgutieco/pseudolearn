---
id: imperativo.caminos.compuesta
leccion: imperativo.caminos
tipo: predecir
nivel: semilla
obligatorio: false
titulo: ¿Las dos o una sola?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo Compuesta
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
`5 > 3` es verdadera y `2 > 4` es falsa. Con `Y` hacen falta las dos: la primera decisión va por `Sino`. Con `O` alcanza una: la segunda va por `Entonces`.
:::

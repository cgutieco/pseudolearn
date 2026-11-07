---
id: imperativo.mientras.promedio-profesora
leccion: imperativo.mientras
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The teacher's average
---

::: enunciado
The teacher dictates the exam marks one by one. When she finishes, she says -1. The program shows the average of the marks; if she dictated none, it shows «No hay notas».
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Which value warns that the marks are over? Which two things do you need to know to compute an average?
2. It is [the dictated money box](ruta:imperativo.mientras) with one more box.
3. One box for the sum and another for the amount. Before dividing, what happens if the amount is zero?
4. Read, add and count until -1; then, if the amount is 0 show «No hay notas» and otherwise the sum divided by the amount. Close with the variant.
:::

::: variante
Also show the highest mark. (You will need it in the next lesson.)
:::

::: docentes
Without checking the amount, the «-1 straight away» case stops with a division by zero. The marks 0 and 0 check that the signal is not confused with a low mark.
:::

---
id: concurrente.tareas.doble-romper
leccion: concurrente.tareas
tipo: romperlo
nivel: arbol
obligatorio: false
titulo: A hurried sum
---

::: enunciado
This program computes in two tasks the double and the triple of a number and shows the sum. With 0 it is right. Find a number it gets wrong.
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
1. When is the sum shown, and when is the triple awaited?
2. The sum uses a provisional value instead of the result of the second task.
3. That provisional value is 0: the program is only right when the triple is also 0.
4. With 4 it shows 8 instead of 20. Close with the variant.
:::

::: variante
Which line has to be moved for the program to be right?
:::

::: docentes
Any number other than 0 breaks it. It is the error of using a result before awaiting it: the provisional value hides the missing wait.
:::

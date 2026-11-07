---
id: imperativo.arreglos.semana-error
leccion: imperativo.arreglos
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The week that ends badly
---

::: enunciado
The program reads the 7 temperatures of the week and shows their sum, but it stops before showing it. Find the error and fix it.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Is it a compile error, a runtime error or a logic error? On which pass does it stop?
2. Count the passes of the loop: how many does it make, and how many cells does the array have?
3. If the array has 7 cells, which is the last index that exists?
4. The loop has to go from 0 to 6. Close with the variant.
:::

::: variante
Write the loop so that it works with any size, keeping the size in a box with a name.
:::

::: docentes
The loop makes 8 passes for 7 cells: on the eighth it asks for cell 7, which does not exist, and the program stops out of range. Frequent mistake: fixing it with an array of 8.
:::

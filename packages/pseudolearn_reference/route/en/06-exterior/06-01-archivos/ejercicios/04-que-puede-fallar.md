---
id: exterior.archivos.que-puede-fallar
leccion: exterior.archivos
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Outside or inside?
---

::: enunciado
Place each step of the inventory: can it fail outside the program, or is it calculation?
:::

```categorias
- Can fail outside
- Is calculation
```

```elementos
- Opening the stock file. | Can fail outside
- Adding up the stock of the five products. | Is calculation
- Asking for permission to use the folder. | Can fail outside
- Building the line «juice;10». | Is calculation
```

::: explicacion
What touches the world can fail for reasons the program does not control: a missing file, a folder without permission. The calculation depends only on its data.
:::

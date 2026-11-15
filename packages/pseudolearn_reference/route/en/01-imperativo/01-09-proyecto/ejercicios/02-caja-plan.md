---
id: imperativo.proyecto.caja-plan
leccion: imperativo.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: The till plan
---

::: enunciado
These are the steps of the till plan, mixed up. Put them in order.
:::

```pasos
- Prepare the names, the prices and the units sold of each product.
- Read the first code.
- While the code is not 0: check it, read the amount, write the line, add to the total and to the units, and read the next code.
- Compute the total with discount.
- Search for the best-selling product.
- Write the closing of the receipt.
```

::: explicacion
The fixed values are prepared before reading anything. The first code is read before the loop so that the question has something to look at. The discount and the best seller are computed when there are no sales left.
:::

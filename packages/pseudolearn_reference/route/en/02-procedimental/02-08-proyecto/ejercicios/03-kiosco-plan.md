---
id: procedimental.proyecto.kiosco-plan
leccion: procedimental.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: The plan of the till with stock
---

::: enunciado
These are the steps of the plan of the till with stock, mixed up. Put them in order.
:::

```pasos
- Prepare the catalogue with the initial stock of each product.
- Read the first code.
- While the code is not 0: read the amount, check the code, the amount and the stock, take off the stock and add to the total, write the line or the rejection, and read the next code.
- Compute the total with discount.
- Write the closing and the final stock.
```

::: explicacion
The catalogue is prepared before reading. The loop checks before touching the stock, so that a rejected sale does not change it. The discount and the closing go when there are no sales left.
:::

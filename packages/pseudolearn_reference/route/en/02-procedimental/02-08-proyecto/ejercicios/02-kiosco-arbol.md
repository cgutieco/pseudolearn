---
id: procedimental.proyecto.kiosco-arbol
leccion: procedimental.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: The till tree
---

::: enunciado
The decomposition tree of the till has three branches: read and check the sale, register the sale and close the day. Place each job in its branch.
:::

```categorias
- Read and check the sale
- Register the sale
- Close the day
```

```elementos
- Read the code and the amount. | Read and check the sale
- Check the code, the amount and the stock. | Read and check the sale
- Compute the price. | Register the sale
- Take off the stock. | Register the sale
- Write the receipt line. | Register the sale
- Compute the discount. | Close the day
- Write the total. | Close the day
- Write the final stock. | Close the day
```

::: explicacion
Each branch can be written and tested separately: the checks do not need to know how the receipt is printed, and the closing does not need to know how each sale was read.
:::

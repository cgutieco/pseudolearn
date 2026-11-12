---
id: objetos.proyecto.objetos-plan
leccion: objetos.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: The plan of the kiosk with objects
---

::: enunciado
These are the steps of the plan of the kiosk shared out into pieces, mixed up. Put them in order.
:::

```pasos
- Create the product catalogue, the inventory with its initial stock and the till.
- Read the first code.
- While the code is not 0: read the amount, check the code and the amount, ask the inventory to take away if there is enough, add the price in the till, write the line or the rejection, and read the next code.
- Read the payment method.
- Write the total and the total with discount.
- Ask the payment method to charge the total with discount and write it.
- Write the final stock.
```

::: explicacion
The pieces are created before reading. The payment method is read when closing, because the customer chooses it at the end. The payment is asked of the payment method, which is the one that knows whether there is a surcharge.
:::

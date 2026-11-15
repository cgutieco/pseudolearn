---
id: exterior.proyecto.final-plan
leccion: exterior.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: The plan of the complete kiosk
---

::: enunciado
These are the steps of the plan of the complete kiosk, mixed up. Put them in order.
:::

```pasos
- Load the saved inventory, or use the initial stock if there is none.
- Read the sales until 0, checking the code and the stock of each one.
- Compute the total and the total with discount.
- Build the JSON text of the new inventory.
- Save the text into the file, with a deferred cleanup that closes it.
- Show the ticket.
```

::: explicacion
The edge loads at the start and saves at the end; in the middle, the core sells and computes. The JSON text is built before saving it, because saving only writes what is already ready.
:::

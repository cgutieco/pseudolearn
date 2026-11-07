---
id: funcional.tipos-dominio.describir-resolver
leccion: funcional.tipos-dominio
tipo: resolver
nivel: brote
obligatorio: true
titulo: Building and describing an order
---

::: enunciado
Read a state code and its data: 1 pending, with no data; 2 on its way, with the courier; 3 delivered, with the courier and the time; 4 cancelled, with the reason. Build the order and show its description, as in the lesson: «En camino con Sol».
:::

::: restriccion
The order is a variant with one shape per state, and the description is a function with a `Switch`.
:::

```programa rol=referencia
```

```casos
```

::: pistas
1. Which data does each state carry? How many shapes does the order have?
2. Use the variant and `Describir` of [the lesson](ruta:funcional.tipos-dominio).
3. Read the code; according to the code, read the matching data and build the shape.
4. A `Switch codigo` that builds `Pedido.EnCamino`, `Pedido.Entregado` or `Pedido.Cancelado`, and finally `Describir`. Close with the variant.
:::

::: variante
Add state 5, returned with a reason. What does the engine warn you about?
:::

::: docentes
The app's catalogue of checks cannot require a variant; the restriction asks for it. Hidden cases: the four states.
:::

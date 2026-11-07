---
id: objetos.proyecto.objetos-tarjetas
leccion: objetos.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: The cards of the kiosk with objects
---

::: enunciado
Place each kiosk responsibility in the piece whose job it is.
:::

```categorias
- Producto
- Inventario
- MedioDePago
- Caja
- Ticket
```

```elementos
- Knowing its name and price. | Producto
- Computing the amount of a quantity. | Producto
- Knowing how much is left of each product. | Inventario
- Taking away from the stock only if there is enough. | Inventario
- Charging an amount with or without surcharge. | MedioDePago
- Gathering the total of the sales. | Caja
- Applying the discount to the total. | Caja
- Writing one line per sale. | Ticket
- Writing the rejections with their reason. | Ticket
- Writing the final stock. | Ticket
```

::: explicacion
Each responsibility goes to whoever has the information: the price, the stock, the way of charging and the total live in different pieces. What is shown is the receipt's job, even if in a small program it can stay in the main algorithm.
:::

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
- Product
- Inventory
- MedioDePago
- Till
- Receipt
```

```elementos
- Knowing its name and price. | Product
- Computing the amount of a quantity. | Product
- Knowing how much is left of each product. | Inventory
- Taking away from the stock only if there is enough. | Inventory
- Charging an amount with or without surcharge. | MedioDePago
- Gathering the total of the sales. | Till
- Applying the discount to the total. | Till
- Writing one line per sale. | Receipt
- Writing the rejections with their reason. | Receipt
- Writing the final stock. | Receipt
```

::: explicacion
Each responsibility goes to whoever has the information: the price, the stock, the way of charging and the total live in different pieces. What is shown is the receipt's job, even if in a small program it can stay in the main algorithm.
:::

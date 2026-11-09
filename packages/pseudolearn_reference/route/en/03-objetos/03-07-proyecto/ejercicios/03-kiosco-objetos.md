---
id: objetos.proyecto.kiosco-objetos
leccion: objetos.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The kiosk with objects
---

::: enunciado
Write the kiosk shared out into pieces. Read pairs of code and amount until code 0, then the way of paying (`efectivo` or `tarjeta`), and show the receipt of Part II with one more line after the discount: «A pagar en efectivo: 31» or «A pagar con tarjeta: 32». The card adds 5 % in whole pesos to the total with discount.
:::

::: restriccion
A contract `MedioDePago` that `Efectivo` and `Tarjeta` meet, and a class `Inventario` with private stock that never goes negative.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- contiene | interfaz | The contract MedioDePago is missing.
- declara-miembro | Inventario | stock | privado | The stock of the class Inventario has to be private.
```

::: pistas
1. Go back to your cards: which piece has each value?
2. It is the till of [Part II](ruta:procedimental.proyecto) with the payment methods of [lesson 3.4](ruta:objetos.contratos) and the cards of [lesson 3.6](ruta:objetos.responsabilidades).
3. `Producto` with its amount, `Inventario` with private stock and a `Quitar` that allows no negatives, `Caja` with the total and the discount, and both payment methods.
4. The main algorithm reads the sales, asks the inventory and the till for their part, and at the end asks the chosen method to charge. Close with the variant.
:::

::: variante
Add the 20-peso voucher as a third payment method, without touching the other pieces.
:::

::: explicacion
Each case of Part II appears twice, with cash and with card. The card on 0 charges 0. Frequent mistake: applying the surcharge before the discount, which gives another number.
:::

---
id: objetos.responsabilidades.colaboracion
leccion: objetos.responsabilidades
tipo: ordenar
nivel: brote
obligatorio: true
titulo: A sale step by step
---

::: enunciado
These are the requests the kiosk pieces make during a sale, mixed up. Put them in order.
:::

```pasos
- The main algorithm asks the till to sell three juices.
- The till asks the inventory to take away three juices.
- The inventory checks that there are enough and takes them away.
- The till asks the juice for the amount of three.
- The till adds the amount to its total.
- The till asks the receipt to note the line.
```

::: explicacion
The till coordinates: first it makes sure there is stock, then it computes and adds, and finally it leaves a record on the receipt. If the inventory did not have enough, the till would not go on with the rest.
:::

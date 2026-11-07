---
id: procedimental.modulos.a-que-modulo
leccion: procedimental.modulos
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: Which file does it go to?
---

::: enunciado
Place each piece of the kiosk in the file it belongs to.
:::

```categorias
- inventario
- ventas
- tickets
```

```elementos
- `AgregarStock` | inventario
- `QuitarStock` | inventario
- `Importe` | ventas
- `ConDescuento` | ventas
- `LineaDeTicket` | tickets
- `CerrarTicket` | tickets
```

::: explicacion
The stock file changes when the stock changes; the sales file, when prices or discounts change; the receipts file, when the format of the paper changes.
:::

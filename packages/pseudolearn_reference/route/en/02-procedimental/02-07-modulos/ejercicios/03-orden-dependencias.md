---
id: procedimental.modulos.orden-dependencias
leccion: procedimental.modulos
tipo: ordenar
nivel: brote
obligatorio: true
titulo: Who uses whom
---

::: enunciado
Order the kiosk files so that each one only uses those that come before it.
:::

```pasos
- inventario
- ventas
- tickets
- principal
```

::: explicacion
The stock file uses nobody. The sales check the stock. The receipts show what the sales compute. The main one uses them all.
:::

---
id: procedimental.modulos.a-que-modulo
leccion: procedimental.modulos
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: ¿A qué archivo va?
---

::: enunciado
Ubica cada pieza del kiosco en el archivo al que pertenece.
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
El inventario cambia cuando cambia el stock; las ventas, cuando cambian los precios o los descuentos; los tickets, cuando cambia el formato del papel.
:::

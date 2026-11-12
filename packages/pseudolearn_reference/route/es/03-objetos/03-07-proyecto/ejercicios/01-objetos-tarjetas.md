---
id: objetos.proyecto.objetos-tarjetas
leccion: objetos.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: Las tarjetas del kiosco con objetos
---

::: enunciado
Ubica cada responsabilidad del kiosco en la pieza a la que le toca.
:::

```categorias
- Producto
- Inventario
- MedioDePago
- Caja
- Ticket
```

```elementos
- Saber su nombre y su precio. | Producto
- Calcular el importe de una cantidad. | Producto
- Saber cuánto queda de cada producto. | Inventario
- Quitar del stock solo si alcanza. | Inventario
- Cobrar un monto con o sin recargo. | MedioDePago
- Juntar el total de las ventas. | Caja
- Aplicar el descuento al total. | Caja
- Escribir una línea por venta. | Ticket
- Escribir los rechazos con su motivo. | Ticket
- Escribir el stock final. | Ticket
```

::: explicacion
Cada responsabilidad va a quien tiene la información: el precio, el stock, la forma de cobrar y el total viven en piezas distintas. Lo que se muestra es tarea del ticket, aunque en un programa chico pueda quedar en el principal.
:::

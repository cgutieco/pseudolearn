---
id: objetos.proyecto.objetos-plan
leccion: objetos.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: El plan del kiosco con objetos
---

::: enunciado
Estos son los pasos del plan del kiosco repartido en piezas, mezclados. Ordénalos.
:::

```pasos
- Crear el catálogo de productos, el inventario con su stock inicial y la caja.
- Leer el primer código.
- Mientras el código no sea 0: leer la cantidad, validar el código y la cantidad, pedirle al inventario que quite si alcanza, sumar el importe en la caja, escribir la línea o el rechazo, y leer el código siguiente.
- Leer el medio de pago.
- Escribir el total y el total con descuento.
- Pedirle al medio de pago que cobre el total con descuento y escribirlo.
- Escribir el stock final.
```

::: explicacion
Las piezas se crean antes de leer. El medio de pago se lee al cerrar, porque el cliente lo elige al final. El cobro se le pide al medio de pago, que es quien sabe si hay recargo.
:::

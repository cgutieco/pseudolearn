---
id: procedimental.proyecto.kiosco-arbol
leccion: procedimental.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: El árbol de la caja
---

::: enunciado
El árbol de descomposición de la caja tiene tres ramas: leer y validar la venta, registrar la venta y cerrar el día. Ubica cada tarea en su rama.
:::

```categorias
- Leer y validar la venta
- Registrar la venta
- Cerrar el día
```

```elementos
- Leer el código y la cantidad. | Leer y validar la venta
- Comprobar el código, la cantidad y el stock. | Leer y validar la venta
- Calcular el importe. | Registrar la venta
- Descontar el stock. | Registrar la venta
- Escribir la línea del ticket. | Registrar la venta
- Calcular el descuento. | Cerrar el día
- Escribir el total. | Cerrar el día
- Escribir el stock final. | Cerrar el día
```

::: explicacion
Cada rama se puede escribir y probar por separado: las validaciones no necesitan saber cómo se imprime el ticket, y el cierre no necesita saber cómo se leyó cada venta.
:::

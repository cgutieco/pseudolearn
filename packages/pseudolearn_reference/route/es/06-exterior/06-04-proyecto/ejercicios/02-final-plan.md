---
id: exterior.proyecto.final-plan
leccion: exterior.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: El plan del kiosco completo
---

::: enunciado
Estos son los pasos del plan del kiosco completo, mezclados. Ordénalos.
:::

```pasos
- Cargar el inventario guardado, o usar el stock inicial si no hay.
- Leer las ventas hasta el 0, revisando el código y el stock de cada una.
- Calcular el total y el total con descuento.
- Armar el texto JSON del inventario nuevo.
- Guardar el texto en el archivo, con una limpieza diferida que lo cierre.
- Mostrar el ticket.
```

::: explicacion
El borde carga al principio y guarda al final; en el medio, el núcleo vende y calcula. El texto JSON se arma antes de guardarlo, porque guardar solo escribe lo que ya está listo.
:::

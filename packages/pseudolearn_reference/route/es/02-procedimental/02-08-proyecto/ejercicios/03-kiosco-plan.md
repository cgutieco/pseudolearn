---
id: procedimental.proyecto.kiosco-plan
leccion: procedimental.proyecto
tipo: ordenar
nivel: arbol
obligatorio: true
titulo: El plan de la caja con stock
---

::: enunciado
Estos son los pasos del plan de la caja con stock, mezclados. Ordénalos.
:::

```pasos
- Preparar el catálogo con el stock inicial de cada producto.
- Leer el primer código.
- Mientras el código no sea 0: leer la cantidad, validar el código, la cantidad y el stock, descontar el stock y sumar al total, escribir la línea o el rechazo, y leer el código siguiente.
- Calcular el total con descuento.
- Escribir el cierre y el stock final.
```

::: explicacion
El catálogo se prepara antes de leer. El bucle valida antes de tocar el stock, para que una venta rechazada no lo cambie. El descuento y el cierre van cuando ya no quedan ventas.
:::

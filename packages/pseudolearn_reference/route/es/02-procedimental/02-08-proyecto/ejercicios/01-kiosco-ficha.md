---
id: procedimental.proyecto.kiosco-ficha
leccion: procedimental.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: La ficha de la caja con stock
---

::: enunciado
Ubica cada dato del problema de la caja con stock en su zona de la ficha.
:::

```categorias
- Entra
- Dato fijo
- Sale
```

```elementos
- El código y la cantidad de cada venta | Entra
- El 0 que cierra la caja | Entra
- Los precios de los productos | Dato fijo
- El stock con que empieza cada producto | Dato fijo
- El descuento de 1 peso cada 10 | Dato fijo
- Las líneas del ticket y los rechazos | Sale
- El total y el total con descuento | Sale
- El stock que queda de cada producto | Sale
```

::: explicacion
El stock inicial es un dato fijo, como los precios; el stock final es una salida, porque depende de lo que se vendió en el día.
:::

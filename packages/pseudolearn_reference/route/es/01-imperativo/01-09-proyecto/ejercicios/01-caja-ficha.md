---
id: imperativo.proyecto.caja-ficha
leccion: imperativo.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: La ficha de la caja
---

::: enunciado
Ubica cada dato del problema de la caja en su zona de la ficha.
:::

```categorias
- Entra
- Dato fijo
- Sale
- No importa
```

```elementos
- El código de cada venta | Entra
- La cantidad de cada venta | Entra
- El 0 que cierra la caja | Entra
- Los precios de los productos | Dato fijo
- El descuento de 1 peso cada 10 | Dato fijo
- Las líneas del ticket | Sale
- El total y el total con descuento | Sale
- El producto más vendido | Sale
- La hora del recreo | No importa
```

::: explicacion
Entra lo que la caja escribe durante el recreo, incluido el 0, que no es una venta sino el aviso de que terminaron. Los precios y el descuento no cambian de un día a otro: van escritos en el programa. La hora del recreo no cambia nada del ticket.
:::

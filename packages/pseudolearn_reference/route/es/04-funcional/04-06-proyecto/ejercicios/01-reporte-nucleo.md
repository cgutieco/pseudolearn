---
id: funcional.proyecto.reporte-nucleo
leccion: funcional.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: ¿Núcleo o borde en el reporte?
---

::: enunciado
Ubica cada tarea del reporte en el núcleo que solo calcula o en el borde que toca el mundo.
:::

```categorias
- Núcleo
- Borde
```

```elementos
- Leer las ventas hasta el 0. | Borde
- Calcular el importe de una venta. | Núcleo
- Sumar todos los importes. | Núcleo
- Aplicar el descuento. | Núcleo
- Contar las ventas de más de 5 pesos. | Núcleo
- Elegir el producto estrella. | Núcleo
- Mostrar cada línea del reporte. | Borde
```

::: explicacion
Solo leer y mostrar tocan el mundo. Todo lo demás recibe datos y devuelve datos: va en funciones puras.
:::

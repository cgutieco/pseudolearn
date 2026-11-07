---
id: procedimental.modulos.orden-dependencias
leccion: procedimental.modulos
tipo: ordenar
nivel: brote
obligatorio: true
titulo: Quién usa a quién
---

::: enunciado
Ordena los archivos del kiosco de modo que cada uno use solo a los que están antes que él.
:::

```pasos
- inventario
- ventas
- tickets
- principal
```

::: explicacion
El inventario no usa a nadie. Las ventas consultan el stock. Los tickets muestran lo que calculan las ventas. El principal usa a todos.
:::

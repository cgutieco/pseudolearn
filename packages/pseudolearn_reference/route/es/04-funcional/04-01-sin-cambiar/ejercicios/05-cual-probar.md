---
id: funcional.sin-cambiar.cual-probar
leccion: funcional.sin-cambiar
tipo: comparar
nivel: brote
obligatorio: false
titulo: ¿Cuál se prueba más fácil?
---

::: enunciado
Hay que probar el descuento con 50 montos distintos. ¿Qué versión conviene probar: la que cambia la caja que recibe o la que devuelve un monto nuevo?
:::

```opciones
- [x] La que devuelve un monto nuevo, `ConDescuento`. | Se llama con cada monto y se compara el resultado, sin preparar nada.
- [ ] La que cambia la caja, `AplicarDescuento`. | Hay que preparar una caja antes de cada llamada y revisarla después.
- [ ] Las dos se prueban igual. | Una necesita preparar estado; la otra, no.
```

::: explicacion
Una función pura se prueba con una tabla de entrada y salida. Un subprograma que cambia una caja obliga a preparar la caja, llamarlo y mirarla.
:::

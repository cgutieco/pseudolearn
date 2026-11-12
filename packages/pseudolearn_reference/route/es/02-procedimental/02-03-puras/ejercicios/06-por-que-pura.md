---
id: procedimental.puras.por-que-pura
leccion: procedimental.puras
tipo: explicar
nivel: arbol
obligatorio: false
titulo: ¿Por qué se prueba fácil?
---

::: enunciado
¿Por qué es más fácil probar una pieza que solo calcula que una que lee o muestra?
:::

```opciones
- [ ] Porque es más corta. | Una función pura puede ser larga; lo que importa es que no tenga efectos.
- [x] Porque con los mismos datos da siempre lo mismo y no hay que preparar nada. | Alcanza con llamarla y comparar el resultado, como en la tabla de casos de la lección.
- [ ] Porque el motor la ejecuta más rápido. | La velocidad no cambia lo que hay que preparar para probarla.
```

::: explicacion
Para probar algo que lee, hay que darle entradas; para probar algo que muestra, hay que mirar la pantalla. Una función pura solo necesita sus datos.
:::

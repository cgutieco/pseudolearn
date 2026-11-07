---
id: procedimental.recursion.munecas
leccion: procedimental.recursion
tipo: explicar
nivel: semilla
obligatorio: false
titulo: Las muñecas
---

::: enunciado
En las muñecas que se abren una dentro de otra, ¿en cuál termina el trabajo de abrir?
:::

```opciones
- [ ] La muñeca más grande. | Es por donde se empieza, pero se abre y contiene a otra.
- [x] La muñeca más chica, que no se abre. | No contiene a ninguna: se resuelve sin abrir otra.
- [ ] Cualquier muñeca del medio. | Todas las del medio contienen a otra más chica.
```

::: explicacion
El caso base es el que ya no contiene una versión más chica del problema. Sin él, abrir muñecas no terminaría nunca.
:::

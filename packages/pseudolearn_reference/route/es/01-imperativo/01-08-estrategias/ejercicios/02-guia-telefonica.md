---
id: imperativo.estrategias.guia-telefonica
leccion: imperativo.estrategias
tipo: comparar
nivel: semilla
obligatorio: false
titulo: La lista de 1000 nombres
---

::: enunciado
Hay que encontrar un nombre en una lista ordenada alfabéticamente de 1000 nombres. ¿Qué forma de buscar conviene, y cuántos pasos necesita como máximo?
:::

```opciones
- [ ] Uno por uno, desde el principio: como máximo 500 pasos. | En el peor caso el nombre está al final, o no está: son 1000 pasos.
- [x] Por mitades: como máximo 10 pasos. | Cada paso descarta la mitad: 1000, 500, 250, … en 10 pasos queda uno solo.
- [ ] Por mitades: como máximo 100 pasos. | Descartar la mitad diez veces ya deja un solo nombre.
- [ ] Da lo mismo: las dos tardan igual en el peor caso. | Uno por uno puede necesitar 1000 pasos; por mitades, 10.
```

::: explicacion
Con 1000 datos, la fuerza bruta puede necesitar 1000 pasos; la búsqueda por mitades, 10. Con un millón, la diferencia es entre un millón y 20.
:::

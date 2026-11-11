---
id: procedimental.recursion.munecas
leccion: procedimental.recursion
tipo: explicar
nivel: semilla
obligatorio: false
titulo: The dolls
---

::: enunciado
In the dolls that open one inside another, in which doll does the work of opening end?
:::

```opciones
- [ ] The biggest doll. | It is where you start, but it opens and holds another.
- [x] The smallest doll, which does not open. | It holds none: it is solved without opening another.
- [ ] Any doll in the middle. | All the ones in the middle hold a smaller one.
```

::: explicacion
The base case is the one that no longer holds a smaller version of the problem. Without it, opening dolls would never end.
:::

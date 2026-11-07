---
id: objetos.identidad.mismo-o-distinto
leccion: objetos.identidad
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: The same or different?
---

::: enunciado
At the end of this program, does each pair of names point at the same `Contador` or at two different ones?

```programa id=pares titulo="Four counters… or fewer"
```
:::

```categorias
- The same counter
- Different counters
```

```elementos
- `a` and `b` | The same counter
- `a` and `e` | The same counter
- `a` and `c` | Different counters
- `c` and `d` | Different counters
```

::: explicacion
Assigning copies the arrow: `b` and `e` end up pointing at `a`'s counter. `New` and `copy` create new counters.
:::

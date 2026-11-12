---
id: exterior.http.borde-o-nucleo
leccion: exterior.http
tipo: clasificar
nivel: arbol
obligatorio: false
titulo: Core or edge?
---

::: enunciado
Place each step of the price of imported fruit: does it go in the core that only computes, or in the edge that touches the world?
:::

```categorias
- Core
- Edge
```

```elementos
- Asking for the network capability. | Edge
- Computing the price in pesos. | Core
- Reading the JSON of the answer. | Core
- Writing the price. | Edge
```

::: explicacion
Parsing a text that has already arrived is calculation: it receives a text and gives back a value. Asking for the network and writing touch the world.
:::

---
id: funcional.proyecto.reporte-nucleo
leccion: funcional.proyecto
tipo: clasificar
nivel: arbol
obligatorio: true
titulo: Core or edge in the report?
---

::: enunciado
Place each job of the report in the core that only computes or in the edge that touches the world.
:::

```categorias
- Core
- Edge
```

```elementos
- Read the sales until 0. | Edge
- Compute the amount of a sale. | Core
- Add up all the amounts. | Core
- Apply the discount. | Core
- Count the sales over 5 pesos. | Core
- Choose the star product. | Core
- Show each line of the report. | Edge
```

::: explicacion
Only reading and showing touch the world. Everything else receives data and gives back data: it goes in pure functions.
:::

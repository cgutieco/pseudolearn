---
id: exterior.json.formato
leccion: exterior.json
tipo: comparar
nivel: semilla
obligatorio: false
titulo: ¿Punto y coma o JSON?
---

::: enunciado
Para la página de la escuela, ¿conviene exportar «jugo;10» o {"jugo": 10}?
:::

```opciones
- [x] {"jugo": 10} | La página ya sabe leer JSON, y no hace falta inventar ni explicar reglas para el punto y coma.
- [ ] «jugo;10» | Es más corto, pero la página no lo sabe leer: habría que explicarle las reglas.
- [ ] Da lo mismo. | No da lo mismo: solo uno de los dos lo entiende la página sin trabajo extra.
```

::: explicacion
Cuando otro programa tiene que leer el dato, conviene una forma que ya conozca. JSON lo es para casi todos.
:::

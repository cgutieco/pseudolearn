---
id: exterior.json.formato
leccion: exterior.json
tipo: comparar
nivel: semilla
obligatorio: false
titulo: Semicolon or JSON?
---

::: enunciado
For the school page, is it better to export «jugo;10» or {"jugo": 10}?
:::

```opciones
- [x] {"jugo": 10} | The page already knows how to read JSON, and there is no need to invent or explain rules for the semicolon.
- [ ] «jugo;10» | It is shorter, but the page cannot read it: you would have to explain the rules to it.
- [ ] It makes no difference. | It does: only one of the two is understood by the page without extra work.
```

::: explicacion
When another program has to read the datum, a form it already knows is better. JSON is that for almost all of them.
:::

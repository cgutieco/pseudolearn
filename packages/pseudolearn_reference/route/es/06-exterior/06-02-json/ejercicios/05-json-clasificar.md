---
id: exterior.json.json-clasificar
leccion: exterior.json
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: ¿Válido o no?
---

::: enunciado
Ubica cada texto: ¿es JSON válido o no?
:::

```categorias
- JSON válido
- No válido
```

```elementos
- {"a": 1} | JSON válido
- {a: 1} | No válido
- [1, 2] | JSON válido
- {"a": 1,} | No válido
```

::: explicacion
En JSON las claves van entre comillas dobles y no se admite una coma después del último elemento.
:::

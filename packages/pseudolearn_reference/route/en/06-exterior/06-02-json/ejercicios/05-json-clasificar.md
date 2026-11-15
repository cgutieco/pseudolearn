---
id: exterior.json.json-clasificar
leccion: exterior.json
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Valid or not?
---

::: enunciado
Place each text: is it valid JSON or not?
:::

```categorias
- Valid JSON
- Not valid
```

```elementos
- {"a": 1} | Valid JSON
- {a: 1} | Not valid
- [1, 2] | Valid JSON
- {"a": 1,} | Not valid
```

::: explicacion
In JSON the keys go between double quotes and a comma after the last element is not allowed.
:::

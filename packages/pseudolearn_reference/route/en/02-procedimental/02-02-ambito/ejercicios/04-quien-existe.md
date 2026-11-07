---
id: procedimental.ambito.quien-existe
leccion: procedimental.ambito
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Who exists here?
---

::: enunciado
In this program, the line that returns `base * 2` is inside `Doble`. Place each name according to whether it exists on that line.

```programa id=ambitos titulo="Two subprograms"
```
:::

```categorias
- Exists on that line
- Does not exist on that line
```

```elementos
- `base` | Exists on that line
- `valor` | Does not exist on that line
- `calculado` | Does not exist on that line
- `total` | Does not exist on that line
```

::: explicacion
Inside `Doble` only its parameter `base` exists. `valor` and `calculado` belong to `Triple`, and `total` belongs to the main algorithm: they cannot be seen from `Doble`.
:::

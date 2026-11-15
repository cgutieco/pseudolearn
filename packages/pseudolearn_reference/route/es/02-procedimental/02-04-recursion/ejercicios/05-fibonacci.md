---
id: procedimental.recursion.fibonacci
leccion: procedimental.recursion
tipo: comparar
nivel: brote
obligatorio: false
titulo: El término 30
---

::: enunciado
En la serie 0, 1, 1, 2, 3, 5, 8, … cada término es la suma de los dos anteriores. Hay que calcular el término 30. ¿Qué forma conviene?
:::

```opciones
- [ ] Con recursión directa: el término `n` es el término `n - 1` más el `n - 2`. | Cada llamada abre dos llamadas más, y los mismos términos se calculan una y otra vez: más de un millón de llamadas.
- [x] Con un bucle que lleva los dos últimos términos. | Treinta vueltas alcanzan, y cada término se calcula una sola vez.
- [ ] Da lo mismo, porque las dos dan el mismo resultado. | Dan lo mismo, pero una hace treinta pasos y la otra más de un millón.
```

::: explicacion
La recursión directa ramifica: el término 30 pide el 29 y el 28, el 29 pide otra vez el 28, y así. Un bucle recuerda los dos últimos términos y no repite nada.
:::

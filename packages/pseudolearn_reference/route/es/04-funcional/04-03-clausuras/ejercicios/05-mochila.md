---
id: funcional.clausuras.mochila
leccion: funcional.clausuras
tipo: explicar
nivel: semilla
obligatorio: false
titulo: ¿Qué hay en la mochila?
---

::: enunciado
¿Qué guarda en su mochila la función que devuelve `CrearDescuento(20)`?
:::

```opciones
- [x] El 20. | Es el porcentaje que la fábrica recibió y que la función usa cada vez que se la llama.
- [ ] El precio. | El precio llega cada vez que se llama a la función; no se guarda.
- [ ] La lista de precios. | La función no sabe nada de la lista: recibe un precio por vez.
```

::: explicacion
La mochila guarda lo que la función necesita y no recibe como parámetro. Por eso `Mapear` puede usarla con un solo parámetro, el precio.
:::

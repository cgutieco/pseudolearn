---
id: objetos.identidad.alias-predecir
leccion: objetos.identidad
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Two names for a counter
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
`b <- a` does not create a new counter: `a` and `b` point at the same one. Incrementing through `b` changes the only counter there is.
:::

---
id: objetos.componer.super-predecir
leccion: objetos.componer
tipo: predecir
nivel: semilla
obligatorio: false
titulo: The cashier's greeting
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
`caja` is a `Cajero`: its `Presentarse` runs, which calls the one of `Empleado` with `Super` and adds its part. `mostrador` is an `Empleado` and uses the original method.
:::

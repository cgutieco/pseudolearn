---
id: procedimental.fallos.segun-resultado
leccion: procedimental.fallos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Success or reason
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
The first call returns `Success(3)` and the `Switch` shows the quotient. The second returns `Failure` with the reason, and the `Switch` shows the reason. The program stops at neither.
:::

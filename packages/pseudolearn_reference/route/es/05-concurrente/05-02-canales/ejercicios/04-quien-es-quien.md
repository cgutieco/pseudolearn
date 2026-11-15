---
id: concurrente.canales.quien-es-quien
leccion: concurrente.canales
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: ¿Quién es quién?
---

::: enunciado
Ubica cada parte: ¿produce mensajes o los consume?
:::

```categorias
- Productor
- Consumidor
```

```elementos
- La cocina que deja platos. | Productor
- El mostrador que los entrega. | Consumidor
- Un sensor que manda temperaturas. | Productor
- La pantalla que las muestra. | Consumidor
```

::: explicacion
El productor pone mensajes en el canal; el consumidor los saca y hace algo con ellos. Una misma tarea puede ser las dos cosas, pero aquí cada una hace solo una.
:::

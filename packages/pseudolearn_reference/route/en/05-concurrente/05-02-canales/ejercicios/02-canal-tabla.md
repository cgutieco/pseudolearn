---
id: concurrente.canales.canal-tabla
leccion: concurrente.canales
tipo: rastrear
nivel: brote
obligatorio: false
titulo: Trace the consumer
---

::: enunciado
Complete the table of the task that adds: the message received and the total, one row per message.
:::

```programa rol=objeto id=traza
```

```vueltas marca=19 columnas=valor,total
```

::: explicacion
Each message is added to the total: 4, then 4 + 5 = 9 and finally 9 + 6 = 15. The messages arrive in the order they were sent.
:::

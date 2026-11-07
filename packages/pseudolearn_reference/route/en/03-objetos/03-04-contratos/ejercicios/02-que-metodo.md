---
id: objetos.contratos.que-metodo
leccion: objetos.contratos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Which method runs?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
```

::: explicacion
The same line of `CobrarCon` runs the `Cobrar` of the real class it receives. The card adds `10 * 5 div 100`, which is 0 with whole numbers; cash charges the same; the voucher of 4 is not enough and charges 4.
:::

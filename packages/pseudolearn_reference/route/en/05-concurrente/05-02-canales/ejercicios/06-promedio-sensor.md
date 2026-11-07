---
id: concurrente.canales.promedio-sensor
leccion: concurrente.canales
tipo: resolver
nivel: arbol
obligatorio: false
titulo: The sensor average
---

::: enunciado
A sensor measures 5 whole temperatures. Read them and show their average as a real number, for example 24.0.
:::

::: restriccion
One task reads the temperatures and sends them through a channel; another receives them and computes the average.
:::

```programa rol=referencia
```

```casos
```

```aserciones
- contiene | bucle-condicional-posterior | The consumer receives in a loop until the channel is closed.
```

::: pistas
1. Who is the producer and who the consumer?
2. It is the pipeline of the lesson: the producer sends and closes; the consumer receives until `None`.
3. The consumer keeps the sum and the number of measurements, and at the end divides with `/`, which gives a real.
4. Each task keeps its own boxes: the sum lives in the consumer. Close with the variant.
:::

::: variante
Also show the highest temperature.
:::

::: docentes
`/` between integers gives a real, which is why 24 is shown as 24.0. The negative temperatures test that the sum can go down; the case of zeros, that there is no division by zero because 5 measurements always arrive.
:::

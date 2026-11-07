---
id: funcional.sin-cambiar.nucleo-o-borde
leccion: funcional.sin-cambiar
tipo: clasificar
nivel: semilla
obligatorio: true
titulo: ¿Núcleo o borde?
---

::: enunciado
El kiosco necesita estas tareas. Ubica cada una en el centro que solo calcula o en el borde que toca el mundo.
:::

```categorias
- Núcleo
- Borde
```

```elementos
- Calcular el IVA de un precio. | Núcleo
- Decidir si un producto está vencido, dada su fecha y la fecha de hoy. | Núcleo
- Preguntarle al cajero cuántos productos lleva el cliente. | Borde
- Mostrar el ticket. | Borde
- Averiguar la fecha de hoy. | Borde
```

::: explicacion
La trampa es la fecha: decidir si un producto está vencido es puro si la fecha de hoy llega como dato. Averiguarla toca el mundo, porque cada día da otro resultado.
:::

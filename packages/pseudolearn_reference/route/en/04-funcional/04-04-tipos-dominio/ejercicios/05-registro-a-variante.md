---
id: funcional.tipos-dominio.registro-a-variante
leccion: funcional.tipos-dominio
tipo: modificar
nivel: brote
obligatorio: false
titulo: From record to variant
---

::: enunciado
This program reads the state of a delivery as text and, if needed, one more value. With any state it does not know it shows «Pendiente», and so a typo such as «entrgado» goes unnoticed. Rewrite it so that each state is a shape with its own data, and that there is a shape for unknown states, which shows «Estado desconocido: » and the text read. For known states, what is shown does not change.
:::

::: restriccion
The delivery is a variant with one shape per state, and each shape carries only its data.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

::: pistas
1. Which states exist? Which data does each one need?
2. Look at the variant of the order in [the lesson](ruta:funcional.tipos-dominio).
3. One shape per known state and another for what is not recognised, which keeps the text.
4. Build the delivery according to the text and describe it with a `Switch` over its shapes. Close with the variant.
:::

::: variante
Add the delivered state with its time, without touching the other shapes.
:::

::: docentes
The record version accepts any text as a state. The variant forces you to decide what to do with what is not recognised.
:::

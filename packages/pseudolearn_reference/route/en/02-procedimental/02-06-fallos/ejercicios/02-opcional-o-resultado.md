---
id: procedimental.fallos.opcional-o-resultado
leccion: procedimental.fallos
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Can it be missing or can it fail?
---

::: enunciado
Place each job according to what it has to give back: a value that may be missing, or a value that may fail with a reason.
:::

```categorias
- May be missing
- May fail with a reason
```

```elementos
- Look up a contact who may not be in the contact list. | May be missing
- Find the first even number of a list. | May be missing
- Turn a text into a number saying why it failed. | May fail with a reason
- Divide warning if the divisor is 0. | May fail with a reason
```

::: explicacion
When not finding something is normal and there is nothing to explain, an optional is enough: `Some` or `None`. When you have to say what went wrong, you need a result: `Success` or `Failure` with its reason.
:::

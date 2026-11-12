---
id: procedimental.fallos.caer-o-avisar
leccion: procedimental.fallos
tipo: explicar
nivel: semilla
obligatorio: false
titulo: Stop or warn?
---

::: enunciado
Someone writes «twelve» where an age is asked for. Why is it better to answer «not a number» than to let the program stop?
:::

```opciones
- [x] Because whoever uses it knows what to fix, and the program can carry on. | The reason says what to do, and nobody loses what was already entered.
- [ ] Because that way the program is shorter. | Warning needs more lines: a filter and its reason.
- [ ] Because stopping is forbidden in PseudoLearn. | A program can stop; the point is that an expected error should not make it.
```

::: explicacion
An expected error, such as a badly written value, is part of the problem: the program has to answer it. Stopping is kept for what cannot be foreseen.
:::

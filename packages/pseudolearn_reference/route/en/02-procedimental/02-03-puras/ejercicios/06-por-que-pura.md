---
id: procedimental.puras.por-que-pura
leccion: procedimental.puras
tipo: explicar
nivel: arbol
obligatorio: false
titulo: Why is it easy to test?
---

::: enunciado
Why is it easier to test a piece that only computes than one that reads or shows?
:::

```opciones
- [ ] Because it is shorter. | A pure function can be long; what matters is that it has no effects.
- [x] Because with the same data it always gives the same and there is nothing to prepare. | Calling it and comparing the result is enough, as in the table of cases in the lesson.
- [ ] Because the engine runs it faster. | Speed does not change what has to be prepared to test it.
```

::: explicacion
To test something that reads, you have to give it inputs; to test something that shows, you have to look at the screen. A pure function only needs its data.
:::

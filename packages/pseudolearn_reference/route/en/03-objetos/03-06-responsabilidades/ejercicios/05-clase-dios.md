---
id: objetos.responsabilidades.clase-dios
leccion: objetos.responsabilidades
tipo: explicar
nivel: semilla
obligatorio: false
titulo: The piece that does everything
---

::: enunciado
What problem does a single piece of program that does all the kiosk's work have?
:::

```opciones
- [x] Every change touches it, and nobody understands all of it. | A change to the receipt and another to the stock end up in the same place, and to touch it you have to understand all of it.
- [ ] It is slower than several pieces. | Speed is not the problem: the problem is changing it without breaking something else.
- [ ] It cannot be run. | It runs without trouble; the problem appears when maintaining it.
```

::: explicacion
When one piece does everything, every reason to change touches it. Sharing out by information lets each change touch a single piece.
:::

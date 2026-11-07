---
id: inicio.errores.donde-se-corrige
leccion: inicio.errores
tipo: explicar
nivel: semilla
obligatorio: false
titulo: Where is it fixed?
---

::: enunciado
The engine shows this diagnostic for version A of the tip calculator. Where is it fixed?
:::

```programa rol=objeto id=diagnostico
```

```opciones
- [x] On the line and column the diagnostic points at. | The diagnostic points at the end of line 6, where the semicolon is missing.
- [ ] On the first line of the program. | The envelope of the program is well written.
- [ ] In any `Write`. | Only one of them is badly finished.
```

::: explicacion
A diagnostic says where to look. Sometimes the error is just before the place it points at, but you never have to check the whole program at random.
:::

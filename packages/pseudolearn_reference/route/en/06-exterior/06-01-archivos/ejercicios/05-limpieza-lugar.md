---
id: exterior.archivos.limpieza-lugar
leccion: exterior.archivos
tipo: explicar
nivel: brote
obligatorio: false
titulo: Where the cleanup goes
---

::: enunciado
Why is the cleanup that closes the file written right after opening it?
:::

```opciones
- [x] So that it is not forgotten even if the subprogram leaves early. | It runs on leaving, by any path: a `Return` or an error that is propagated.
- [ ] Because it runs straight away. | It does not run where it is written: it is kept and runs on leaving.
- [ ] Because that way the program is faster. | It does not change the speed; it changes that closing does not depend on reaching the end.
```

::: explicacion
Writing the cleanup next to what needs it avoids forgetting it: any exit from the subprogram runs it.
:::

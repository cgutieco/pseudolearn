---
id: procedimental.modulos.un-archivo
leccion: procedimental.modulos
tipo: comparar
nivel: semilla
obligatorio: false
titulo: One big file or several small ones
---

::: enunciado
Two classmates are going to work at the same time on the kiosk program. Which is better?
:::

```opciones
- [ ] A single big file, to have everything in view. | Both would touch the same file, and names like `Total` would clash.
- [x] Several files, one per responsibility. | Each one works in their file, and names do not clash because they live in different modules.
- [ ] One file per subprogram. | There would be dozens of files, and what changes together would be separated.
```

::: explicacion
One file per responsibility shares out the work without treading on each other and keeps together the pieces that change for the same reason.
:::

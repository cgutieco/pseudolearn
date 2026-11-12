---
id: objetos.identidad.registro-u-objeto
leccion: objetos.identidad
tipo: comparar
nivel: brote
obligatorio: false
titulo: Record or object?
---

::: enunciado
At the kiosk, several screens show the same order while it is being put together, and they all have to see it up to date. Should each screen have its own copy of the order, or should they all share the same one?
:::

```opciones
- [x] As an object, shared. | All the screens can hold a reference to the same order: what one adds, the others see.
- [ ] As a record, copied. | Each screen would have its own copy, and the changes of one would not reach the others.
- [ ] It makes no difference. | Here it does make a difference: sharing is what is wanted.
```

::: explicacion
A record is copied when assigned; an object is shared. When several parts of the program have to see the same thing, sharing is an advantage.
:::

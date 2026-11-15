---
id: funcional.tipos-dominio.por-que-variante
leccion: funcional.tipos-dominio
tipo: explicar
nivel: semilla
obligatorio: false
titulo: ¿Qué gana el kiosco?
---

::: enunciado
¿Qué gana el kiosco al guardar los pedidos con una forma por estado, en lugar de cuatro datos sueltos?
:::

```opciones
- [x] Un pedido entregado sin hora ya no se puede escribir. | La forma de entregado exige la hora: el error desaparece antes de ejecutar.
- [ ] El programa ocupa menos memoria. | No es lo importante: lo importante es qué se puede escribir.
- [ ] Ya no hacen falta decisiones. | Hace falta un `Segun`, pero el motor avisa si falta una forma.
```

::: explicacion
Con datos sueltos, hay que comprobar en todos lados que los datos tengan sentido. Con una variante, lo que no tiene sentido no se puede escribir.
:::

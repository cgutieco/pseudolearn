---
id: funcional.cara-a-cara.impuesto
leccion: funcional.cara-a-cara
tipo: comparar
nivel: brote
obligatorio: true
titulo: ¿Dónde se agrega un impuesto?
---

::: enunciado
Hay que agregar un impuesto del 5 % al total, antes del descuento. ¿En qué versión del kiosco se toca menos?
:::

```opciones
- [x] En la funcional. | Una función nueva `ConImpuesto` y la expresión del total cambian; nada más se toca.
- [ ] En la de objetos. | Hay que cambiar los métodos de la caja que calculan el total, y cuidar su estado.
- [ ] En la imperativa. | Hay que agregar una asignación en el lugar exacto del orden, y revisar todo lo que viene después.
```

::: explicacion
Un impuesto es una operación nueva sobre los mismos datos: es el cambio que la versión funcional hace fácil.
:::

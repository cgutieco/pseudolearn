---
id: objetos.responsabilidades.dos-disenos
leccion: objetos.responsabilidades
tipo: comparar
nivel: brote
obligatorio: true
titulo: Dos repartos
---

::: enunciado
En un reparto, la caja calcula cada importe multiplicando el precio por la cantidad. En otro, el producto sabe calcular su importe y la caja se lo pide. Ahora hay que agregar un impuesto al importe de algunos productos. ¿Qué reparto cambia menos?
:::

```opciones
- [x] El que pone el cálculo en el producto. | El impuesto depende del producto: cambia solo el método del producto, y la caja sigue igual.
- [ ] El que pone el cálculo en la caja. | La caja tendría que saber qué productos llevan impuesto, y cada pieza que calcule importes, también.
- [ ] Los dos cambian lo mismo. | En uno cambia una pieza; en el otro, todas las que calculan importes.
```

::: explicacion
La tarea le toca a quien tiene la información. El precio y el impuesto son del producto: el cálculo también.
:::

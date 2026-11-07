---
id: funcional.sin-cambiar.cual-probar
leccion: funcional.sin-cambiar
tipo: comparar
nivel: brote
obligatorio: false
titulo: Which one is easier to test?
---

::: enunciado
The discount has to be tested with 50 different amounts. Which version should be tested: the one that changes the box it receives or the one that gives back a new amount?
:::

```opciones
- [x] The one that gives back a new amount, `ConDescuento`. | It is called with each amount and the result is compared, without preparing anything.
- [ ] The one that changes the box, `AplicarDescuento`. | A box has to be prepared before each call and checked afterwards.
- [ ] Both are tested the same way. | One needs prepared state; the other does not.
```

::: explicacion
A pure function is tested with a table of input and output. A subprogram that changes a box forces you to prepare the box, call it and look at it.
:::

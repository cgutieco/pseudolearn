---
id: objetos.contratos.por-que-contrato
leccion: objetos.contratos
tipo: explicar
nivel: brote
obligatorio: false
titulo: What does the till gain?
---

::: enunciado
What does the till gain by depending on the contract `PaymentMethod` instead of knowing each way of paying?
:::

```opciones
- [x] Payment methods can be added without touching it. | A new method is a new class that meets the contract; the till stays the same.
- [ ] It charges faster. | Speed does not change: what changes is how much has to be touched to grow.
- [ ] It no longer needs classes. | The opposite: each payment method is a class.
```

::: explicacion
Depending on what an object promises, and not on which object it is, separates what changes (the payment methods) from what does not change (that the till asks to charge).
:::

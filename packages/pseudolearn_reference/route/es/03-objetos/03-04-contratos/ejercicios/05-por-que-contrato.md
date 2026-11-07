---
id: objetos.contratos.por-que-contrato
leccion: objetos.contratos
tipo: explicar
nivel: brote
obligatorio: false
titulo: ¿Qué gana la caja?
---

::: enunciado
¿Qué gana la caja al depender del contrato `MedioDePago` en lugar de conocer cada medio de pago?
:::

```opciones
- [x] Se le pueden agregar medios de pago sin tocarla. | Un medio nuevo es una clase nueva que cumple el contrato; la caja sigue igual.
- [ ] Cobra más rápido. | La velocidad no cambia: lo que cambia es cuánto hay que tocar para crecer.
- [ ] Ya no necesita clases. | Al contrario: cada medio de pago es una clase.
```

::: explicacion
Depender de lo que un objeto promete, y no de qué objeto es, separa lo que cambia (los medios de pago) de lo que no cambia (que la caja pide cobrar).
:::

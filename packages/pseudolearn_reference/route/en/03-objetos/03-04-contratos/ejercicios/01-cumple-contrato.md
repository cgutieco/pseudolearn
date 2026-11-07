---
id: objetos.contratos.cumple-contrato
leccion: objetos.contratos
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Does it meet the contract?
---

::: enunciado
The contract `MedioDePago` asks for `Cobrar(monto As Integer) As Integer`. Place each of these four candidates according to whether it meets the contract or not.

```programa id=cuatro-clases titulo="Four candidates"
```
:::

```categorias
- Meets the contract
- Does not meet the contract
```

```elementos
- `Efectivo` | Meets the contract
- `Puntos` | Meets the contract
- `Cupon` | Does not meet the contract
- `Cheque` | Does not meet the contract
```

::: explicacion
`Efectivo` and `Puntos` say they implement the contract and have the method with the exact signature, even though they charge differently. `Cupon` has the method, but does not say it implements the contract. `Cheque` says it does, but its method has a different name.
:::

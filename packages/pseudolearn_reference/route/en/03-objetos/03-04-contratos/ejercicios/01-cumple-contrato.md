---
id: objetos.contratos.cumple-contrato
leccion: objetos.contratos
tipo: clasificar
nivel: semilla
obligatorio: false
titulo: Does it meet the contract?
---

::: enunciado
The contract `PaymentMethod` asks for `Charge(amount As Integer) As Integer`. Place each of these four candidates according to whether it meets the contract or not.

```programa id=cuatro-clases titulo="Four candidates"
Clase Cash Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount;
  FinMetodo
FinClase

Clase Coupon
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount - 2;
  FinMetodo
FinClase

Clase Cheque Realiza PaymentMethod
  Metodo Pay(amount Como Entero) Como Entero
    Retornar amount;
  FinMetodo
FinClase

Clase Points Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount * 10;
  FinMetodo
FinClase
```
:::

```categorias
- Meets the contract
- Does not meet the contract
```

```elementos
- `Cash` | Meets the contract
- `Points` | Meets the contract
- `Coupon` | Does not meet the contract
- `Cheque` | Does not meet the contract
```

::: explicacion
`Cash` and `Points` say they implement the contract and have the method with the exact signature, even though they charge differently. `Coupon` has the method, but does not say it implements the contract. `Cheque` says it does, but its method has a different name.
:::

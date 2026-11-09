---
id: objetos.contratos.transferencia
leccion: objetos.contratos
tipo: modificar
nivel: brote
obligatorio: true
titulo: A new payment method
---

::: enunciado
The program reads a way of paying (1 cash, 2 card, 3 voucher of 15) and an amount, and shows what is charged. Add option 4, bank transfer, which has no surcharge but costs a fixed 1 peso, without changing `CobrarCon`.
:::

::: restriccion
`CobrarCon` does not change and the program does not use `Switch`: the new method is a class that meets the contract.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- no-contiene | seleccion-multiple | The new method is added with a class, without `Switch`.
```

::: pistas
1. Which part of the program knows how each method charges?
2. Look at how `Efectivo`, `Tarjeta` and `Vale` are written in [the lesson](ruta:objetos.contratos).
3. You need a new class that implements `MedioDePago`, and one more case in the choice of the main algorithm.
4. `Class Transferencia Implements MedioDePago` with `Cobrar` returning `monto + 1`, and the main algorithm uses it with code 4. Close with the variant.
:::

::: variante
Add a fifth method, the kiosk points, which charge twice the amount. Which lines did you change?
:::

::: explicacion
The initial program does not know method 4 and charges as a voucher. The reference adds a class and a case in the main algorithm; `CobrarCon` stays the same. The assertion prevents solving it with a `Switch`.
:::

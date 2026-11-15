---
id: objetos.contratos.transferencia
leccion: objetos.contratos
tipo: modificar
nivel: brote
obligatorio: true
titulo: A new payment method
---

::: enunciado
The program reads a way of paying (1 cash, 2 card, 3 voucher of 15) and an amount, and shows what is charged. Add option 4, bank transfer, which has no surcharge but costs a fixed 1 peso, without changing `ChargeWith`.
:::

::: restriccion
`ChargeWith` does not change and the program does not use `Switch`: the new method is a class that meets the contract.
:::

```programa rol=inicial
Interfaz PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero;
FinInterfaz

Clase Cash Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount;
  FinMetodo
FinClase

Clase Card Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount + amount * 5 div 100;
  FinMetodo
FinClase

Clase Voucher Realiza PaymentMethod
  Privado Definir available Como Entero;

  Metodo Constructor(balance Como Entero)
    Este.available <- balance;
  FinMetodo

  Metodo Charge(amount Como Entero) Como Entero
    Si amount > Este.available Entonces
      Retornar Este.available;
    FinSi
    Retornar amount;
  FinMetodo
FinClase

SubProceso ChargeWith<T: PaymentMethod>(payment Como T, amount Como Entero) Como Entero
  Retornar payment.Charge(amount);
FinSubProceso

Algoritmo Till
  Definir payment, amount Como Entero;
  Leer payment;
  Leer amount;
  Si payment = 1 Entonces
    Escribir ChargeWith(Nuevo Cash(), amount);
  Sino
    Si payment = 2 Entonces
      Escribir ChargeWith(Nuevo Card(), amount);
    Sino
      Escribir ChargeWith(Nuevo Voucher(15), amount);
    FinSi
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Interfaz PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero;
FinInterfaz

Clase Cash Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount;
  FinMetodo
FinClase

Clase Card Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount + amount * 5 div 100;
  FinMetodo
FinClase

Clase Voucher Realiza PaymentMethod
  Privado Definir available Como Entero;

  Metodo Constructor(balance Como Entero)
    Este.available <- balance;
  FinMetodo

  Metodo Charge(amount Como Entero) Como Entero
    Si amount > Este.available Entonces
      Retornar Este.available;
    FinSi
    Retornar amount;
  FinMetodo
FinClase

SubProceso ChargeWith<T: PaymentMethod>(payment Como T, amount Como Entero) Como Entero
  Retornar payment.Charge(amount);
FinSubProceso

Clase Transfer Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount + 1;
  FinMetodo
FinClase

Algoritmo Till
  Definir payment, amount Como Entero;
  Leer payment;
  Leer amount;
  Si payment = 1 Entonces
    Escribir ChargeWith(Nuevo Cash(), amount);
  Sino
    Si payment = 2 Entonces
      Escribir ChargeWith(Nuevo Card(), amount);
    Sino
      Si payment = 3 Entonces
        Escribir ChargeWith(Nuevo Voucher(15), amount);
      Sino
        Escribir ChargeWith(Nuevo Transfer(), amount);
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | 1 ; 20 | 20
visible | 4 ; 20 | 21
oculto | 2 ; 100 | 105
oculto | 3 ; 20 | 15
oculto | 4 ; 0 | 1
oculto | 4 ; 99 | 100
```

```aserciones
- no-contiene | seleccion-multiple | The new method is added with a class, without `Switch`.
```

::: pistas
1. Which part of the program knows how each method charges?
2. Look at how `Cash`, `Card` and `Voucher` are written in [the lesson](ruta:objetos.contratos).
3. You need a new class that implements `PaymentMethod`, and one more case in the choice of the main algorithm.
4. `Class Transfer Implements PaymentMethod` with `Charge` returning `amount + 1`, and the main algorithm uses it with code 4. Close with the variant.
:::

::: variante
Add a fifth method, the kiosk points, which charge twice the amount. Which lines did you change?
:::

::: explicacion
The initial program does not know method 4 and charges as a voucher. The reference adds a class and a case in the main algorithm; `ChargeWith` stays the same. The assertion prevents solving it with a `Switch`.
:::

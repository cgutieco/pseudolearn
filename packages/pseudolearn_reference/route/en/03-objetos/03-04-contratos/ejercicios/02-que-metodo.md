---
id: objetos.contratos.que-metodo
leccion: objetos.contratos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Which method runs?
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
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

Algoritmo Charges
  Escribir ChargeWith(Nuevo Card(), 10);
  Escribir ChargeWith(Nuevo Cash(), 10);
  Escribir ChargeWith(Nuevo Voucher(4), 10);
FinAlgoritmo
```

```salida
10
10
4
```

::: explicacion
The same line of `ChargeWith` runs the `Charge` of the real class it receives. The card adds `10 * 5 div 100`, which is 0 with whole numbers; cash charges the same; the voucher of 4 is not enough and charges 4.
:::

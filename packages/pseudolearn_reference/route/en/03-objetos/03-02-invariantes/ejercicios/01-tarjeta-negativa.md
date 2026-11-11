---
id: objetos.invariantes.tarjeta-negativa
leccion: objetos.invariantes
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The card that goes negative
---

::: enunciado
This program reads the initial balance of a card and an amount to charge, and shows whether it could charge and the balance left. With balance 30 and a charge of 50 it leaves the card at -20. Find the error and fix it so that the card never goes negative.
:::

```programa rol=inicial
Clase Card
  Privado Definir balance Como Entero;

  Metodo Constructor(initial Como Entero)
    Este.balance <- 0;
    Si initial > 0 Entonces
      Este.balance <- initial;
    FinSi
  FinMetodo

  Metodo Charge(amount Como Entero) Como Logico
    Este.balance <- Este.balance - amount;
    Retornar Verdadero;
  FinMetodo

  Metodo Load(amount Como Entero) Como Logico
    Si amount <= 0 Entonces
      Retornar Falso;
    FinSi
    Este.balance <- Este.balance + amount;
    Retornar Verdadero;
  FinMetodo

  Metodo Balance() Como Entero
    Retornar Este.balance;
  FinMetodo
FinClase

Algoritmo Canteen
  Definir initial, amount Como Entero;
  Leer initial;
  Leer amount;
  Definir card Como Card <- Nuevo Card(initial);
  Escribir card.Charge(amount), " ", card.Balance();
FinAlgoritmo
```

```programa rol=referencia
Clase Card
  Privado Definir balance Como Entero;

  Metodo Constructor(initial Como Entero)
    Este.balance <- 0;
    Si initial > 0 Entonces
      Este.balance <- initial;
    FinSi
  FinMetodo

  Metodo Charge(amount Como Entero) Como Logico
    Si amount <= 0 O amount > Este.balance Entonces
      Retornar Falso;
    FinSi
    Este.balance <- Este.balance - amount;
    Retornar Verdadero;
  FinMetodo

  Metodo Load(amount Como Entero) Como Logico
    Si amount <= 0 Entonces
      Retornar Falso;
    FinSi
    Este.balance <- Este.balance + amount;
    Retornar Verdadero;
  FinMetodo

  Metodo Balance() Como Entero
    Retornar Este.balance;
  FinMetodo
FinClase

Algoritmo Canteen
  Definir initial, amount Como Entero;
  Leer initial;
  Leer amount;
  Definir card Como Card <- Nuevo Card(initial);
  Escribir card.Charge(amount), " ", card.Balance();
FinAlgoritmo
```

```casos
visible | 30 ; 10 | Verdadero 20
visible | 30 ; 50 | Falso 30
oculto | 30 ; 30 | Verdadero 0
oculto | 30 ; 31 | Falso 30
oculto | 0 ; 1 | Falso 0
oculto | 100 ; 0 | Falso 100
```

::: pistas
1. What always has to be true of a card? Which method breaks it?
2. Compare `Charge` with the one of the card in [the lesson](ruta:objetos.invariantes).
3. Before subtracting, the method has to decide whether the charge is possible; if not, it returns false without touching anything.
4. Add at the start of `Charge` the check that the amount is positive and not over the balance. Close with the variant.
:::

::: variante
Add a method `Transfer(other, amount)` that moves balance from one card to another without breaking the invariant in either.
:::

::: explicacion
The method subtracts without asking. Hidden cases: charging exactly the balance, one more, charging an empty card and a charge of 0.
:::

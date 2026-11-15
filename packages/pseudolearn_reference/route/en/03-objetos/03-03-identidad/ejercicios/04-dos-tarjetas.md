---
id: objetos.identidad.dos-tarjetas
leccion: objetos.identidad
tipo: resolver
nivel: brote
obligatorio: true
titulo: Two cards with the same balance
---

::: enunciado
Read an initial balance and create two canteen cards with that balance. Charge 5 pesos to the first and show both balances, separated by a space. If the first one does not have enough, nothing is charged.
:::

::: restriccion
Use the class `Card` from the previous lesson, with its private balance.
:::

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

Algoritmo TwoCards
  Definir initial Como Entero;
  Leer initial;
  Definir cardOne Como Card <- Nuevo Card(initial);
  Definir cardTwo Como Card <- Nuevo Card(initial);
  Definir charged Como Logico <- cardOne.Charge(5);
  Escribir cardOne.Balance(), " ", cardTwo.Balance();
FinAlgoritmo
```

```casos
visible | 20 | 15 20
visible | 10 | 5 10
oculto | 5 | 0 5
oculto | 3 | 3 3
oculto | 0 | 0 0
```

::: pistas
1. How many cards have to exist at the end? How many times do you have to create one?
2. Look at the alias in [the lesson](ruta:objetos.identidad): assigning does not create a new card.
3. Create each card with its own `New`.
4. Two `New Card(initial)`, a `Charge(5)` on the first and both `Balance()`. Close with the variant.
:::

::: variante
Make the second card an alias of the first. What does it show now with 20?
:::

::: explicacion
Common mistake: creating one card and assigning it to both variables, which shows 15 15. Hidden cases: charging exactly the balance, a balance that is not enough and an empty one.
:::

---
id: objetos.invariantes.tarjeta-pruebas
leccion: objetos.invariantes
tipo: disenar-pruebas
nivel: brote
obligatorio: true
titulo: The card tests
---

::: enunciado
A program reads the initial balance, an amount to charge and an amount to load, and shows the result of charging, the result of loading and the final balance. Write between 3 and 4 test cases so that any wrong version of the card fails at least one.
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

Algoritmo Tests
  Definir initial, charge, load Como Entero;
  Leer initial;
  Leer charge;
  Leer load;
  Definir card Como Card <- Nuevo Card(initial);
  Escribir card.Charge(charge), " ", card.Load(load), " ", card.Balance();
FinAlgoritmo
```

```programa rol=mutante id=sin-cobro-justo
Clase Card
  Privado Definir balance Como Entero;

  Metodo Constructor(initial Como Entero)
    Este.balance <- 0;
    Si initial > 0 Entonces
      Este.balance <- initial;
    FinSi
  FinMetodo

  Metodo Charge(amount Como Entero) Como Logico
    Si amount <= 0 O amount >= Este.balance Entonces
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

Algoritmo Tests
  Definir initial, charge, load Como Entero;
  Leer initial;
  Leer charge;
  Leer load;
  Definir card Como Card <- Nuevo Card(initial);
  Escribir card.Charge(charge), " ", card.Load(load), " ", card.Balance();
FinAlgoritmo
```

```programa rol=mutante id=permite-negativo
Clase Card
  Privado Definir balance Como Entero;

  Metodo Constructor(initial Como Entero)
    Este.balance <- 0;
    Si initial > 0 Entonces
      Este.balance <- initial;
    FinSi
  FinMetodo

  Metodo Charge(amount Como Entero) Como Logico
    Si amount <= 0 Entonces
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

Algoritmo Tests
  Definir initial, charge, load Como Entero;
  Leer initial;
  Leer charge;
  Leer load;
  Definir card Como Card <- Nuevo Card(initial);
  Escribir card.Charge(charge), " ", card.Load(load), " ", card.Balance();
FinAlgoritmo
```

```programa rol=mutante id=carga-negativa
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
    Este.balance <- Este.balance + amount;
    Retornar Verdadero;
  FinMetodo

  Metodo Balance() Como Entero
    Retornar Este.balance;
  FinMetodo
FinClase

Algoritmo Tests
  Definir initial, charge, load Como Entero;
  Leer initial;
  Leer charge;
  Leer load;
  Definir card Como Card <- Nuevo Card(initial);
  Escribir card.Charge(charge), " ", card.Load(load), " ", card.Balance();
FinAlgoritmo
```

```casos
visible | 30 ; 10 ; 5 | Verdadero Verdadero 25
```

```casos-solucion minimo=3 maximo=4
30 ; 30 ; 10 | Verdadero Verdadero 10
30 ; 31 ; 10 | Falso Verdadero 40
30 ; 5 ; -5 | Verdadero Falso 25
```

::: pistas
1. Write the card's invariant. At which edges can it break?
2. Look at the table of cases in [the lesson](ruta:objetos.invariantes).
3. You need a charge of exactly the balance, a charge of one more and a negative load.
4. 30, 30 and 10; 30, 31 and 10; 30, 5 and -5, with their answers. Close with the variant.
:::

::: variante
Which case would you add for an error that charged negative amounts?
:::

::: explicacion
Wrong versions: it does not allow charging exactly the balance, it allows going negative and it accepts negative loads. Each case of the solution uncovers one.
:::

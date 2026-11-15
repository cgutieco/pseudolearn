---
id: objetos.invariantes.atributo-privado
leccion: objetos.invariantes
tipo: modificar
nivel: brote
obligatorio: true
titulo: The balance, inside
---

::: enunciado
In this program, the balance of the card is in view and the main algorithm changes it directly. Rewrite the card so that the balance is protected and the main algorithm only makes requests to it, without changing what it shows.
:::

::: restriccion
The attribute `balance` of the class `Card` is private; the card offers methods to create it with its balance, charge and check the balance.
:::

```programa rol=inicial
Clase Card
  Definir balance Como Entero;
FinClase

Algoritmo Canteen
  Definir initial, amount Como Entero;
  Leer initial;
  Leer amount;
  Definir card Como Card <- Nuevo Card();
  card.balance <- initial;
  Si amount > 0 Y amount <= card.balance Entonces
    card.balance <- card.balance - amount;
  FinSi
  Escribir card.balance;
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
  Definir charged Como Logico <- card.Charge(amount);
  Escribir card.Balance();
FinAlgoritmo
```

```casos
visible | 30 ; 10 | 20
visible | 30 ; 50 | 30
oculto | 30 ; 30 | 0
oculto | 0 ; 0 | 0
oculto | 100 ; 1 | 99
```

```aserciones
- declara-miembro | Card | balance | privado | The attribute balance of the class Card has to be private.
```

::: pistas
1. Which lines of the main algorithm touch the balance directly? Those will have to become methods.
2. Look at the card of [the lesson](ruta:objetos.invariantes): constructor, `Charge` and `Balance`.
3. Mark the attribute as private and move the charge check into a method.
4. The main algorithm creates the card with its balance, asks it to charge and shows `Balance()`. Close with the variant.
:::

::: variante
Try, from the main algorithm, to set the balance directly. What does the engine say?
:::

::: explicacion
The assertion checks that `balance` is private. The cases are those of the initial program: what is shown does not change, but now the rule lives in the class.
:::

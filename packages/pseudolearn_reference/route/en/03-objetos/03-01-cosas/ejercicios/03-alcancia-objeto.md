---
id: objetos.cosas.alcancia-objeto
leccion: objetos.cosas
tipo: resolver
nivel: semilla
obligatorio: true
titulo: The money box as an object
---

::: enunciado
Read coin deposits until a 0 and show the total gathered. The program shows only the number.
:::

::: restriccion
A class `MoneyBox` with a public method `Deposit(coins)` and another `Total()`; the main algorithm only reads, deposits and shows.
:::

```programa rol=referencia
Clase MoneyBox
  Definir gathered Como Entero;

  Metodo Constructor()
    Este.gathered <- 0;
  FinMetodo

  Metodo Deposit(coins Como Entero)
    Este.gathered <- Este.gathered + coins;
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.gathered;
  FinMetodo
FinClase

Algoritmo Savings
  Definir moneyBox Como MoneyBox <- Nuevo MoneyBox();
  Definir coins Como Entero;
  Leer coins;
  Mientras coins <> 0 Hacer
    moneyBox.Deposit(coins);
    Leer coins;
  FinMientras
  Escribir moneyBox.Total();
FinAlgoritmo
```

```casos
visible | 2 ; 3 ; 4 ; 0 | 9
visible | 0 | 0
oculto | 50 ; 0 | 50
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 0 | 10
oculto | 7 ; 0 | 7
```

```aserciones
- declara-miembro | MoneyBox | Deposit | publico | The public method Deposit is missing from the class MoneyBox.
```

::: pistas
1. What does a money box know? What does it know how to do?
2. It is the dictated money box of [lesson 1.3](ruta:imperativo.mientras), with the total box kept inside an object, like the counter of [the lesson](ruta:objetos.cosas).
3. An attribute for what was gathered, which starts at 0 in the constructor; `Deposit` adds and `Total` returns it.
4. The main algorithm creates the money box, deposits each value until 0 and shows `Total()`. Close with the variant.
:::

::: variante
Add a method `Break()` that returns the total and leaves the money box at 0.
:::

::: explicacion
The assertion checks that `Deposit` exists and is public. Frequent mistake: adding in the main algorithm and using the class only to keep the number.
:::

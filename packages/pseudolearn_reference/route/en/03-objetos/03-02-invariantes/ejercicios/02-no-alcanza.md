---
id: objetos.invariantes.no-alcanza
leccion: objetos.invariantes
tipo: predecir
nivel: semilla
obligatorio: false
titulo: When it is not enough
---

::: enunciado
Without running it, write exactly what this program shows.
:::

```programa rol=objeto id=prediccion
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
  Definir card Como Card <- Nuevo Card(10);
  Escribir card.Charge(15);
  Escribir card.Balance();
FinAlgoritmo
```

```salida
Falso
10
```

::: explicacion
15 is more than the balance: `Charge` returns false and changes nothing. The balance stays at 10.
:::

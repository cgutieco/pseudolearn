---
id: imperativo.mientras.alcancia-pruebas
leccion: imperativo.mientras
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: The money box tests
---

::: enunciado
Do not write code. Write four prices with the right answer for each one, so that any wrong version of the money box fails at least one of them.
:::

```programa rol=referencia
Algoritmo MoneyBox
  Definir price Como Entero;
  Leer price;
  Definir dia Como Entero <- 1;
  Definir savedToday Como Entero <- 2;
  Definir savings Como Entero <- 2;
  Mientras savings < price Hacer
    dia <- dia + 1;
    savedToday <- savedToday + 1;
    savings <- savings + savedToday;
  FinMientras
  Escribir "Day ", dia, " with ", savings, " coins";
FinAlgoritmo
```

```programa rol=mutante id=menor-o-igual
Algoritmo MoneyBox
  Definir price Como Entero;
  Leer price;
  Definir dia Como Entero <- 1;
  Definir savedToday Como Entero <- 2;
  Definir savings Como Entero <- 2;
  Mientras savings <= price Hacer
    dia <- dia + 1;
    savedToday <- savedToday + 1;
    savings <- savings + savedToday;
  FinMientras
  Escribir "Day ", dia, " with ", savings, " coins";
FinAlgoritmo
```

```programa rol=mutante id=ahorro-en-cero
Algoritmo MoneyBox
  Definir price Como Entero;
  Leer price;
  Definir dia Como Entero <- 1;
  Definir savedToday Como Entero <- 2;
  Definir savings Como Entero <- 0;
  Mientras savings < price Hacer
    dia <- dia + 1;
    savedToday <- savedToday + 1;
    savings <- savings + savedToday;
  FinMientras
  Escribir "Day ", dia, " with ", savings, " coins";
FinAlgoritmo
```

```programa rol=mutante id=suma-antes
Algoritmo MoneyBox
  Definir price Como Entero;
  Leer price;
  Definir dia Como Entero <- 1;
  Definir savedToday Como Entero <- 2;
  Definir savings Como Entero <- 2;
  Mientras savings < price Hacer
    dia <- dia + 1;
    savings <- savings + savedToday;
    savedToday <- savedToday + 1;
  FinMientras
  Escribir "Day ", dia, " with ", savings, " coins";
FinAlgoritmo
```

```programa rol=mutante id=dia-en-cero
Algoritmo MoneyBox
  Definir price Como Entero;
  Leer price;
  Definir dia Como Entero <- 0;
  Definir savedToday Como Entero <- 2;
  Definir savings Como Entero <- 2;
  Mientras savings < price Hacer
    dia <- dia + 1;
    savedToday <- savedToday + 1;
    savings <- savings + savedToday;
  FinMientras
  Escribir "Day ", dia, " with ", savings, " coins";
FinAlgoritmo
```

```casos
visible | 50 | Day 9 with 54 coins
```

```casos-solucion minimo=4 maximo=4
50 | Day 9 with 54 coins
54 | Day 9 with 54 coins
2 | Day 1 with 2 coins
1000 | Day 44 with 1034 coins
```

::: pistas
1. Write the worked examples of the card. Which ones are edge cases?
2. Imagine possible errors: a condition that is off by one, a box that starts wrong, two lines in another order. Which price uncovers them?
3. You need a price that is gathered exactly and one that is enough on the first day.
4. 50, 54, 2 and 1000, with their answers from the lesson, uncover every wrong version. Close with the variant.
:::

::: variante
Which of the four prices could you remove without letting any wrong version escape? (Try it: the app tells you which one survives.)
:::

::: explicacion
Wrong versions: `<=` in the condition, the money box starting at 0, adding before increasing what is saved each day, and the day starting at 0. A set without an exact price (such as 54) and without one less than or equal to 2 does not detect the first one.
:::

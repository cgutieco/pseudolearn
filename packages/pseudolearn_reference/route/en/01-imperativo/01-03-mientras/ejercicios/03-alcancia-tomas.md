---
id: imperativo.mientras.alcancia-tomas
leccion: imperativo.mientras
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Tomás's money box
---

::: enunciado
Tomás wrote his version of the money box. With price 50 it shows «Day 9 with 54 coins», the same as yours. But it is wrong. Find a price it gets wrong.
:::

```programa rol=defectuoso
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

```casos
visible | 50 | Day 9 with 54 coins
```

```rompe
54
2
```

::: pistas
1. Go back to the problem card. Which of the worked examples is an edge case?
2. Compare Tomás's condition with yours. When do those two questions give different answers?
3. Try a price that Lucía can gather exactly.
4. With price 54 Tomás says «Day 10 with 65 coins»; with price 2, «Day 2 with 5». Close with the variant.
:::

::: variante
Fix Tomás's condition by changing a single sign.
:::

::: explicacion
The prices that are gathered exactly break Tomás's version: 2, 5, 9, 14, 20, 27, 35, 44, 54. The app runs the proposed price in both versions and accepts it if they differ.
:::

---
id: imperativo.mientras.frijol
leccion: imperativo.mientras
tipo: resolver
nivel: brote
obligatorio: true
titulo: The magic bean
---

::: enunciado
You plant a magic bean that already measures a few centimetres; the program reads how many. On the first day it grows 1 centimetre, and every day it grows twice as much as it grew the day before. How many days does it take to reach the window, which is 100 centimetres off the ground? The program shows only the number of days.
:::

```programa rol=referencia
Algoritmo Bean
  Definir height Como Entero;
  Leer height;
  Definir growth Como Entero <- 1;
  Definir days Como Entero <- 0;
  Mientras height < 100 Hacer
    height <- height + growth;
    growth <- growth * 2;
    days <- days + 1;
  FinMientras
  Escribir days;
FinAlgoritmo
```

```casos
visible | 3 | 7
visible | 100 | 0
oculto | 99 | 1
oculto | 0 | 7
oculto | 50 | 6
```

::: pistas
1. Make the table by hand for 3 centimetres. Which box changes by adding and which one by multiplying?
2. It looks like [the money box](ruta:imperativo.mientras): there what was saved each day grew one by one; here it doubles.
3. You need a height, a growth and a box that counts the days. The question: has it still not reached 100?
4. While the height is less than 100: add the growth, double it and count a day. Close with the variant.
:::

::: variante
What if the window is at 1000 centimetres? (With 3 centimetres, it takes 10 days.)
:::

::: explicacion
Hidden cases: 99 → 1 (one day is enough), 0 → 7, 50 → 6 (51, 53, 57, 65, 81, 113). Frequent mistake: doubling the growth before adding it, which gives 6 with 3 centimetres.
:::

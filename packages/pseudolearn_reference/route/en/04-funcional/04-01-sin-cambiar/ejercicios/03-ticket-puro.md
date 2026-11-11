---
id: funcional.sin-cambiar.ticket-puro
leccion: funcional.sin-cambiar
tipo: resolver
nivel: brote
obligatorio: true
titulo: A pure receipt
---

::: enunciado
Read two sales, each with a product code and an amount, and show the total with discount. The prices are the kiosk's: 1 Juice 3, 2 Sandwich 5, 3 Biscuit 2, 4 Water 1 and 5 Fruit 2. For every 10 pesos, 1 is taken off.
:::

::: restriccion
The price, the line amount and the discount are functions; the main algorithm only reads and shows.
:::

```programa rol=referencia
Funcion price <- PriceOf(code Como Entero)
  Definir price Como Entero;
  Segun code Hacer
    1:
      price <- 3;
    2:
      price <- 5;
    3:
      price <- 2;
    4:
      price <- 1;
    De Otro Modo:
      price <- 2;
  FinSegun
FinFuncion

Funcion amount <- Line(price Como Entero, quantity Como Entero)
  Definir amount Como Entero;
  amount <- price * quantity;
FinFuncion

Funcion discounted <- WithDiscount(total Como Entero)
  Definir discounted Como Entero;
  discounted <- total - total div 10;
FinFuncion

Algoritmo Receipt
  Definir code1, quantity1, code2, quantity2 Como Entero;
  Leer code1;
  Leer quantity1;
  Leer code2;
  Leer quantity2;
  Escribir WithDiscount(Line(PriceOf(code1), quantity1) + Line(PriceOf(code2), quantity2));
FinAlgoritmo
```

```casos
```

```aserciones
- declara-subprograma | WithDiscount | 1 | The function WithDiscount, which receives the total, is missing.
```

::: pistas
1. Which part is calculation and which part touches the world?
2. Use the functions of the functional till of [the lesson](ruta:funcional.sin-cambiar).
3. One function for the price of a code, another for the amount of a line and another for the discount.
4. The main algorithm reads the four values and shows a single expression that composes the functions. Close with the variant.
:::

::: variante
Also show how much was saved with the discount, without computing anything twice.
:::

::: explicacion
In «3, 5, 5, 0» there are 5 biscuits (10 pesos) and 0 fruit: total 10, with discount 9. The assertion checks that `WithDiscount` exists; that it is pure is checked by the engine when compiling it.
:::

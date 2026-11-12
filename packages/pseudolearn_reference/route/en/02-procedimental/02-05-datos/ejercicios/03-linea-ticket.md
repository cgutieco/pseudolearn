---
id: procedimental.datos.linea-ticket
leccion: procedimental.datos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: A receipt line
---

::: enunciado
Read the name, the price and the amount of a product, in that order, and show the receipt line in the format `Juice x 3 = 9`.
:::

::: restriccion
The name and the price are kept together in a record `Product`.
:::

```programa rol=referencia
Registro Product
  Definir name Como Cadena;
  Definir price Como Entero;
FinRegistro

Algoritmo Line
  Definir name Como Cadena;
  Definir price, quantity Como Entero;
  Leer name;
  Leer price;
  Leer quantity;
  Definir product Como Product <- Product(name, price);
  Escribir product.name, " x ", quantity, " = ", product.price * quantity;
FinAlgoritmo
```

```casos
visible | Juice ; 3 ; 3 | Juice x 3 = 9
visible | Sandwich ; 5 ; 2 | Sandwich x 2 = 10
oculto | Water ; 1 ; 0 | Water x 0 = 0
oculto | Fruit ; 2 ; 1 | Fruit x 1 = 2
oculto | Gum ; 1 ; 25 | Gum x 25 = 25
```

::: pistas
1. Which values describe the product and which one describes the sale?
2. Look at the kiosk product in [the lesson](ruta:procedimental.datos).
3. The record keeps name and price; the amount belongs to the sale.
4. Create `Product(name, price)` and show its fields with the amount. Close with the variant.
:::

::: variante
Add a field `stock` and show how much is left after the sale.
:::

::: explicacion
Hidden cases: amount 0 and price 1. The record does not change the output; it organises the data for the variant.
:::

---
id: procedimental.datos.paralelos-a-registros
leccion: procedimental.datos
tipo: modificar
nivel: arbol
obligatorio: false
titulo: From separate rows to cards
---

::: enunciado
This program reads three products (name and price) in separate rows and shows them. Now each product also brings its stock, which is read after the price. Change the program so that it shows each product as `Juice 3 (10 left)`.
:::

::: restriccion
Each product is kept as a card with its three values together, in a vector.
:::

```programa rol=inicial
Algoritmo Products
  Dimension names[3] Como Cadena;
  Dimension prices[3] Como Entero;
  Para i <- 0 Hasta 2 Hacer
    Leer names[i];
    Leer prices[i];
  FinPara
  Para i <- 0 Hasta 2 Hacer
    Escribir names[i], " ", prices[i];
  FinPara
FinAlgoritmo
```

```programa rol=referencia
Registro Product
  Definir name Como Cadena;
  Definir price, stock Como Entero;
FinRegistro

Algoritmo Products
  Definir products Como Vector<Product> <- Vector();
  Definir name Como Cadena;
  Definir price, stock Como Entero;
  Para i <- 1 Hasta 3 Hacer
    Leer name;
    Leer price;
    Leer stock;
    products.Agregar(Product(name, price, stock));
  FinPara
  Para Cada product En products Hacer
    Escribir product.name, " ", product.price, " (", product.stock, " left)";
  FinPara
FinAlgoritmo
```

```casos
visible | Juice ; 3 ; 10 ; Water ; 1 ; 12 ; Fruit ; 2 ; 6 | Juice 3 (10 left) ⏎ Water 1 (12 left) ⏎ Fruit 2 (6 left)
visible | Alfajor ; 2 ; 0 ; Juice ; 3 ; 1 ; Water ; 1 ; 2 | Alfajor 2 (0 left) ⏎ Juice 3 (1 left) ⏎ Water 1 (2 left)
oculto | A ; 1 ; 1 ; B ; 2 ; 2 ; C ; 3 ; 3 | A 1 (1 left) ⏎ B 2 (2 left) ⏎ C 3 (3 left)
oculto | Sandwich ; 5 ; 5 ; Sandwich ; 5 ; 4 ; Sandwich ; 5 ; 3 | Sandwich 5 (5 left) ⏎ Sandwich 5 (4 left) ⏎ Sandwich 5 (3 left)
oculto | Gum ; 1 ; 100 ; Water ; 1 ; 0 ; Fruit ; 2 ; 50 | Gum 1 (100 left) ⏎ Water 1 (0 left) ⏎ Fruit 2 (50 left)
```

::: pistas
1. With separate rows, how many things do you have to touch to add the stock?
2. Look at the end of [the lesson](ruta:procedimental.datos): adding a value to a card is adding a field.
3. Define a card with name, price and stock, and keep the three in a vector.
4. A record `Product` with three fields, a vector filled in the first loop and a `For Each` that shows. Close with the variant.
:::

::: variante
Show at the end the product with the least stock.
:::

::: explicacion
The app's catalogue of checks cannot require a record; the restriction asks for it, and the cases require the new stock. Common mistake: adding a third separate row, which works but leaves three rows to keep aligned.
:::

---
id: procedimental.proyecto.kiosco-partes
leccion: procedimental.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The till in parts
---

::: enunciado
Write the till with stock. Read pairs of code and amount until code 0 and show the receipt with the exact format of the lesson: a line `Juice x 3 = 9` per accepted sale, `Sandwich x 6 rejected: stock is 5` if the stock is not enough, «Code 9 does not exist» and «Quantity 0 is not valid» for the other rejections; at the end `Total: `, `With discount: `, `Final stock:` and one line per product, in code order, such as `Juice 7`.
:::

::: restriccion
Use at least three pure functions (for example, the price, the discount and the code check) and a record for the products.
:::

```programa rol=referencia
Registro Product
  Definir name Como Cadena;
  Definir price, stock Como Entero;
FinRegistro

Funcion amount <- LineAmount(price Como Entero, quantity Como Entero)
  Definir amount Como Entero;
  amount <- price * quantity;
FinFuncion

Funcion discounted <- WithDiscount(total Como Entero)
  Definir discounted Como Entero;
  discounted <- total - total div 10;
FinFuncion

Funcion isValid <- IsValidCode(code Como Entero)
  Definir isValid Como Logico;
  isValid <- code >= 1 Y code <= 5;
FinFuncion

SubProceso Catalog() Como Vector<Product>
  Definir products Como Vector<Product> <- Vector();
  products.Agregar(Product("Juice", 3, 10));
  products.Agregar(Product("Sandwich", 5, 5));
  products.Agregar(Product("Alfajor", 2, 8));
  products.Agregar(Product("Water", 1, 12));
  products.Agregar(Product("Fruit", 2, 6));
  Retornar products;
FinSubProceso

Algoritmo Kiosk
  Definir products Como Vector<Product> <- Catalog();
  Definir total Como Entero <- 0;
  Definir code, quantity Como Entero;
  Leer code;
  Mientras code <> 0 Hacer
    Leer quantity;
    Si NO IsValidCode(code) Entonces
      Escribir "Code ", code, " does not exist";
    Sino
      Si quantity < 1 Entonces
        Escribir "Quantity ", quantity, " is not valid";
      Sino
        Definir product Como Product <- products[code - 1];
        Si quantity > product.stock Entonces
          Escribir product.name, " x ", quantity, " rejected: stock is ", product.stock;
        Sino
          product.stock <- product.stock - quantity;
          products[code - 1] <- product;
          Escribir product.name, " x ", quantity, " = ", LineAmount(product.price, quantity);
          total <- total + LineAmount(product.price, quantity);
        FinSi
      FinSi
    FinSi
    Leer code;
  FinMientras
  Escribir "Total: ", total;
  Escribir "With discount: ", WithDiscount(total);
  Escribir "Final stock:";
  Para Cada product En products Hacer
    Escribir product.name, " ", product.stock;
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 6 ; 2 ; 5 ; 9 ; 1 ; 0 | Juice x 3 = 9 ⏎ Sandwich x 6 rejected: stock is 5 ⏎ Sandwich x 5 = 25 ⏎ Code 9 does not exist ⏎ Total: 34 ⏎ With discount: 31 ⏎ Final stock: ⏎ Juice 7 ⏎ Sandwich 0 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
visible | 0 | Total: 0 ⏎ With discount: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 5 ; 6 ; 5 ; 1 ; 0 | Fruit x 6 = 12 ⏎ Fruit x 1 rejected: stock is 0 ⏎ Total: 12 ⏎ With discount: 11 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 0
oculto | 1 ; 0 ; 0 | Quantity 0 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 7 ; 1 ; 2 ; 9 ; 3 ; -2 ; 0 | Code 7 does not exist ⏎ Sandwich x 9 rejected: stock is 5 ⏎ Quantity -2 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 4 ; 12 ; 1 ; 10 ; 3 ; 8 ; 0 | Water x 12 = 12 ⏎ Juice x 10 = 30 ⏎ Alfajor x 8 = 16 ⏎ Total: 58 ⏎ With discount: 53 ⏎ Final stock: ⏎ Juice 0 ⏎ Sandwich 5 ⏎ Alfajor 0 ⏎ Water 0 ⏎ Fruit 6
oculto | 2 ; 2 ; 2 ; 2 ; 2 ; 2 ; 0 | Sandwich x 2 = 10 ⏎ Sandwich x 2 = 10 ⏎ Sandwich x 2 rejected: stock is 1 ⏎ Total: 20 ⏎ With discount: 18 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 1 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 3 ; 1 ; 0 | Alfajor x 1 = 2 ⏎ Total: 2 ⏎ With discount: 2 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 7 ⏎ Water 12 ⏎ Fruit 6
```

::: pistas
1. Go back to your tree: which jobs are pure calculations and which ones read or write?
2. It is the till of [Part I](ruta:imperativo.proyecto), with the checks of [lesson 2.6](ruta:procedimental.fallos) and the records of [lesson 2.5](ruta:procedimental.datos).
3. A record `Product` with name, price and stock in a vector; pure functions for the price, the discount and the valid code; the main algorithm reads, checks and shows.
4. Check in order: code, amount and stock. Only if all three pass, take off the stock, put the card back in the vector, write the line and add. Close with the variant.
:::

::: variante
Also show how many sales were rejected during the day and for which reason.
:::

::: explicacion
The app's closed catalogue of checks cannot count pure functions or require a record: the restriction asks for them, and the cases tell the three rejections apart with their exact reason. Hidden cases: a sale that leaves the stock exactly at 0 and the next one rejected, a sale of 0 units, everything rejected, sales that use up three products, stock rejections after accepted sales and a single sale.
:::

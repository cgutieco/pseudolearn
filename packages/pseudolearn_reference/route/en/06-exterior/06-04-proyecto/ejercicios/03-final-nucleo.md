---
id: exterior.proyecto.final-nucleo
leccion: exterior.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The core of the kiosk
---

::: enunciado
Write the core of the kiosk, without files: start with the initial stock, read the sales, code and amount, until a 0, and check each one with the rules of Part II. At the end show the total, the total with discount and «Inventory: » with the final inventory in JSON, as in the lesson.
:::

::: restriccion
The JSON text of the inventory is built by a pure function, `InventoryJson`, which receives the list of products.
:::

```programa rol=referencia
Registro Product
  Definir name Como Cadena;
  Definir price, stock Como Entero;
FinRegistro

Funcion amount <- Amount(price Como Entero, quantity Como Entero)
  Definir amount Como Entero;
  amount <- price * quantity;
FinFuncion

Funcion discounted <- WithDiscount(total Como Entero)
  Definir discounted Como Entero;
  discounted <- total - total div 10;
FinFuncion

Funcion valid <- ValidCode(code Como Entero)
  Definir valid Como Logico;
  valid <- code >= 1 Y code <= 5;
FinFuncion

Funcion text <- InventoryJson(products Como Vector<Product>)
  Definir text Como Cadena <- "{";
  Para Cada product En products Hacer
    Si text <> "{" Entonces
      text <- text + ", ";
    FinSi
    text <- text + '"' + product.name + '": ' + ATexto(product.stock);
  FinPara
  text <- text + "}";
FinFuncion

SubProceso Catalog() Como Vector<Product>
  Definir products Como Vector<Product> <- Vector();
  products.Agregar(Product("Juice", 3, 10));
  products.Agregar(Product("Sandwich", 5, 5));
  products.Agregar(Product("Biscuit", 2, 8));
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
    Si NO ValidCode(code) Entonces
      Escribir "Code ", code, " does not exist";
    Sino
      Si quantity < 1 Entonces
        Escribir "Quantity ", quantity, " is not valid";
      Sino
        Definir product Como Product <- products[code - 1];
        Si quantity > product.stock Entonces
          Escribir product.name, " x ", quantity, " rejected: remaining ", product.stock;
        Sino
          product.stock <- product.stock - quantity;
          products[code - 1] <- product;
          Escribir product.name, " x ", quantity, " = ", Amount(product.price, quantity);
          total <- total + Amount(product.price, quantity);
        FinSi
      FinSi
    FinSi
    Leer code;
  FinMientras
  Escribir "Total: ", total;
  Escribir "With discount: ", WithDiscount(total);
  Escribir "Inventory: ", InventoryJson(products);
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 ; 0 | Juice x 3 = 9 ⏎ Sandwich x 2 = 10 ⏎ Total: 19 ⏎ With discount: 18 ⏎ Inventory: {"Juice": 7, "Sandwich": 3, "Biscuit": 8, "Water": 12, "Fruit": 6}
visible | 0 | Total: 0 ⏎ With discount: 0 ⏎ Inventory: {"Juice": 10, "Sandwich": 5, "Biscuit": 8, "Water": 12, "Fruit": 6}
oculto | 1 ; 3 ; 7 ; 1 ; 2 ; 2 ; 0 | Juice x 3 = 9 ⏎ Code 7 does not exist ⏎ Sandwich x 2 = 10 ⏎ Total: 19 ⏎ With discount: 18 ⏎ Inventory: {"Juice": 7, "Sandwich": 3, "Biscuit": 8, "Water": 12, "Fruit": 6}
oculto | 5 ; 6 ; 5 ; 1 ; 0 | Fruit x 6 = 12 ⏎ Fruit x 1 rejected: remaining 0 ⏎ Total: 12 ⏎ With discount: 11 ⏎ Inventory: {"Juice": 10, "Sandwich": 5, "Biscuit": 8, "Water": 12, "Fruit": 0}
oculto | 2 ; 9 ; 0 | Sandwich x 9 rejected: remaining 5 ⏎ Total: 0 ⏎ With discount: 0 ⏎ Inventory: {"Juice": 10, "Sandwich": 5, "Biscuit": 8, "Water": 12, "Fruit": 6}
oculto | 1 ; 1 ; 2 ; 1 ; 3 ; 1 ; 4 ; 1 ; 5 ; 1 ; 0 | Juice x 1 = 3 ⏎ Sandwich x 1 = 5 ⏎ Biscuit x 1 = 2 ⏎ Water x 1 = 1 ⏎ Fruit x 1 = 2 ⏎ Total: 13 ⏎ With discount: 12 ⏎ Inventory: {"Juice": 9, "Sandwich": 4, "Biscuit": 7, "Water": 11, "Fruit": 5}
oculto | 4 ; 99 ; 1 ; 50 ; 0 | Water x 99 rejected: remaining 12 ⏎ Juice x 50 rejected: remaining 10 ⏎ Total: 0 ⏎ With discount: 0 ⏎ Inventory: {"Juice": 10, "Sandwich": 5, "Biscuit": 8, "Water": 12, "Fruit": 6}
oculto | 9 ; 1 ; 2 ; 9 ; 0 | Code 9 does not exist ⏎ Sandwich x 9 rejected: remaining 5 ⏎ Total: 0 ⏎ With discount: 0 ⏎ Inventory: {"Juice": 10, "Sandwich": 5, "Biscuit": 8, "Water": 12, "Fruit": 6}
oculto | 3 ; 0 ; 0 | Quantity 0 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ Inventory: {"Juice": 10, "Sandwich": 5, "Biscuit": 8, "Water": 12, "Fruit": 6}
```

```aserciones
- declara-subprograma | InventoryJson | 1 | The function InventoryJson, which receives the list of products, is missing.
```

::: pistas
1. Go back to your card and your plan: which steps belong to the core?
2. It is the till with stock of Part II; only the closing changes.
3. `InventoryJson` walks through the products and joins each pair with commas, between braces, like the inventory of lesson 6.2.
4. The first entry carries no comma before it: check whether the text is still only the brace. Close with the variant.
:::

::: variante
Add to the closing how many sales were rejected.
:::

::: explicacion
Hidden cases: an invalid sale in the middle, a sale that leaves a stock at 0, one that asks for more than there is, the five products, large amounts rejected, a day with only rejections and an amount of 0. The keys of the JSON are the names of the catalogue, with a capital letter.
:::

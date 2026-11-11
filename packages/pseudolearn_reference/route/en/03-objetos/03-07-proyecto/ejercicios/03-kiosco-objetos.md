---
id: objetos.proyecto.kiosco-objetos
leccion: objetos.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The kiosk with objects
---

::: enunciado
Write the kiosk shared out into pieces. Read pairs of code and amount until code 0, then the way of paying (`cash` or `card`), and show the receipt of Part II with one more line after the discount: «To pay in cash: 31» or «To pay by card: 32». The card adds 5 % in whole pesos to the total with discount.
:::

::: restriccion
A contract `PaymentMethod` that `Cash` and `Card` meet, and a class `Inventory` with private stock that never goes negative.
:::

```programa rol=referencia
Interfaz PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero;
FinInterfaz

Clase Cash Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount;
  FinMetodo
FinClase

Clase Card Realiza PaymentMethod
  Metodo Charge(amount Como Entero) Como Entero
    Retornar amount + amount * 5 div 100;
  FinMetodo
FinClase

SubProceso ChargeWith<T: PaymentMethod>(payment Como T, amount Como Entero) Como Entero
  Retornar payment.Charge(amount);
FinSubProceso

Clase Product
  Definir name Como Cadena;
  Definir price Como Entero;

  Metodo Constructor(n Como Cadena, p Como Entero)
    Este.name <- n;
    Este.price <- p;
  FinMetodo

  Metodo Amount(quantity Como Entero) Como Entero
    Retornar Este.price * quantity;
  FinMetodo
FinClase

Clase Inventory
  Privado Definir stock Como Vector<Entero>;

  Metodo Constructor()
    Este.stock <- Vector();
    Este.stock.Agregar(10);
    Este.stock.Agregar(5);
    Este.stock.Agregar(8);
    Este.stock.Agregar(12);
    Este.stock.Agregar(6);
  FinMetodo

  Metodo Remaining(codigo Como Entero) Como Entero
    Retornar Este.stock[codigo - 1];
  FinMetodo

  Metodo Withdraw(codigo Como Entero, quantity Como Entero) Como Logico
    Si quantity > Este.stock[codigo - 1] Entonces
      Retornar Falso;
    FinSi
    Este.stock[codigo - 1] <- Este.stock[codigo - 1] - quantity;
    Retornar Verdadero;
  FinMetodo
FinClase

Clase Till
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo AddUp(amount Como Entero)
    Este.total <- Este.total + amount;
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo

  Metodo WithDiscount() Como Entero
    Retornar Este.total - Este.total div 10;
  FinMetodo
FinClase

SubProceso Catalog() Como Vector<Product>
  Definir products Como Vector<Product> <- Vector();
  products.Agregar(Nuevo Product("Juice", 3));
  products.Agregar(Nuevo Product("Sandwich", 5));
  products.Agregar(Nuevo Product("Alfajor", 2));
  products.Agregar(Nuevo Product("Water", 1));
  products.Agregar(Nuevo Product("Fruit", 2));
  Retornar products;
FinSubProceso

Algoritmo Kiosk
  Definir products Como Vector<Product> <- Catalog();
  Definir inventory Como Inventory <- Nuevo Inventory();
  Definir till Como Till <- Nuevo Till();
  Definir codigo, quantity Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer quantity;
    Si codigo < 1 O codigo > 5 Entonces
      Escribir "Code ", codigo, " does not exist";
    Sino
      Definir product Como Product <- products[codigo - 1];
      Si quantity < 1 Entonces
        Escribir "Quantity ", quantity, " is not valid";
      Sino
        Si inventory.Withdraw(codigo, quantity) Entonces
          till.AddUp(product.Amount(quantity));
          Escribir product.name, " x ", quantity, " = ", product.Amount(quantity);
        Sino
          Escribir product.name, " x ", quantity, " rejected: stock ", inventory.Remaining(codigo);
        FinSi
      FinSi
    FinSi
    Leer codigo;
  FinMientras
  Definir payment Como Cadena;
  Leer payment;
  Escribir "Total: ", till.Total();
  Escribir "With discount: ", till.WithDiscount();
  Si payment = "card" Entonces
    Escribir "To pay by card: ", ChargeWith(Nuevo Card(), till.WithDiscount());
  Sino
    Escribir "To pay in cash: ", ChargeWith(Nuevo Cash(), till.WithDiscount());
  FinSi
  Escribir "Final stock:";
  Para i <- 1 Hasta 5 Hacer
    Escribir products[i - 1].name, " ", inventory.Remaining(i);
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 6 ; 2 ; 5 ; 9 ; 1 ; 0 ; card | Juice x 3 = 9 ⏎ Sandwich x 6 rejected: stock 5 ⏎ Sandwich x 5 = 25 ⏎ Code 9 does not exist ⏎ Total: 34 ⏎ With discount: 31 ⏎ To pay by card: 32 ⏎ Final stock: ⏎ Juice 7 ⏎ Sandwich 0 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 1 ; 3 ; 2 ; 6 ; 2 ; 5 ; 9 ; 1 ; 0 ; cash | Juice x 3 = 9 ⏎ Sandwich x 6 rejected: stock 5 ⏎ Sandwich x 5 = 25 ⏎ Code 9 does not exist ⏎ Total: 34 ⏎ With discount: 31 ⏎ To pay in cash: 31 ⏎ Final stock: ⏎ Juice 7 ⏎ Sandwich 0 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 0 ; card | Total: 0 ⏎ With discount: 0 ⏎ To pay by card: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
visible | 0 ; cash | Total: 0 ⏎ With discount: 0 ⏎ To pay in cash: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 5 ; 6 ; 5 ; 1 ; 0 ; card | Fruit x 6 = 12 ⏎ Fruit x 1 rejected: stock 0 ⏎ Total: 12 ⏎ With discount: 11 ⏎ To pay by card: 11 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 0
oculto | 5 ; 6 ; 5 ; 1 ; 0 ; cash | Fruit x 6 = 12 ⏎ Fruit x 1 rejected: stock 0 ⏎ Total: 12 ⏎ With discount: 11 ⏎ To pay in cash: 11 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 0
oculto | 1 ; 0 ; 0 ; card | Quantity 0 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ To pay by card: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 1 ; 0 ; 0 ; cash | Quantity 0 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ To pay in cash: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 7 ; 1 ; 2 ; 9 ; 3 ; -2 ; 0 ; card | Code 7 does not exist ⏎ Sandwich x 9 rejected: stock 5 ⏎ Quantity -2 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ To pay by card: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 7 ; 1 ; 2 ; 9 ; 3 ; -2 ; 0 ; cash | Code 7 does not exist ⏎ Sandwich x 9 rejected: stock 5 ⏎ Quantity -2 is not valid ⏎ Total: 0 ⏎ With discount: 0 ⏎ To pay in cash: 0 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 4 ; 12 ; 1 ; 10 ; 3 ; 8 ; 0 ; card | Water x 12 = 12 ⏎ Juice x 10 = 30 ⏎ Alfajor x 8 = 16 ⏎ Total: 58 ⏎ With discount: 53 ⏎ To pay by card: 55 ⏎ Final stock: ⏎ Juice 0 ⏎ Sandwich 5 ⏎ Alfajor 0 ⏎ Water 0 ⏎ Fruit 6
oculto | 4 ; 12 ; 1 ; 10 ; 3 ; 8 ; 0 ; cash | Water x 12 = 12 ⏎ Juice x 10 = 30 ⏎ Alfajor x 8 = 16 ⏎ Total: 58 ⏎ With discount: 53 ⏎ To pay in cash: 53 ⏎ Final stock: ⏎ Juice 0 ⏎ Sandwich 5 ⏎ Alfajor 0 ⏎ Water 0 ⏎ Fruit 6
oculto | 2 ; 2 ; 2 ; 2 ; 2 ; 2 ; 0 ; card | Sandwich x 2 = 10 ⏎ Sandwich x 2 = 10 ⏎ Sandwich x 2 rejected: stock 1 ⏎ Total: 20 ⏎ With discount: 18 ⏎ To pay by card: 18 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 1 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 2 ; 2 ; 2 ; 2 ; 2 ; 2 ; 0 ; cash | Sandwich x 2 = 10 ⏎ Sandwich x 2 = 10 ⏎ Sandwich x 2 rejected: stock 1 ⏎ Total: 20 ⏎ With discount: 18 ⏎ To pay in cash: 18 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 1 ⏎ Alfajor 8 ⏎ Water 12 ⏎ Fruit 6
oculto | 3 ; 1 ; 0 ; card | Alfajor x 1 = 2 ⏎ Total: 2 ⏎ With discount: 2 ⏎ To pay by card: 2 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 7 ⏎ Water 12 ⏎ Fruit 6
oculto | 3 ; 1 ; 0 ; cash | Alfajor x 1 = 2 ⏎ Total: 2 ⏎ With discount: 2 ⏎ To pay in cash: 2 ⏎ Final stock: ⏎ Juice 10 ⏎ Sandwich 5 ⏎ Alfajor 7 ⏎ Water 12 ⏎ Fruit 6
```

```aserciones
- contiene | interfaz | The contract MedioDePago is missing.
- declara-miembro | Inventory | stock | privado | The stock of the class Inventory has to be private.
```

::: pistas
1. Go back to your cards: which piece has each value?
2. It is the till of [Part II](ruta:procedimental.proyecto) with the payment methods of [lesson 3.4](ruta:objetos.contratos) and the cards of [lesson 3.6](ruta:objetos.responsabilidades).
3. `Product` with its amount, `Inventory` with private stock and a `Withdraw` that allows no negatives, `Till` with the total and the discount, and both payment methods.
4. The main algorithm reads the sales, asks the inventory and the till for their part, and at the end asks the chosen method to charge. Close with the variant.
:::

::: variante
Add the 20-peso voucher as a third payment method, without touching the other pieces.
:::

::: explicacion
Each case of Part II appears twice, with cash and with card. The card on 0 charges 0. Frequent mistake: applying the surcharge before the discount, which gives another number.
:::

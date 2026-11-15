---
id: objetos.responsabilidades.mover-metodo
leccion: objetos.responsabilidades
tipo: modificar
nivel: brote
obligatorio: false
titulo: The amount in its place
---

::: enunciado
In this program, the till computes the amount of each sale with the product's price. Move that calculation to the product, which is the one that knows its price, without changing what the program shows.
:::

::: restriccion
`Product` has a public method `Amount(quantity)`, and the till asks it.
:::

```programa rol=inicial
Clase Product
  Definir name Como Cadena;
  Definir price Como Entero;

  Metodo Constructor(productName Como Cadena, productPrice Como Entero)
    Este.name <- productName;
    Este.price <- productPrice;
  FinMetodo
FinClase

Clase Inventory
  Privado Definir stock Como Diccionario<Cadena, Entero>;

  Metodo Constructor()
    Este.stock <- Diccionario();
  FinMetodo

  Metodo Load(name Como Cadena, quantity Como Entero)
    Este.stock[name] <- quantity;
  FinMetodo

  Metodo Withdraw(name Como Cadena, quantity Como Entero) Como Logico
    Si quantity > Este.stock[name] Entonces
      Retornar Falso;
    FinSi
    Este.stock[name] <- Este.stock[name] - quantity;
    Retornar Verdadero;
  FinMetodo
FinClase

Clase Receipt
  Privado Definir lines Como Vector<Cadena>;

  Metodo Constructor()
    Este.lines <- Vector();
  FinMetodo

  Metodo Note(line Como Cadena)
    Este.lines.Agregar(line);
  FinMetodo

  Metodo Display()
    Para Cada line En Este.lines Hacer
      Escribir line;
    FinPara
  FinMetodo
FinClase

Clase Till
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Sell(product Como Product, quantity Como Entero, inventory Como Inventory, receipt Como Receipt)
    Si inventory.Withdraw(product.name, quantity) Entonces
      Este.total <- Este.total + product.price * quantity;
      receipt.Note(product.name + " x " + ConvertirATexto(quantity) + " = " + ConvertirATexto(product.price * quantity));
    Sino
      receipt.Note(product.name + " x " + ConvertirATexto(quantity) + " rejected");
    FinSi
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir juices, sandwiches Como Entero;
  Leer juices;
  Leer sandwiches;
  Definir juice Como Product <- Nuevo Product("Juice", 3);
  Definir sandwich Como Product <- Nuevo Product("Sandwich", 5);
  Definir inventory Como Inventory <- Nuevo Inventory();
  inventory.Load("Juice", 10);
  inventory.Load("Sandwich", 5);
  Definir receipt Como Receipt <- Nuevo Receipt();
  Definir till Como Till <- Nuevo Till();
  till.Sell(juice, juices, inventory, receipt);
  till.Sell(sandwich, sandwiches, inventory, receipt);
  receipt.Display();
  Escribir "Total: ", till.Total();
FinAlgoritmo
```

```programa rol=referencia
Clase Product
  Definir name Como Cadena;
  Definir price Como Entero;

  Metodo Constructor(productName Como Cadena, productPrice Como Entero)
    Este.name <- productName;
    Este.price <- productPrice;
  FinMetodo

  Metodo Amount(quantity Como Entero) Como Entero
    Retornar Este.price * quantity;
  FinMetodo
FinClase

Clase Inventory
  Privado Definir stock Como Diccionario<Cadena, Entero>;

  Metodo Constructor()
    Este.stock <- Diccionario();
  FinMetodo

  Metodo Load(name Como Cadena, quantity Como Entero)
    Este.stock[name] <- quantity;
  FinMetodo

  Metodo Withdraw(name Como Cadena, quantity Como Entero) Como Logico
    Si quantity > Este.stock[name] Entonces
      Retornar Falso;
    FinSi
    Este.stock[name] <- Este.stock[name] - quantity;
    Retornar Verdadero;
  FinMetodo
FinClase

Clase Receipt
  Privado Definir lines Como Vector<Cadena>;

  Metodo Constructor()
    Este.lines <- Vector();
  FinMetodo

  Metodo Note(line Como Cadena)
    Este.lines.Agregar(line);
  FinMetodo

  Metodo Display()
    Para Cada line En Este.lines Hacer
      Escribir line;
    FinPara
  FinMetodo
FinClase

Clase Till
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Sell(product Como Product, quantity Como Entero, inventory Como Inventory, receipt Como Receipt)
    Si inventory.Withdraw(product.name, quantity) Entonces
      Este.total <- Este.total + product.Amount(quantity);
      receipt.Note(product.name + " x " + ConvertirATexto(quantity) + " = " + ConvertirATexto(product.Amount(quantity)));
    Sino
      receipt.Note(product.name + " x " + ConvertirATexto(quantity) + " rejected");
    FinSi
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir juices, sandwiches Como Entero;
  Leer juices;
  Leer sandwiches;
  Definir juice Como Product <- Nuevo Product("Juice", 3);
  Definir sandwich Como Product <- Nuevo Product("Sandwich", 5);
  Definir inventory Como Inventory <- Nuevo Inventory();
  inventory.Load("Juice", 10);
  inventory.Load("Sandwich", 5);
  Definir receipt Como Receipt <- Nuevo Receipt();
  Definir till Como Till <- Nuevo Till();
  till.Sell(juice, juices, inventory, receipt);
  till.Sell(sandwich, sandwiches, inventory, receipt);
  receipt.Display();
  Escribir "Total: ", till.Total();
FinAlgoritmo
```

```casos
visible | 3 ; 2 | Juice x 3 = 9 ⏎ Sandwich x 2 = 10 ⏎ Total: 19
visible | 0 ; 6 | Juice x 0 = 0 ⏎ Sandwich x 6 rejected ⏎ Total: 0
oculto | 10 ; 5 | Juice x 10 = 30 ⏎ Sandwich x 5 = 25 ⏎ Total: 55
oculto | 11 ; 1 | Juice x 11 rejected ⏎ Sandwich x 1 = 5 ⏎ Total: 5
oculto | 1 ; 1 | Juice x 1 = 3 ⏎ Sandwich x 1 = 5 ⏎ Total: 8
```

```aserciones
- declara-miembro | Product | Amount | publico | The public method Amount is missing from the class Product.
```

::: pistas
1. Which data does the calculation of the amount need? Which piece has it?
2. Look at the cards of [the lesson](ruta:objetos.responsabilidades).
3. The product gains a method; the till stops multiplying and asks it.
4. `Method Amount(quantity As Integer) As Integer` in `Product`, and the till uses `product.Amount(quantity)`. Close with the variant.
:::

::: variante
Add a 10 % tax to the sandwiches. Which pieces did you change?
:::

::: explicacion
The assertion checks that `Product` has `Amount`. The cases are those of the initial program: what is shown does not change, but the calculation goes where the information is.
:::

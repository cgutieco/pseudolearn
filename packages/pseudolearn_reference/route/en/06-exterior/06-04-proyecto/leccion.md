---
id: exterior.proyecto
numero: "P·F"
tipo: proyecto
titulo: "Final project: the complete kiosk"
duracion: 90
problema_breve: The kiosk that remembers its stock
necesita: [exterior.http]
introduce: []
usa: [nucleo-puro, funcion-pura, archivo, capacidad, limpieza-diferida, json, serializar, registro, vector]
---

::: frase
A complete program is a core that computes and an edge that talks to the world.
:::

## The problem {#problema}

::: problema
On opening, the kiosk reads its saved inventory; if it does not exist yet, it starts with the initial stock: juice 10, sandwich 5, biscuit 8, water 12 and fruit 6. It sells during the break with the rules of Part II: it checks the code and the stock of each sale. On closing, it shows the ticket with the total and the discount, and saves the new inventory for tomorrow.

**What does the complete kiosk look like?**
:::

## Try it {#intentalo}

::: intento
It is the first day and nothing is saved. 3 juices and 2 sandwiches are sold. What does the ticket say, and what stays saved?
:::

::: respuesta
The total is **19** and, with discount, **18**. The new inventory says juice **7** and sandwich **3**; the other products stay the same.
:::

## Understand {#entender fase=1}

The first exercise asks you to place each datum of the problem: what goes in, what is a fixed datum, what comes out and what does not matter. Notice that now something goes in that nobody writes during the break: the file from the day before.

::: recuerda termino=nucleo-puro
:::

## Plan {#planear fase=2}

The second exercise asks you to order the steps of the plan. Separate what touches the world, at the start and at the end, from what only computes, in the middle.

## Write {#escribir fase=3}

The third exercise is the pure core: the sales, the ticket and the final inventory in JSON, without files. The complete kiosk adds the edge: it loads the inventory, and at the end it saves it with a deferred cleanup that closes the file.

```programa id=kiosco-completo titulo="The complete kiosk, first day" ejecutar
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

Funcion stock <- SavedStock(inventory Como ValorJson, product Como Product)
  Definir stock Como Entero <- product.stock;
  Segun inventory.Campo(product.name) Hacer
    Algo(valor):
      Segun valor.ComoEntero() Hacer
        Algo(saved): stock <- saved;
        Nada: stock <- product.stock;
      FinSegun
    Nada: stock <- product.stock;
  FinSegun
FinFuncion

Funcion loaded <- ApplyInventory(products Como Vector<Product>, inventory Como ValorJson)
  Definir loaded Como Vector<Product> <- Vector();
  Para Cada product En products Hacer
    loaded.Agregar(Product(product.name, product.price, SavedStock(inventory, product)));
  FinPara
FinFuncion

SubProceso LoadInventory() Como Resultado<Cadena, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("inventory.json", "lectura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.LeerTexto();
FinSubProceso

SubProceso SaveInventory(text Como Cadena) Como Resultado<Entero, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("inventory.json", "escritura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.EscribirTexto(text);
FinSubProceso

Algoritmo Kiosk
  Definir products Como Vector<Product> <- Catalog();
  Segun LoadInventory() Hacer
    Exito(text):
      Segun AnalizarJson(text) Hacer
        Exito(inventory):
          products <- ApplyInventory(products, inventory);
          Escribir "Inventory loaded";
        Error(broken): Escribir "Broken inventory at column ", broken.JsonColumna, ": initial stock";
      FinSegun
    Error(report): Escribir "No saved inventory (", report.Codigo, "): initial stock";
  FinSegun
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
  Segun SaveInventory(InventoryJson(products)) Hacer
    Exito(bytes): Escribir "Inventory saved: ", bytes, " bytes";
    Error(report): Escribir "Could not save: ", report.Codigo;
  FinSegun
FinAlgoritmo
```

```entrada
1
3
2
2
0
```

```anfitrion
{}
```

```salida
No saved inventory (no_encontrado): initial stock
Juice x 3 = 9
Sandwich x 2 = 10
Total: 19
With discount: 18
Inventory saved: 66 bytes
```

## Test {#probar fase=4}

On the second day, the file already exists with the inventory the first one saved:

```programa id=kiosco-dia-dos titulo="The complete kiosk, second day" ejecutar
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

Funcion stock <- SavedStock(inventory Como ValorJson, product Como Product)
  Definir stock Como Entero <- product.stock;
  Segun inventory.Campo(product.name) Hacer
    Algo(valor):
      Segun valor.ComoEntero() Hacer
        Algo(saved): stock <- saved;
        Nada: stock <- product.stock;
      FinSegun
    Nada: stock <- product.stock;
  FinSegun
FinFuncion

Funcion loaded <- ApplyInventory(products Como Vector<Product>, inventory Como ValorJson)
  Definir loaded Como Vector<Product> <- Vector();
  Para Cada product En products Hacer
    loaded.Agregar(Product(product.name, product.price, SavedStock(inventory, product)));
  FinPara
FinFuncion

SubProceso LoadInventory() Como Resultado<Cadena, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("inventory.json", "lectura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.LeerTexto();
FinSubProceso

SubProceso SaveInventory(text Como Cadena) Como Resultado<Entero, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("inventory.json", "escritura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.EscribirTexto(text);
FinSubProceso

Algoritmo Kiosk
  Definir products Como Vector<Product> <- Catalog();
  Segun LoadInventory() Hacer
    Exito(text):
      Segun AnalizarJson(text) Hacer
        Exito(inventory):
          products <- ApplyInventory(products, inventory);
          Escribir "Inventory loaded";
        Error(broken): Escribir "Broken inventory at column ", broken.JsonColumna, ": initial stock";
      FinSegun
    Error(report): Escribir "No saved inventory (", report.Codigo, "): initial stock";
  FinSegun
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
  Segun SaveInventory(InventoryJson(products)) Hacer
    Exito(bytes): Escribir "Inventory saved: ", bytes, " bytes";
    Error(report): Escribir "Could not save: ", report.Codigo;
  FinSegun
FinAlgoritmo
```

```entrada
1
3
2
4
0
```

```anfitrion
{"files": {"inventory.json": "{\"Juice\": 7, \"Sandwich\": 3, \"Biscuit\": 8, \"Water\": 12, \"Fruit\": 6}"}}
```

```salida
Inventory loaded
Juice x 3 = 9
Sandwich x 4 rejected: remaining 3
Total: 9
With discount: 9
Inventory saved: 66 bytes
```

| Case | Why |
|---|---|
| The first day, without a file | it starts with the initial stock |
| The second day | the stock goes on where it was left |
| A sale that asks for more than there is | it is rejected with what is left |
| A broken file | it warns and starts with the initial stock |

## Improve {#mejorar fase=5}

In one sentence: «The kiosk loads its inventory on the edge, sells and computes in a pure core, and saves the new inventory on closing».

Look at which part of the program changed since Part II: the core, almost nothing. What is new lives on the edge, which is what talks to the world.

## What you learned {#aprendiste}

::: resumen
- A complete program brings together a pure core, tested with cases, and a thin edge that reads, writes and saves.
- The errors from outside, like a missing file, are expected situations that the program handles.
:::

## Practise {#practica}

::: practica
- exterior.proyecto.final-ficha
- exterior.proyecto.final-plan
- exterior.proyecto.final-nucleo
:::

::: profundizar titulo="Common pitfalls"
- **Planning before opening the editor.** The card and the plan are exercises for a reason: the program is the longest of the route.
- **Separating core and edge.** The checked exercise is only the core; the edge is tested in the lesson with the memory host.
- **Testing the day without a file.** It is the first case that anyone who uses the kiosk runs into.
:::

::: siguiente
You finished the route. From here, the Specification tells each part of the language in detail: choose a problem of your own and write it.
:::

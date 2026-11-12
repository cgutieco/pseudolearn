---
id: objetos.responsabilidades
numero: "3.6"
tipo: leccion
titulo: Whose job is it?
duracion: 30
problema_breve: The kiosk class that does everything
necesita: [objetos.componer]
introduce: [responsabilidad, tarjeta-de-responsabilidad, colaborador]
usa: [clase, objeto, metodo, encapsulamiento, composicion, interfaz]
---

::: frase
Each job belongs to the class that has the information to do it.
:::

## The problem {#problema}

::: problema
A single piece of the kiosk, `Kiosk`, reads the sales, computes the amounts, takes off the stock, applies the discount and writes the receipt. Every change, however small, touches that piece, and it already has **600 lines**.

**How is the work shared out?**
:::

## Try it {#intentalo}

::: intento
Make a list of the jobs of `Kiosk` and write next to each one which data it needs to be done.
:::

::: respuesta
Computing an amount needs the price of the product. Taking off the stock needs how much is left. Gathering the total and applying the discount need what was sold. Writing the receipt needs the lines of each sale. Each job needs different data: that is the clue that there are different pieces.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The same as before: what changes is who does each part.
- **What does it look like?** The modules of [lesson 2.7](ruta:procedimental.modulos): bringing together what changes for the same reason.
- **Who has the information to do this?** That question, asked for each job, shares out the work.

```figura id=ruta-tarjetas
pie: Each card says what a class knows or does and whom it asks for help.
```

## The new tool {#herramienta}

There is no new construction. There is a way of thinking. A [[def:responsabilidad|responsibility]] is something a class knows or does. To do it, it sometimes asks others for help: those are its [[def:colaborador|collaborators]]. A [[def:tarjeta-de-responsabilidad|responsibility card]] writes down, for each class, its job and whom it works with, before writing code.

| Class | Its job | Works with |
|---|---|---|
| `Product` | knowing its name and price; computing the amount of a quantity | — |
| `Inventory` | knowing how much is left of each product; taking away if there is enough | — |
| `Receipt` | noting lines and printing them | — |
| `Till` | registering a sale and gathering the total | `Product`, `Inventory`, `Receipt` |

## Write {#escribir fase=3}

```programa id=kiosco-repartido titulo="The kiosk shared out" ejecutar
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
  Definir juice Como Product <- Nuevo Product("Juice", 3);
  Definir sandwich Como Product <- Nuevo Product("Sandwich", 5);
  Definir inventory Como Inventory <- Nuevo Inventory();
  inventory.Load("Juice", 10);
  inventory.Load("Sandwich", 5);
  Definir receipt Como Receipt <- Nuevo Receipt();
  Definir till Como Till <- Nuevo Till();
  till.Sell(juice, 3, inventory, receipt);
  till.Sell(sandwich, 6, inventory, receipt);
  till.Sell(sandwich, 5, inventory, receipt);
  receipt.Display();
  Escribir "Total: ", till.Total();
FinAlgoritmo
```

```salida
Juice x 3 = 9
Sandwich x 6 rejected
Sandwich x 5 = 25
Total: 34
```

## Test {#probar fase=4}

The outputs are the same that the single class gave for the same sales: the behaviour did not change, the sharing out did. And now each piece can be tested on its own: `Product.Amount` with a table of cases, `Inventory.Withdraw` with an exact stock and one that is not enough.

## Improve {#mejorar fase=5}

In one sentence: «Each kiosk class does what its information allows, and the till coordinates the sale by asking them for help».

Changing the format of the receipt touches only `Receipt`. Adding a tax to the amount touches only `Product`. With a single class, each of those changes touched the same file of 600 lines.

## What you learned {#aprendiste}

::: resumen
- {responsabilidad,colaborador} A responsibility is something a class knows or does; its collaborators are the classes it asks for help.
- {tarjeta-de-responsabilidad} A responsibility card writes down a class, its job and whom it works with.
:::

## Practise {#practica}

::: practica
- objetos.responsabilidades.a-quien-le-toca
- objetos.responsabilidades.dos-disenos
- objetos.responsabilidades.colaboracion
- objetos.responsabilidades.mover-metodo
- objetos.responsabilidades.clase-dios
:::

::: profundizar titulo="Common pitfalls"
- **Classes named after verbs.** A «Calculator» is usually a job that belongs to another class.
- **Sharing out by size and not by information.** Splitting a big class into two halves does not help if both need the same data.
- **Cards with ten responsibilities.** A card that does not fit on the paper is a class that does too much.
:::

::: siguiente
The kiosk, now with objects.
:::

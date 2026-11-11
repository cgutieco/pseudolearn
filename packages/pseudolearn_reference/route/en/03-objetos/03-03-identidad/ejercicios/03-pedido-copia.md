---
id: objetos.identidad.pedido-copia
leccion: objetos.identidad
tipo: encontrar-error
nivel: brote
obligatorio: true
titulo: The order that was copied wrong
---

::: enunciado
The program reads two products for an order and a third one for a similar order. The receipt of the original order should show only its two products, but it also shows the third. Find the error and fix it.
:::

```programa rol=inicial
Clase Order
  Privado Definir products Como Vector<Cadena>;

  Metodo Constructor()
    Este.products <- Vector();
  FinMetodo

  Metodo Agregar(product Como Cadena)
    Este.products.Agregar(product);
  FinMetodo

  Metodo Receipt() Como Cadena
    Retornar Unir(Este.products, ", ");
  FinMetodo

  Metodo Duplicate() Como Order
    Definir duplicate Como Order <- Nuevo Order();
    Para Cada product En Este.products Hacer
      duplicate.Agregar(product);
    FinPara
    Retornar duplicate;
  FinMetodo
FinClase

Algoritmo Orders
  Definir primero, segundo, extra Como Cadena;
  Leer primero;
  Leer segundo;
  Leer extra;
  Definir order Como Order <- Nuevo Order();
  order.Agregar(primero);
  order.Agregar(segundo);
  Definir copyOrder Como Order <- order;
  copyOrder.Agregar(extra);
  Escribir "Original: ", order.Receipt();
  Escribir "Copy: ", copyOrder.Receipt();
FinAlgoritmo
```

```programa rol=referencia
Clase Order
  Privado Definir products Como Vector<Cadena>;

  Metodo Constructor()
    Este.products <- Vector();
  FinMetodo

  Metodo Agregar(product Como Cadena)
    Este.products.Agregar(product);
  FinMetodo

  Metodo Receipt() Como Cadena
    Retornar Unir(Este.products, ", ");
  FinMetodo

  Metodo Duplicate() Como Order
    Definir duplicate Como Order <- Nuevo Order();
    Para Cada product En Este.products Hacer
      duplicate.Agregar(product);
    FinPara
    Retornar duplicate;
  FinMetodo
FinClase

Algoritmo Orders
  Definir primero, segundo, extra Como Cadena;
  Leer primero;
  Leer segundo;
  Leer extra;
  Definir order Como Order <- Nuevo Order();
  order.Agregar(primero);
  order.Agregar(segundo);
  Definir copyOrder Como Order <- order.Duplicate();
  copyOrder.Agregar(extra);
  Escribir "Original: ", order.Receipt();
  Escribir "Copy: ", copyOrder.Receipt();
FinAlgoritmo
```

```casos
visible | Juice ; Sandwich ; Alfajor | Original: Juice, Sandwich ⏎ Copy: Juice, Sandwich, Alfajor
visible | Water ; Fruit ; Juice | Original: Water, Fruit ⏎ Copy: Water, Fruit, Juice
oculto | Juice ; Juice ; Juice | Original: Juice, Juice ⏎ Copy: Juice, Juice, Juice
oculto | A ; B ; C | Original: A, B ⏎ Copy: A, B, C
oculto | Alfajor ; Water ; Sandwich | Original: Alfajor, Water ⏎ Copy: Alfajor, Water, Sandwich
```

::: pistas
1. How many orders are there in the program? Count the times `New` appears.
2. Look at the arrows figure in [the lesson](ruta:objetos.identidad).
3. The order already knows how to make a copy with its own list.
4. Build the copy with `order.Duplicate()` instead of assigning the order. Close with the variant.
:::

::: variante
What would happen if the copy were built with `copy(order)`? Try it and explain the result.
:::

::: explicacion
`copyOrder <- order` gives the same order another name. The fix uses `Duplicate`, which builds a new list. `copy` is not enough: it shares the list.
:::

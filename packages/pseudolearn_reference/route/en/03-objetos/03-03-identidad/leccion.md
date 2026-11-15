---
id: objetos.identidad
numero: "3.3"
tipo: leccion
titulo: Two names, one object
duracion: 30
problema_breve: The order that was copied wrong
necesita: [objetos.invariantes]
introduce: [identidad, alias, referencia-a-objeto]
usa: [objeto, clase, metodo, registro, asignar, vector, encapsulamiento]
pieza: 6
---

::: frase
Assigning an object to another variable does not copy it: it gives the same object another name.
:::

## The problem {#problema}

::: problema
At the kiosk, an order keeps its list of products and knows how to add more. To put together a similar order, someone wrote `copyOrder <- order` and added a biscuit to `copyOrder`. The receipt of the original order **also** shows the biscuit.

**Why did it happen, and how do you make a real copy?**
:::

## Try it {#intentalo}

::: intento
Predict what the two receipts of this program show.

```programa id=pedido-alias titulo="An order and its «copy»"
Clase Order
  Privado Definir products Como Vector<Cadena>;

  Metodo Constructor()
    Este.products <- Vector();
  FinMetodo

  Metodo Add(product Como Cadena)
    Este.products.Agregar(product);
  FinMetodo

  Metodo Receipt() Como Cadena
    Retornar Unir(Este.products, ", ");
  FinMetodo

  Metodo Duplicate() Como Order
    Definir duplicate Como Order <- Nuevo Order();
    Para Cada product En Este.products Hacer
      duplicate.Add(product);
    FinPara
    Retornar duplicate;
  FinMetodo
FinClase

Algoritmo Orders
  Definir order Como Order <- Nuevo Order();
  order.Add("Juice");
  order.Add("Sandwich");
  Definir copyOrder Como Order <- order;
  copyOrder.Add("Alfajor");
  Escribir "Original: ", order.Receipt();
  Escribir "Copy: ", copyOrder.Receipt();
FinAlgoritmo
```
:::

::: respuesta
Both receipts say «Juice, Sandwich, Alfajor». `copyOrder` and `order` are two names for the same order: what is added through one name is seen through the other.
:::

## Understand and plan {#entender-planear fase=1-2}

::: recuerda termino=registro
:::

- **What goes in and what comes out?** The products of each order go in; their two receipts come out, each with its own.
- **What does it look like?** The record of [lesson 2.5](ruta:procedimental.datos), but the other way round: a record is copied when assigned; an object is not.
- **Who has the information to do this?** The order: it knows which products it has, so it can build a new order with the same ones.

## The new tool {#herramienta}

Each object has an [[def:identidad|identity]]: it is that object and not another, even if there is another one with the same data. An object variable does not keep the object: it keeps an [[def:referencia-a-objeto|object reference]], an arrow towards it. Two variables with the same arrow are [[def:alias|aliases]] of the same object.

```figura-especificacion seccion=objetos.copia figura=alias-copia
```

```figura id=ruta-flechas-pedido
pie: Assigning copies the arrow, not the order. To have two orders you have to create the second one.
paso: `order` and `copyOrder` point at the same order.
paso: A biscuit is added through `copyOrder`: there is only one order, so it is also seen through `order`.
paso: With a real copy there are two orders, each with its own list.
```

`copy(object)` creates a new object, but copies only one level: if the object holds another object or a vector, the copy shares it. The details are in [the Specification](especificacion:objetos.copia). That is why, when the object has a list, it is better for the object itself to know how to duplicate itself.

::: especificacion
- objetos.copia
:::

## Write {#escribir fase=3}

```programa id=pedidos titulo="An alias, a half copy and a real copy" ejecutar
Clase Order
  Privado Definir products Como Vector<Cadena>;

  Metodo Constructor()
    Este.products <- Vector();
  FinMetodo

  Metodo Add(product Como Cadena)
    Este.products.Agregar(product);
  FinMetodo

  Metodo Receipt() Como Cadena
    Retornar Unir(Este.products, ", ");
  FinMetodo

  Metodo Duplicate() Como Order
    Definir duplicate Como Order <- Nuevo Order();
    Para Cada product En Este.products Hacer
      duplicate.Add(product);
    FinPara
    Retornar duplicate;
  FinMetodo
FinClase

Algoritmo Orders
  Definir order Como Order <- Nuevo Order();
  order.Add("Juice");
  order.Add("Sandwich");
  Definir copyOrder Como Order <- order;
  copyOrder.Add("Alfajor");
  Escribir "Original: ", order.Receipt();
  Definir shallow Como Order <- Copiar(order);
  shallow.Add("Fruit");
  Escribir "Original: ", order.Receipt();
  Definir copy Como Order <- order.Duplicate();
  copy.Add("Water");
  Escribir "Original: ", order.Receipt();
  Escribir "Another: ", copy.Receipt();
FinAlgoritmo
```

```salida
Original: Juice, Sandwich, Alfajor
Original: Juice, Sandwich, Alfajor, Fruit
Original: Juice, Sandwich, Alfajor, Fruit
Another: Juice, Sandwich, Alfajor, Fruit, Water
```

The alias and the half copy change the original. Only `Duplicate`, which builds a new order with a new list, leaves the original alone.

## Test {#probar fase=4}

| How it was built | Does it share the list with the original? | Adding through the new name… |
|---|---|---|
| `copyOrder <- order` | yes: it is the same order | changes the original |
| `copy(order)` | yes: it copies only one level | changes the original |
| `order.Duplicate()` | no | does not change the original |

## Improve {#mejorar fase=5}

In one sentence: «Assigning an order gives it another name; to have another order, you have to ask the order to duplicate itself».

Sharing is not always an error. If all the kiosk screens have to see the same up-to-date stock, it is good that they share it. If each order belongs to a different customer, each one needs its own.

## What you learned {#aprendiste}

::: resumen
- {identidad} Identity is what makes an object that object and not another equal one.
- {alias,referencia-a-objeto} An object variable keeps a reference to the object; two variables with the same reference are aliases.
:::

## Practise {#practica}

::: practica
- objetos.identidad.alias-predecir
- objetos.identidad.mismo-o-distinto
- objetos.identidad.pedido-copia
- objetos.identidad.dos-tarjetas
- objetos.identidad.registro-u-objeto
:::

::: profundizar titulo="Common pitfalls"
- **«Assigning copies».** With records yes; with objects, no. The program in the try-it shows it.
- **Comparing objects with equals expecting to compare the content.** Two orders with the same products are not the same object; the details are in [the Specification](especificacion:objetos.copia).
- **«An alias is always an error».** Sometimes sharing is exactly what you want.
:::

::: siguiente
The till charges in cash, by card and with a voucher, and each new payment method forces you to touch the till. Can a method be added without touching it?
:::

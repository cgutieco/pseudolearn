---
id: objetos.componer
numero: "3.5"
tipo: leccion
titulo: Inherit or compose
duracion: 35
problema_breve: The yoghurt that expires and is on offer
necesita: [objetos.contratos]
introduce: [herencia, composicion, sobrescribir]
usa: [clase, objeto, metodo, constructor, despacho-dinamico, valor-opcional, interfaz]
---

::: frase
Inheriting says what something is; composing says what it has. When traits combine, composing scales better.
:::

## The problem {#problema}

::: problema
At the kiosk there are products that **expire** (they have a date) and products **on offer** (they have a percentage). Someone created `ExpiringProduct` and `OfferProduct` as particular cases of `Product`. Now a yoghurt arrives that expires **and** is on offer.

**Is a third particular case needed? And what if a third trait appears tomorrow?**
:::

## Try it {#intentalo}

::: intento
Count how many kinds of product would be needed if there were three traits that can be combined: it expires, it is on offer and it has a deposit bottle.
:::

::: respuesta
**8** would be needed: one without traits, three with one trait, three with two and one with all three. Each new trait doubles the amount.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** A product with its traits goes in; its final price comes out.
- **What does it look like?** The till of [lesson 3.4](ruta:objetos.contratos): each trait knows how it changes the price.
- **Who has the information to do this?** Every trait knows how to apply its part; the product knows which traits it has.

```figura id=ruta-explosion-clases
pie: With one particular case per combination, the kinds multiply. With traits the product holds inside, they add up.
paso: One particular case for each combination of traits: with three traits, eight kinds.
paso: A single product that has, or not, each trait: with three traits, three more pieces.
```

## The new tool {#herramienta}

[[def:herencia|Inheritance]] creates a class that is a particular case of another: `Class Cashier Inherits From Employee`. The child class has everything the parent has and can [[def:sobrescribir|override]] a method, that is, declare it again with the same signature to do it its own way. With `Super` it calls the parent's version.

```figura-especificacion seccion=objetos.herencia figura=herencia-despacho
```

```programa id=empleados titulo="A cashier is an employee" ejecutar
Clase Employee
  Definir name Como Cadena;

  Metodo Constructor(n Como Cadena)
    Este.name <- n;
  FinMetodo

  Metodo Introduce() Como Cadena
    Retornar "Hello, I am " + Este.name;
  FinMetodo
FinClase

Clase Cashier Hereda De Employee
  Metodo Constructor(n Como Cadena)
    Super.Constructor(n);
  FinMetodo

  Metodo Introduce() Como Cadena
    Retornar Super.Introduce() + " and I work the till";
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir ana Como Employee <- Nuevo Employee("Ana");
  Definir beto Como Employee <- Nuevo Cashier("Beto");
  Escribir ana.Introduce();
  Escribir beto.Introduce();
FinAlgoritmo
```

```salida
Hello, I am Ana
Hello, I am Beto and I work the till
```

[[def:composicion|Composition]], instead, builds an object from other objects it holds inside. A product **is** not an offer: it **has** an offer, or it does not. What the language does not have, such as abstract classes, is in [the Specification](especificacion:objetos.ausentes).

::: especificacion
- objetos.herencia
- objetos.ausentes
:::

## Write {#escribir fase=3}

```programa id=productos-componer titulo="A product that has traits" ejecutar
Clase Offer
  Definir percent Como Entero;
  Metodo Constructor(p Como Entero)
    Este.percent <- p;
  FinMetodo
  Metodo Apply(price Como Entero) Como Entero
    Retornar price - price * Este.percent div 100;
  FinMetodo
FinClase

Clase Expiry
  Definir days Como Entero;
  Metodo Constructor(d Como Entero)
    Este.days <- d;
  FinMetodo
  Metodo Apply(price Como Entero) Como Entero
    Si Este.days <= 2 Entonces
      Retornar price div 2;
    FinSi
    Retornar price;
  FinMetodo
FinClase

Clase Product
  Definir name Como Cadena;
  Definir price Como Entero;
  Definir offer Como Offer;
  Definir expiry Como Expiry;
  Metodo Constructor(n Como Cadena, p Como Entero)
    Este.name <- n;
    Este.price <- p;
    Este.offer <- Nuevo Offer(0);
    Este.expiry <- Nuevo Expiry(365);
  FinMetodo
  Metodo SetOffer(newOffer Como Offer)
    Este.offer <- newOffer;
  FinMetodo
  Metodo SetExpiry(date Como Expiry)
    Este.expiry <- date;
  FinMetodo
  Metodo FinalPrice() Como Entero
    Retornar Este.expiry.Apply(Este.offer.Apply(Este.price));
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir juice Como Product <- Nuevo Product("Juice", 30);
  Definir milk Como Product <- Nuevo Product("Milk", 40);
  milk.SetExpiry(Nuevo Expiry(1));
  Definir biscuits Como Product <- Nuevo Product("Biscuits", 20);
  biscuits.SetOffer(Nuevo Offer(50));
  Definir yoghurt Como Product <- Nuevo Product("Yoghurt", 40);
  yoghurt.SetOffer(Nuevo Offer(25));
  yoghurt.SetExpiry(Nuevo Expiry(1));
  Escribir juice.name, " ", juice.FinalPrice();
  Escribir milk.name, " ", milk.FinalPrice();
  Escribir biscuits.name, " ", biscuits.FinalPrice();
  Escribir yoghurt.name, " ", yoghurt.FinalPrice();
FinAlgoritmo
```

```salida
Juice 30
Milk 20
Biscuits 10
Yoghurt 15
```

Every product has an offer and an expiry: if it is not on offer, its offer is 0 %, and if it does not expire soon, its date is far away. A product that expires in two days or less sells at half price. The yoghurt has both traits: first the offer lowers it from 40 to 30, and then the expiry leaves it at 15.

## Test {#probar fase=4}

| Product | Traits | Expected |
|---|---|---|
| Juice, 30 | none | 30 |
| Milk, 40 | expires in 1 day | 20 |
| Biscuits, 20 | 50 % offer | 10 |
| Yoghurt, 40 | 25 % offer and expires in 1 day | 15 |

## Improve {#mejorar fase=5}

In one sentence: «A product has, or not, each trait, and its final price applies the ones it has».

A third trait, such as the deposit bottle, adds a class and an attribute, not four new particular cases.

## What you learned {#aprendiste}

::: resumen
- {herencia,sobrescribir} Inheriting creates a class that is a particular case of another and can override its methods.
- {composicion} Composing is building an object from other objects it holds inside.
:::

## Practise {#practica}

::: practica
- objetos.componer.es-o-tiene
- objetos.componer.super-predecir
- objetos.componer.yogur
- objetos.componer.empleados
- objetos.componer.cuando-heredar
:::

::: profundizar titulo="Common pitfalls"
- **Inheriting to reuse code.** When the child is not a particular case of the parent, inheritance ties together two things that will change differently.
- **Deep hierarchies.** Understanding a class means reading all its parents. Draw the hierarchy before adding a level.
- **«Composing is less object-oriented».** Composing is building objects from objects: it is as object-oriented as it gets.
:::

::: siguiente
The kiosk class does everything and has 600 lines. How do you decide whose job each thing is?
:::

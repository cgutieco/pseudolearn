---
id: objetos.componer.yogur
leccion: objetos.componer
tipo: modificar
nivel: brote
obligatorio: true
titulo: The yoghurt that had no place
---

::: enunciado
The program reads a type of product (1 normal, 2 expires soon, 3 on a 25 % offer, 4 both) and its price, and shows the final price. A product that expires soon sells at half price. Type 4 does not work: it is charged as a normal product. Rewrite the program so that the traits combine, without changing the prices of the other types.
:::

::: restriccion
The product holds its traits inside, instead of having a particular case for each combination.
:::

```programa rol=inicial
Clase Product
  Definir price Como Entero;

  Metodo Constructor(p Como Entero)
    Este.price <- p;
  FinMetodo

  Metodo FinalPrice() Como Entero
    Retornar Este.price;
  FinMetodo
FinClase

Clase ExpiringProduct Hereda De Product
  Metodo Constructor(p Como Entero)
    Super.Constructor(p);
  FinMetodo

  Metodo FinalPrice() Como Entero
    Retornar Este.price div 2;
  FinMetodo
FinClase

Clase OfferProduct Hereda De Product
  Metodo Constructor(p Como Entero)
    Super.Constructor(p);
  FinMetodo

  Metodo FinalPrice() Como Entero
    Retornar Este.price - Este.price * 25 div 100;
  FinMetodo
FinClase

Algoritmo Kiosk
  Definir yogurtKind, price Como Entero;
  Leer yogurtKind;
  Leer price;
  Definir product Como Product <- Nuevo Product(price);
  Si yogurtKind = 2 Entonces
    product <- Nuevo ExpiringProduct(price);
  FinSi
  Si yogurtKind = 3 Entonces
    product <- Nuevo OfferProduct(price);
  FinSi
  Escribir product.FinalPrice();
FinAlgoritmo
```

```programa rol=referencia
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
  Definir yogurtKind, price Como Entero;
  Leer yogurtKind;
  Leer price;
  Definir product Como Product <- Nuevo Product("Product", price);
  Si yogurtKind = 3 O yogurtKind = 4 Entonces
    product.SetOffer(Nuevo Offer(25));
  FinSi
  Si yogurtKind = 2 O yogurtKind = 4 Entonces
    product.SetExpiry(Nuevo Expiry(1));
  FinSi
  Escribir product.FinalPrice();
FinAlgoritmo
```

```casos
visible | 1 ; 30 | 30
visible | 4 ; 40 | 15
oculto | 2 ; 40 | 20
oculto | 3 ; 40 | 30
oculto | 4 ; 100 | 37
oculto | 1 ; 0 | 0
```

::: pistas
1. How many particular cases would be needed if one more trait were added?
2. Look at the product that has traits in [the lesson](ruta:objetos.componer).
3. Each trait is a class that knows how to apply its part to the price; the product has each one.
4. A `Product` that has an offer and an expiry (of 0 % and far away if they do not apply), and a `FinalPrice` that applies both. Close with the variant.
:::

::: variante
Add the deposit bottle, which adds 2 pesos to the price. How many new classes are needed?
:::

::: explicacion
The app's catalogue of checks cannot forbid a class from inheriting from another; the restriction asks for it and type 4 requires it, because with inheritance one more class would be needed. Hidden cases: each trait alone, the combination with another price and a price of 0.
:::

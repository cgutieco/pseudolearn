---
id: procedimental.datos.buscar-telefono
leccion: procedimental.datos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Finding a phone
---

::: enunciado
Read 4 contacts, each with name, phone and birthday month, and then a name. Show that name's phone, or «Not found». If the name appears more than once, show the first.
:::

```programa rol=referencia
Registro Contact
  Definir name, phone Como Cadena;
  Definir month Como Entero;
FinRegistro

Algoritmo PhoneSearch
  Definir contacts Como Vector<Contact> <- Vector();
  Definir name, phone Como Cadena;
  Definir month Como Entero;
  Para i <- 1 Hasta 4 Hacer
    Leer name;
    Leer phone;
    Leer month;
    contacts.Agregar(Contact(name, phone, month));
  FinPara
  Leer name;
  Definir found Como Cadena <- "Not found";
  Para Cada contact En contacts Hacer
    Si contact.name = name Y found = "Not found" Entonces
      found <- contact.phone;
    FinSi
  FinPara
  Escribir found;
FinAlgoritmo
```

```casos
visible | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Beto | 222
visible | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Ana | 111
oculto | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Eva | Not found
oculto | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Caro ; 333 ; 5 ; Dani ; 444 ; 3 ; Dani | 444
oculto | Ana ; 111 ; 5 ; Beto ; 222 ; 11 ; Ana ; 999 ; 2 ; Dani ; 444 ; 3 ; Ana | 111
```

::: pistas
1. Which shape of data best answers «the phone of this name»?
2. It is the search of the contact list in [the lesson](ruta:procedimental.datos).
3. Keep the contacts in a vector of cards and search it; be careful with repeated names.
4. Walk through the vector and keep the phone only the first time the name matches. Close with the variant.
:::

::: variante
Also show how many classmates have their birthday in the same month as the searched one.
:::

::: explicacion
Hidden cases: a missing name, the last one on the list and a repeated name (the first wins). Frequent mistake: replacing the phone on each match, which returns the last one.
:::

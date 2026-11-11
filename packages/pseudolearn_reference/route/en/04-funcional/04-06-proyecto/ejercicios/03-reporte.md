---
id: funcional.proyecto.reporte
leccion: funcional.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: The day's report
---

::: enunciado
Read the day's sales, code and amount, until a 0, and show the report with the exact format of the lesson: the total, the total with discount, how many sales were over 5 pesos and the star product, or «None» if there were no sales. In a tie of units, the product with the lowest code wins.
:::

::: restriccion
The calculation uses three functions, `Map`, `Filter` and `Reduce`, that receive another function as a value; the main algorithm only reads and shows.
:::

```programa rol=referencia
Registro Sale
  Definir codigo, quantity Como Entero;
FinRegistro

Funcion valor <- PriceOf(codigo Como Entero)
  Definir valor Como Entero;
  Segun codigo Hacer
    1:
      valor <- 3;
    2:
      valor <- 5;
    3:
      valor <- 2;
    4:
      valor <- 1;
    De Otro Modo:
      valor <- 2;
  FinSegun
FinFuncion

Funcion name <- NameOf(codigo Como Entero)
  Definir name Como Cadena;
  Segun codigo Hacer
    1:
      name <- "Juice";
    2:
      name <- "Sandwich";
    3:
      name <- "Biscuit";
    4:
      name <- "Water";
    De Otro Modo:
      name <- "Fruit";
  FinSegun
FinFuncion

Funcion amount <- Amount(sale Como Sale)
  Definir amount Como Entero;
  amount <- PriceOf(sale.codigo) * sale.quantity;
FinFuncion

Funcion big <- OverFive(figure Como Entero)
  Definir big Como Logico;
  big <- figure > 5;
FinFuncion

Funcion total <- Sum(a Como Entero, b Como Entero)
  Definir total Como Entero;
  total <- a + b;
FinFuncion

Funcion discounted <- WithDiscount(total Como Entero)
  Definir discounted Como Entero;
  discounted <- total - total div 10;
FinFuncion

Funcion mapped <- Map(sales Como Vector<Sale>, f Como Funcion(Sale) Como Entero)
  Definir mapped Como Vector<Entero> <- Vector();
  Para Cada sale En sales Hacer
    mapped.Agregar(f(sale));
  FinPara
FinFuncion

Funcion chosen <- Filter(amounts Como Vector<Entero>, condition Como Funcion(Entero) Como Logico)
  Definir chosen Como Vector<Entero> <- Vector();
  Para Cada entry En amounts Hacer
    Si condition(entry) Entonces
      chosen.Agregar(entry);
    FinSi
  FinPara
FinFuncion

Funcion accumulated <- Reduce(amounts Como Vector<Entero>, f Como Funcion(Entero, Entero) Como Entero, initial Como Entero)
  Definir accumulated Como Entero <- initial;
  Para Cada entry En amounts Hacer
    accumulated <- f(accumulated, entry);
  FinPara
FinFuncion

Funcion counter <- UnitsOf(codigo Como Entero)
  Definir counter Como Funcion(Sale) Como Entero <- Funcion(sale Como Sale) Como Entero
    Si sale.codigo = codigo Entonces
      Retornar sale.quantity;
    FinSi
    Retornar 0;
  FinFuncion;
FinFuncion

Funcion star <- Star(sales Como Vector<Sale>)
  Definir star Como Cadena <- "None";
  Definir best Como Entero <- 0;
  Para codigo <- 1 Hasta 5 Hacer
    Definir units Como Entero <- Reduce(Map(sales, UnitsOf(codigo)), Sum, 0);
    Si units > best Entonces
      best <- units;
      star <- NameOf(codigo);
    FinSi
  FinPara
FinFuncion

Algoritmo Report
  Definir sales Como Vector<Sale> <- Vector();
  Definir codigo, quantity Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer quantity;
    sales.Agregar(Sale(codigo, quantity));
    Leer codigo;
  FinMientras
  Definir amounts Como Vector<Entero> <- Map(sales, Amount);
  Definir total Como Entero <- Reduce(amounts, Sum, 0);
  Escribir "Total: ", total;
  Escribir "With discount: ", WithDiscount(total);
  Escribir "Sales over 5 pesos: ", Filter(amounts, OverFive).Longitud();
  Escribir "Star product: ", Star(sales);
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 ; 3 ; 1 ; 1 ; 1 ; 0 | Total: 24 ⏎ With discount: 22 ⏎ Sales over 5 pesos: 2 ⏎ Star product: Juice
visible | 0 | Total: 0 ⏎ With discount: 0 ⏎ Sales over 5 pesos: 0 ⏎ Star product: None
oculto | 3 ; 2 ; 4 ; 5 ; 5 ; 1 ; 0 | Total: 11 ⏎ With discount: 10 ⏎ Sales over 5 pesos: 0 ⏎ Star product: Water
oculto | 3 ; 2 ; 1 ; 2 ; 0 | Total: 10 ⏎ With discount: 9 ⏎ Sales over 5 pesos: 1 ⏎ Star product: Juice
oculto | 2 ; 10 ; 0 | Total: 50 ⏎ With discount: 45 ⏎ Sales over 5 pesos: 1 ⏎ Star product: Sandwich
oculto | 5 ; 1 ; 4 ; 1 ; 3 ; 1 ; 0 | Total: 5 ⏎ With discount: 5 ⏎ Sales over 5 pesos: 0 ⏎ Star product: Biscuit
oculto | 1 ; 2 ; 2 ; 1 ; 1 ; 2 ; 0 | Total: 17 ⏎ With discount: 16 ⏎ Sales over 5 pesos: 2 ⏎ Star product: Juice
oculto | 4 ; 30 ; 0 | Total: 30 ⏎ With discount: 27 ⏎ Sales over 5 pesos: 1 ⏎ Star product: Water
```

```aserciones
- declara-subprograma | Map | 2 | The function Map, which receives the list and the operation, is missing.
- declara-subprograma | Filter | 2 | The function Filter, which receives the list and the condition, is missing.
- declara-subprograma | Reduce | 3 | The function Reduce, which receives the list, the operation and the initial value, is missing.
```

::: pistas
1. Go back to your classification: which jobs belong to the core?
2. They are the three pieces of [lesson 4.2](ruta:funcional.orden-superior) and the factory of [lesson 4.3](ruta:funcional.clausuras), over a list of sales.
3. `Map` gives the amounts, `Reduce` adds them, `Filter` keeps those over 5; for the star, a factory that counts the units of a code.
4. The main algorithm reads the sales into a list and shows four expressions that compose the functions. Close with the variant.
:::

::: variante
Add the average amount per sale, without walking through the sales again.
:::

::: explicacion
The assertions check the three functions; that they show nothing is guaranteed by the engine, because they are pure. Hidden cases: all sales of 5 pesos or less, a tie (the lowest code wins), a single big sale and large amounts.
:::

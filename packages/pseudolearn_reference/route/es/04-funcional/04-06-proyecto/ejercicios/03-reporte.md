---
id: funcional.proyecto.reporte
leccion: funcional.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: El reporte del día
---

::: enunciado
Lee las ventas del día, código y cantidad, hasta un 0, y muestra el reporte con el formato exacto de la lección: el total, el total con descuento, cuántas ventas superaron los 5 pesos y el producto estrella, o «Ninguno» si no hubo ventas. En un empate de unidades gana el producto de menor código.
:::

::: restriccion
El cálculo usa tres funciones, `Mapear`, `Filtrar` y `Reducir`, que reciben otra función como dato; el algoritmo principal solo lee y muestra.
:::

```programa rol=referencia
Registro Venta
  Definir codigo, cantidad Como Entero;
FinRegistro

Funcion valor <- PrecioDe(codigo Como Entero)
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

Funcion nombre <- NombreDe(codigo Como Entero)
  Definir nombre Como Cadena;
  Segun codigo Hacer
    1:
      nombre <- "Jugo";
    2:
      nombre <- "Sándwich";
    3:
      nombre <- "Alfajor";
    4:
      nombre <- "Agua";
    De Otro Modo:
      nombre <- "Fruta";
  FinSegun
FinFuncion

Funcion importe <- Importe(venta Como Venta)
  Definir importe Como Entero;
  importe <- PrecioDe(venta.codigo) * venta.cantidad;
FinFuncion

Funcion grande <- MasDeCinco(monto Como Entero)
  Definir grande Como Logico;
  grande <- monto > 5;
FinFuncion

Funcion total <- Sumar(a Como Entero, b Como Entero)
  Definir total Como Entero;
  total <- a + b;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Funcion nuevos <- Mapear(ventas Como Vector<Venta>, f Como Funcion(Venta) Como Entero)
  Definir nuevos Como Vector<Entero> <- Vector();
  Para Cada venta En ventas Hacer
    nuevos.Agregar(f(venta));
  FinPara
FinFuncion

Funcion elegidos <- Filtrar(montos Como Vector<Entero>, condicion Como Funcion(Entero) Como Logico)
  Definir elegidos Como Vector<Entero> <- Vector();
  Para Cada monto En montos Hacer
    Si condicion(monto) Entonces
      elegidos.Agregar(monto);
    FinSi
  FinPara
FinFuncion

Funcion acumulado <- Reducir(montos Como Vector<Entero>, f Como Funcion(Entero, Entero) Como Entero, inicial Como Entero)
  Definir acumulado Como Entero <- inicial;
  Para Cada monto En montos Hacer
    acumulado <- f(acumulado, monto);
  FinPara
FinFuncion

Funcion contar <- UnidadesDel(codigo Como Entero)
  Definir contar Como Funcion(Venta) Como Entero <- Funcion(venta Como Venta) Como Entero
    Si venta.codigo = codigo Entonces
      Retornar venta.cantidad;
    FinSi
    Retornar 0;
  FinFuncion;
FinFuncion

Funcion estrella <- Estrella(ventas Como Vector<Venta>)
  Definir estrella Como Cadena <- "Ninguno";
  Definir mejores Como Entero <- 0;
  Para codigo <- 1 Hasta 5 Hacer
    Definir unidades Como Entero <- Reducir(Mapear(ventas, UnidadesDel(codigo)), Sumar, 0);
    Si unidades > mejores Entonces
      mejores <- unidades;
      estrella <- NombreDe(codigo);
    FinSi
  FinPara
FinFuncion

Algoritmo Reporte
  Definir ventas Como Vector<Venta> <- Vector();
  Definir codigo, cantidad Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer cantidad;
    ventas.Agregar(Venta(codigo, cantidad));
    Leer codigo;
  FinMientras
  Definir importes Como Vector<Entero> <- Mapear(ventas, Importe);
  Definir total Como Entero <- Reducir(importes, Sumar, 0);
  Escribir "Total: ", total;
  Escribir "Con descuento: ", ConDescuento(total);
  Escribir "Ventas de más de 5 pesos: ", Filtrar(importes, MasDeCinco).Longitud();
  Escribir "Producto estrella: ", Estrella(ventas);
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 ; 3 ; 1 ; 1 ; 1 ; 0 | Total: 24 ⏎ Con descuento: 22 ⏎ Ventas de más de 5 pesos: 2 ⏎ Producto estrella: Jugo
visible | 0 | Total: 0 ⏎ Con descuento: 0 ⏎ Ventas de más de 5 pesos: 0 ⏎ Producto estrella: Ninguno
oculto | 3 ; 2 ; 4 ; 5 ; 5 ; 1 ; 0 | Total: 11 ⏎ Con descuento: 10 ⏎ Ventas de más de 5 pesos: 0 ⏎ Producto estrella: Agua
oculto | 3 ; 2 ; 1 ; 2 ; 0 | Total: 10 ⏎ Con descuento: 9 ⏎ Ventas de más de 5 pesos: 1 ⏎ Producto estrella: Jugo
oculto | 2 ; 10 ; 0 | Total: 50 ⏎ Con descuento: 45 ⏎ Ventas de más de 5 pesos: 1 ⏎ Producto estrella: Sándwich
oculto | 5 ; 1 ; 4 ; 1 ; 3 ; 1 ; 0 | Total: 5 ⏎ Con descuento: 5 ⏎ Ventas de más de 5 pesos: 0 ⏎ Producto estrella: Alfajor
oculto | 1 ; 2 ; 2 ; 1 ; 1 ; 2 ; 0 | Total: 17 ⏎ Con descuento: 16 ⏎ Ventas de más de 5 pesos: 2 ⏎ Producto estrella: Jugo
oculto | 4 ; 30 ; 0 | Total: 30 ⏎ Con descuento: 27 ⏎ Ventas de más de 5 pesos: 1 ⏎ Producto estrella: Agua
```

```aserciones
- declara-subprograma | Mapear | 2 | Falta la función Mapear, que recibe la lista y la operación.
- declara-subprograma | Filtrar | 2 | Falta la función Filtrar, que recibe la lista y la condición.
- declara-subprograma | Reducir | 3 | Falta la función Reducir, que recibe la lista, la operación y el valor inicial.
```

::: pistas
1. Vuelve a tu clasificación: ¿qué tareas son del núcleo?
2. Son las tres piezas de [la lección 4.2](ruta:funcional.orden-superior) y la fábrica de [la lección 4.3](ruta:funcional.clausuras), sobre una lista de ventas.
3. `Mapear` da los importes, `Reducir` los suma, `Filtrar` deja los de más de 5; para la estrella, una fábrica que cuente las unidades de un código.
4. El principal lee las ventas en una lista y muestra cuatro expresiones que componen las funciones. Cierra con la variante.
:::

::: variante
Agrega el importe promedio por venta, sin recorrer las ventas otra vez.
:::

::: docentes
Las aserciones comprueban las tres funciones; que no muestren nada lo garantiza el motor, porque son puras. Casos ocultos: todas las ventas de 5 pesos o menos, un empate (gana el de menor código), una sola venta grande y cantidades grandes.
:::

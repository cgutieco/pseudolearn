---
id: objetos.responsabilidades.mover-metodo
leccion: objetos.responsabilidades
tipo: modificar
nivel: brote
obligatorio: false
titulo: El importe en su lugar
---

::: enunciado
En este programa, la caja calcula el importe de cada venta con el precio del producto. Mueve ese cálculo al producto, que es quien sabe su precio, sin cambiar lo que muestra el programa.
:::

::: restriccion
`Producto` tiene un método público `Importe(cantidad)`, y la caja se lo pide.
:::

```programa rol=inicial
Clase Producto
  Definir nombre Como Cadena;
  Definir precio Como Entero;

  Metodo Constructor(n Como Cadena, p Como Entero)
    Este.nombre <- n;
    Este.precio <- p;
  FinMetodo
FinClase

Clase Inventario
  Privado Definir stock Como Diccionario<Cadena, Entero>;

  Metodo Constructor()
    Este.stock <- Diccionario();
  FinMetodo

  Metodo Cargar(nombre Como Cadena, cantidad Como Entero)
    Este.stock[nombre] <- cantidad;
  FinMetodo

  Metodo Quitar(nombre Como Cadena, cantidad Como Entero) Como Logico
    Si cantidad > Este.stock[nombre] Entonces
      Retornar Falso;
    FinSi
    Este.stock[nombre] <- Este.stock[nombre] - cantidad;
    Retornar Verdadero;
  FinMetodo
FinClase

Clase Ticket
  Privado Definir lineas Como Vector<Cadena>;

  Metodo Constructor()
    Este.lineas <- Vector();
  FinMetodo

  Metodo Anotar(linea Como Cadena)
    Este.lineas.Agregar(linea);
  FinMetodo

  Metodo Imprimir()
    Para Cada linea En Este.lineas Hacer
      Escribir linea;
    FinPara
  FinMetodo
FinClase

Clase Caja
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Vender(producto Como Producto, cantidad Como Entero, inventario Como Inventario, ticket Como Ticket)
    Si inventario.Quitar(producto.nombre, cantidad) Entonces
      Este.total <- Este.total + producto.precio * cantidad;
      ticket.Anotar(producto.nombre + " x " + ConvertirATexto(cantidad) + " = " + ConvertirATexto(producto.precio * cantidad));
    Sino
      ticket.Anotar(producto.nombre + " x " + ConvertirATexto(cantidad) + " rechazado");
    FinSi
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir jugos, sandwiches Como Entero;
  Leer jugos;
  Leer sandwiches;
  Definir jugo Como Producto <- Nuevo Producto("Jugo", 3);
  Definir sandwich Como Producto <- Nuevo Producto("Sándwich", 5);
  Definir inventario Como Inventario <- Nuevo Inventario();
  inventario.Cargar("Jugo", 10);
  inventario.Cargar("Sándwich", 5);
  Definir ticket Como Ticket <- Nuevo Ticket();
  Definir caja Como Caja <- Nuevo Caja();
  caja.Vender(jugo, jugos, inventario, ticket);
  caja.Vender(sandwich, sandwiches, inventario, ticket);
  ticket.Imprimir();
  Escribir "Total: ", caja.Total();
FinAlgoritmo
```

```programa rol=referencia
Clase Producto
  Definir nombre Como Cadena;
  Definir precio Como Entero;

  Metodo Constructor(n Como Cadena, p Como Entero)
    Este.nombre <- n;
    Este.precio <- p;
  FinMetodo

  Metodo Importe(cantidad Como Entero) Como Entero
    Retornar Este.precio * cantidad;
  FinMetodo
FinClase

Clase Inventario
  Privado Definir stock Como Diccionario<Cadena, Entero>;

  Metodo Constructor()
    Este.stock <- Diccionario();
  FinMetodo

  Metodo Cargar(nombre Como Cadena, cantidad Como Entero)
    Este.stock[nombre] <- cantidad;
  FinMetodo

  Metodo Quitar(nombre Como Cadena, cantidad Como Entero) Como Logico
    Si cantidad > Este.stock[nombre] Entonces
      Retornar Falso;
    FinSi
    Este.stock[nombre] <- Este.stock[nombre] - cantidad;
    Retornar Verdadero;
  FinMetodo
FinClase

Clase Ticket
  Privado Definir lineas Como Vector<Cadena>;

  Metodo Constructor()
    Este.lineas <- Vector();
  FinMetodo

  Metodo Anotar(linea Como Cadena)
    Este.lineas.Agregar(linea);
  FinMetodo

  Metodo Imprimir()
    Para Cada linea En Este.lineas Hacer
      Escribir linea;
    FinPara
  FinMetodo
FinClase

Clase Caja
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Vender(producto Como Producto, cantidad Como Entero, inventario Como Inventario, ticket Como Ticket)
    Si inventario.Quitar(producto.nombre, cantidad) Entonces
      Este.total <- Este.total + producto.Importe(cantidad);
      ticket.Anotar(producto.nombre + " x " + ConvertirATexto(cantidad) + " = " + ConvertirATexto(producto.Importe(cantidad)));
    Sino
      ticket.Anotar(producto.nombre + " x " + ConvertirATexto(cantidad) + " rechazado");
    FinSi
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir jugos, sandwiches Como Entero;
  Leer jugos;
  Leer sandwiches;
  Definir jugo Como Producto <- Nuevo Producto("Jugo", 3);
  Definir sandwich Como Producto <- Nuevo Producto("Sándwich", 5);
  Definir inventario Como Inventario <- Nuevo Inventario();
  inventario.Cargar("Jugo", 10);
  inventario.Cargar("Sándwich", 5);
  Definir ticket Como Ticket <- Nuevo Ticket();
  Definir caja Como Caja <- Nuevo Caja();
  caja.Vender(jugo, jugos, inventario, ticket);
  caja.Vender(sandwich, sandwiches, inventario, ticket);
  ticket.Imprimir();
  Escribir "Total: ", caja.Total();
FinAlgoritmo
```

```casos
visible | 3 ; 2 | Jugo x 3 = 9 ⏎ Sándwich x 2 = 10 ⏎ Total: 19
visible | 0 ; 6 | Jugo x 0 = 0 ⏎ Sándwich x 6 rechazado ⏎ Total: 0
oculto | 10 ; 5 | Jugo x 10 = 30 ⏎ Sándwich x 5 = 25 ⏎ Total: 55
oculto | 11 ; 1 | Jugo x 11 rechazado ⏎ Sándwich x 1 = 5 ⏎ Total: 5
oculto | 1 ; 1 | Jugo x 1 = 3 ⏎ Sándwich x 1 = 5 ⏎ Total: 8
```

```aserciones
- declara-miembro | Producto | Importe | publico | Falta el método público Importe en la clase Producto.
```

::: pistas
1. ¿Qué dato necesita el cálculo del importe? ¿Qué pieza lo tiene?
2. Repasa las tarjetas de [la lección](ruta:objetos.responsabilidades).
3. El producto gana un método; la caja deja de multiplicar y se lo pide.
4. `Metodo Importe(cantidad Como Entero) Como Entero` en `Producto`, y la caja usa `producto.Importe(cantidad)`. Cierra con la variante.
:::

::: variante
Agrega un impuesto del 10 % a los sándwiches. ¿Qué piezas cambiaste?
:::

::: explicacion
La aserción comprueba que `Producto` tenga `Importe`. Los casos son los del programa inicial: lo que se muestra no cambia, pero el cálculo queda donde está la información.
:::

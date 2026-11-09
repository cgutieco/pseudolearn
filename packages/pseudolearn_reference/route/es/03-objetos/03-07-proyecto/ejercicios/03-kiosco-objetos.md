---
id: objetos.proyecto.kiosco-objetos
leccion: objetos.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: El kiosco con objetos
---

::: enunciado
Escribe el kiosco repartido en piezas. Lee pares de código y cantidad hasta el código 0, después el medio de pago (`efectivo` o `tarjeta`), y muestra el ticket de la Parte II con una línea más después del descuento: «A pagar en efectivo: 31» o «A pagar con tarjeta: 32». La tarjeta suma un 5 % en pesos enteros al total con descuento.
:::

::: restriccion
Un contrato `MedioDePago` que cumplen `Efectivo` y `Tarjeta`, y una clase `Inventario` con el stock privado que nunca queda negativo.
:::

```programa rol=referencia
Interfaz MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero;
FinInterfaz

Clase Efectivo Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto;
  FinMetodo
FinClase

Clase Tarjeta Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto + monto * 5 div 100;
  FinMetodo
FinClase

SubProceso CobrarCon<T: MedioDePago>(medio Como T, monto Como Entero) Como Entero
  Retornar medio.Cobrar(monto);
FinSubProceso

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
  Privado Definir stock Como Vector<Entero>;

  Metodo Constructor()
    Este.stock <- Vector();
    Este.stock.Agregar(10);
    Este.stock.Agregar(5);
    Este.stock.Agregar(8);
    Este.stock.Agregar(12);
    Este.stock.Agregar(6);
  FinMetodo

  Metodo Queda(codigo Como Entero) Como Entero
    Retornar Este.stock[codigo - 1];
  FinMetodo

  Metodo Quitar(codigo Como Entero, cantidad Como Entero) Como Logico
    Si cantidad > Este.stock[codigo - 1] Entonces
      Retornar Falso;
    FinSi
    Este.stock[codigo - 1] <- Este.stock[codigo - 1] - cantidad;
    Retornar Verdadero;
  FinMetodo
FinClase

Clase Caja
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Sumar(importe Como Entero)
    Este.total <- Este.total + importe;
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo

  Metodo ConDescuento() Como Entero
    Retornar Este.total - Este.total div 10;
  FinMetodo
FinClase

SubProceso Catalogo() Como Vector<Producto>
  Definir productos Como Vector<Producto> <- Vector();
  productos.Agregar(Nuevo Producto("Jugo", 3));
  productos.Agregar(Nuevo Producto("Sándwich", 5));
  productos.Agregar(Nuevo Producto("Alfajor", 2));
  productos.Agregar(Nuevo Producto("Agua", 1));
  productos.Agregar(Nuevo Producto("Fruta", 2));
  Retornar productos;
FinSubProceso

Algoritmo Kiosco
  Definir productos Como Vector<Producto> <- Catalogo();
  Definir inventario Como Inventario <- Nuevo Inventario();
  Definir caja Como Caja <- Nuevo Caja();
  Definir codigo, cantidad Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer cantidad;
    Si codigo < 1 O codigo > 5 Entonces
      Escribir "Código ", codigo, " no existe";
    Sino
      Definir producto Como Producto <- productos[codigo - 1];
      Si cantidad < 1 Entonces
        Escribir "Cantidad ", cantidad, " no válida";
      Sino
        Si inventario.Quitar(codigo, cantidad) Entonces
          caja.Sumar(producto.Importe(cantidad));
          Escribir producto.nombre, " x ", cantidad, " = ", producto.Importe(cantidad);
        Sino
          Escribir producto.nombre, " x ", cantidad, " rechazado: quedan ", inventario.Queda(codigo);
        FinSi
      FinSi
    FinSi
    Leer codigo;
  FinMientras
  Definir pago Como Cadena;
  Leer pago;
  Escribir "Total: ", caja.Total();
  Escribir "Con descuento: ", caja.ConDescuento();
  Si pago = "tarjeta" Entonces
    Escribir "A pagar con tarjeta: ", CobrarCon(Nuevo Tarjeta(), caja.ConDescuento());
  Sino
    Escribir "A pagar en efectivo: ", CobrarCon(Nuevo Efectivo(), caja.ConDescuento());
  FinSi
  Escribir "Stock final:";
  Para i <- 1 Hasta 5 Hacer
    Escribir productos[i - 1].nombre, " ", inventario.Queda(i);
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 6 ; 2 ; 5 ; 9 ; 1 ; 0 ; tarjeta | Jugo x 3 = 9 ⏎ Sándwich x 6 rechazado: quedan 5 ⏎ Sándwich x 5 = 25 ⏎ Código 9 no existe ⏎ Total: 34 ⏎ Con descuento: 31 ⏎ A pagar con tarjeta: 32 ⏎ Stock final: ⏎ Jugo 7 ⏎ Sándwich 0 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 1 ; 3 ; 2 ; 6 ; 2 ; 5 ; 9 ; 1 ; 0 ; efectivo | Jugo x 3 = 9 ⏎ Sándwich x 6 rechazado: quedan 5 ⏎ Sándwich x 5 = 25 ⏎ Código 9 no existe ⏎ Total: 34 ⏎ Con descuento: 31 ⏎ A pagar en efectivo: 31 ⏎ Stock final: ⏎ Jugo 7 ⏎ Sándwich 0 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 0 ; tarjeta | Total: 0 ⏎ Con descuento: 0 ⏎ A pagar con tarjeta: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
visible | 0 ; efectivo | Total: 0 ⏎ Con descuento: 0 ⏎ A pagar en efectivo: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 5 ; 6 ; 5 ; 1 ; 0 ; tarjeta | Fruta x 6 = 12 ⏎ Fruta x 1 rechazado: quedan 0 ⏎ Total: 12 ⏎ Con descuento: 11 ⏎ A pagar con tarjeta: 11 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 0
oculto | 5 ; 6 ; 5 ; 1 ; 0 ; efectivo | Fruta x 6 = 12 ⏎ Fruta x 1 rechazado: quedan 0 ⏎ Total: 12 ⏎ Con descuento: 11 ⏎ A pagar en efectivo: 11 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 0
oculto | 1 ; 0 ; 0 ; tarjeta | Cantidad 0 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ A pagar con tarjeta: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 1 ; 0 ; 0 ; efectivo | Cantidad 0 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ A pagar en efectivo: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 7 ; 1 ; 2 ; 9 ; 3 ; -2 ; 0 ; tarjeta | Código 7 no existe ⏎ Sándwich x 9 rechazado: quedan 5 ⏎ Cantidad -2 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ A pagar con tarjeta: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 7 ; 1 ; 2 ; 9 ; 3 ; -2 ; 0 ; efectivo | Código 7 no existe ⏎ Sándwich x 9 rechazado: quedan 5 ⏎ Cantidad -2 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ A pagar en efectivo: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 4 ; 12 ; 1 ; 10 ; 3 ; 8 ; 0 ; tarjeta | Agua x 12 = 12 ⏎ Jugo x 10 = 30 ⏎ Alfajor x 8 = 16 ⏎ Total: 58 ⏎ Con descuento: 53 ⏎ A pagar con tarjeta: 55 ⏎ Stock final: ⏎ Jugo 0 ⏎ Sándwich 5 ⏎ Alfajor 0 ⏎ Agua 0 ⏎ Fruta 6
oculto | 4 ; 12 ; 1 ; 10 ; 3 ; 8 ; 0 ; efectivo | Agua x 12 = 12 ⏎ Jugo x 10 = 30 ⏎ Alfajor x 8 = 16 ⏎ Total: 58 ⏎ Con descuento: 53 ⏎ A pagar en efectivo: 53 ⏎ Stock final: ⏎ Jugo 0 ⏎ Sándwich 5 ⏎ Alfajor 0 ⏎ Agua 0 ⏎ Fruta 6
oculto | 2 ; 2 ; 2 ; 2 ; 2 ; 2 ; 0 ; tarjeta | Sándwich x 2 = 10 ⏎ Sándwich x 2 = 10 ⏎ Sándwich x 2 rechazado: quedan 1 ⏎ Total: 20 ⏎ Con descuento: 18 ⏎ A pagar con tarjeta: 18 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 1 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 2 ; 2 ; 2 ; 2 ; 2 ; 2 ; 0 ; efectivo | Sándwich x 2 = 10 ⏎ Sándwich x 2 = 10 ⏎ Sándwich x 2 rechazado: quedan 1 ⏎ Total: 20 ⏎ Con descuento: 18 ⏎ A pagar en efectivo: 18 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 1 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 3 ; 1 ; 0 ; tarjeta | Alfajor x 1 = 2 ⏎ Total: 2 ⏎ Con descuento: 2 ⏎ A pagar con tarjeta: 2 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 7 ⏎ Agua 12 ⏎ Fruta 6
oculto | 3 ; 1 ; 0 ; efectivo | Alfajor x 1 = 2 ⏎ Total: 2 ⏎ Con descuento: 2 ⏎ A pagar en efectivo: 2 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 7 ⏎ Agua 12 ⏎ Fruta 6
```

```aserciones
- contiene | interfaz | Falta el contrato MedioDePago.
- declara-miembro | Inventario | stock | privado | El stock de la clase Inventario tiene que ser privado.
```

::: pistas
1. Vuelve a tus tarjetas: ¿qué pieza tiene cada dato?
2. Es la caja de [la Parte II](ruta:procedimental.proyecto) con los medios de pago de [la lección 3.4](ruta:objetos.contratos) y las tarjetas de [la lección 3.6](ruta:objetos.responsabilidades).
3. `Producto` con su importe, `Inventario` con el stock privado y un `Quitar` que no deja negativos, `Caja` con el total y el descuento, y los dos medios de pago.
4. El principal lee las ventas, le pide al inventario y a la caja lo que les toca, y al final le pide cobrar al medio elegido. Cierra con la variante.
:::

::: variante
Agrega el vale de 20 pesos como tercer medio de pago, sin tocar las otras piezas.
:::

::: explicacion
Cada caso de la Parte II aparece dos veces, con efectivo y con tarjeta. La tarjeta sobre 0 cobra 0. Error frecuente: aplicar el recargo antes del descuento, que da otro número.
:::

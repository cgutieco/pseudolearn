---
id: procedimental.proyecto.kiosco-partes
leccion: procedimental.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: La caja en partes
---

::: enunciado
Escribe la caja con stock. Lee pares de código y cantidad hasta el código 0 y muestra el ticket con el formato exacto de la lección: una línea `Jugo x 3 = 9` por venta aceptada, `Sándwich x 6 rechazado: quedan 5` si no alcanza el stock, «Código 9 no existe» y «Cantidad 0 no válida» para los otros rechazos; al final `Total: `, `Con descuento: `, `Stock final:` y una línea por producto, en el orden del código, como `Jugo 7`.
:::

::: restriccion
Usa al menos tres funciones puras (por ejemplo, el importe, el descuento y la validación del código) y un registro para los productos.
:::

```programa rol=referencia
Registro Producto
  Definir nombre Como Cadena;
  Definir precio, stock Como Entero;
FinRegistro

Funcion importe <- Importe(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Funcion valido <- CodigoValido(codigo Como Entero)
  Definir valido Como Logico;
  valido <- codigo >= 1 Y codigo <= 5;
FinFuncion

SubProceso Catalogo() Como Vector<Producto>
  Definir productos Como Vector<Producto> <- Vector();
  productos.Agregar(Producto("Jugo", 3, 10));
  productos.Agregar(Producto("Sándwich", 5, 5));
  productos.Agregar(Producto("Alfajor", 2, 8));
  productos.Agregar(Producto("Agua", 1, 12));
  productos.Agregar(Producto("Fruta", 2, 6));
  Retornar productos;
FinSubProceso

Algoritmo Kiosco
  Definir productos Como Vector<Producto> <- Catalogo();
  Definir total Como Entero <- 0;
  Definir codigo, cantidad Como Entero;
  Leer codigo;
  Mientras codigo <> 0 Hacer
    Leer cantidad;
    Si NO CodigoValido(codigo) Entonces
      Escribir "Código ", codigo, " no existe";
    Sino
      Si cantidad < 1 Entonces
        Escribir "Cantidad ", cantidad, " no válida";
      Sino
        Definir producto Como Producto <- productos[codigo - 1];
        Si cantidad > producto.stock Entonces
          Escribir producto.nombre, " x ", cantidad, " rechazado: quedan ", producto.stock;
        Sino
          producto.stock <- producto.stock - cantidad;
          productos[codigo - 1] <- producto;
          Escribir producto.nombre, " x ", cantidad, " = ", Importe(producto.precio, cantidad);
          total <- total + Importe(producto.precio, cantidad);
        FinSi
      FinSi
    FinSi
    Leer codigo;
  FinMientras
  Escribir "Total: ", total;
  Escribir "Con descuento: ", ConDescuento(total);
  Escribir "Stock final:";
  Para Cada producto En productos Hacer
    Escribir producto.nombre, " ", producto.stock;
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 6 ; 2 ; 5 ; 9 ; 1 ; 0 | Jugo x 3 = 9 ⏎ Sándwich x 6 rechazado: quedan 5 ⏎ Sándwich x 5 = 25 ⏎ Código 9 no existe ⏎ Total: 34 ⏎ Con descuento: 31 ⏎ Stock final: ⏎ Jugo 7 ⏎ Sándwich 0 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
visible | 0 | Total: 0 ⏎ Con descuento: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 5 ; 6 ; 5 ; 1 ; 0 | Fruta x 6 = 12 ⏎ Fruta x 1 rechazado: quedan 0 ⏎ Total: 12 ⏎ Con descuento: 11 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 0
oculto | 1 ; 0 ; 0 | Cantidad 0 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 7 ; 1 ; 2 ; 9 ; 3 ; -2 ; 0 | Código 7 no existe ⏎ Sándwich x 9 rechazado: quedan 5 ⏎ Cantidad -2 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 4 ; 12 ; 1 ; 10 ; 3 ; 8 ; 0 | Agua x 12 = 12 ⏎ Jugo x 10 = 30 ⏎ Alfajor x 8 = 16 ⏎ Total: 58 ⏎ Con descuento: 53 ⏎ Stock final: ⏎ Jugo 0 ⏎ Sándwich 5 ⏎ Alfajor 0 ⏎ Agua 0 ⏎ Fruta 6
oculto | 2 ; 2 ; 2 ; 2 ; 2 ; 2 ; 0 | Sándwich x 2 = 10 ⏎ Sándwich x 2 = 10 ⏎ Sándwich x 2 rechazado: quedan 1 ⏎ Total: 20 ⏎ Con descuento: 18 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 1 ⏎ Alfajor 8 ⏎ Agua 12 ⏎ Fruta 6
oculto | 3 ; 1 ; 0 | Alfajor x 1 = 2 ⏎ Total: 2 ⏎ Con descuento: 2 ⏎ Stock final: ⏎ Jugo 10 ⏎ Sándwich 5 ⏎ Alfajor 7 ⏎ Agua 12 ⏎ Fruta 6
```

::: pistas
1. Vuelve a tu árbol: ¿qué tareas son cálculos puros y cuáles leen o escriben?
2. Es la caja de [la Parte I](ruta:imperativo.proyecto), con las validaciones de [la lección 2.6](ruta:procedimental.fallos) y los registros de [la lección 2.5](ruta:procedimental.datos).
3. Un registro `Producto` con nombre, precio y stock en un vector; funciones puras para el importe, el descuento y el código válido; el principal lee, valida y muestra.
4. Valida en orden: código, cantidad y stock. Solo si pasan los tres, descuenta el stock, guarda la ficha de vuelta en el vector, escribe la línea y suma. Cierra con la variante.
:::

::: variante
Muestra también cuántas ventas se rechazaron en el día y por qué motivo.
:::

::: explicacion
El catálogo cerrado de comprobaciones de la app no puede contar funciones puras ni exigir un registro: lo pide la restricción, y los casos distinguen los tres rechazos con su motivo exacto. Casos ocultos: una venta que deja el stock en 0 justo y la siguiente rechazada, una venta de 0 unidades, todo rechazado, ventas que agotan tres productos, rechazos por stock después de ventas aceptadas y una sola venta.
:::

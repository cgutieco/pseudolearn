---
id: exterior.proyecto.final-nucleo
leccion: exterior.proyecto
tipo: resolver
nivel: arbol
obligatorio: true
titulo: El núcleo del kiosco
---

::: enunciado
Escribe el núcleo del kiosco, sin archivos: empieza con el stock inicial, lee las ventas, código y cantidad, hasta un 0, y revisa cada una con las reglas de la Parte II. Al final muestra el total, el total con descuento y «Inventario: » con el inventario final en JSON, como en la lección.
:::

::: restriccion
El texto JSON del inventario lo arma una función pura, `InventarioJson`, que recibe la lista de productos.
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

Funcion texto <- InventarioJson(productos Como Vector<Producto>)
  Definir texto Como Cadena <- "{";
  Para Cada producto En productos Hacer
    Si texto <> "{" Entonces
      texto <- texto + ", ";
    FinSi
    texto <- texto + '"' + producto.nombre + '": ' + ATexto(producto.stock);
  FinPara
  texto <- texto + "}";
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
  Escribir "Inventario: ", InventarioJson(productos);
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 ; 0 | Jugo x 3 = 9 ⏎ Sándwich x 2 = 10 ⏎ Total: 19 ⏎ Con descuento: 18 ⏎ Inventario: {"Jugo": 7, "Sándwich": 3, "Alfajor": 8, "Agua": 12, "Fruta": 6}
visible | 0 | Total: 0 ⏎ Con descuento: 0 ⏎ Inventario: {"Jugo": 10, "Sándwich": 5, "Alfajor": 8, "Agua": 12, "Fruta": 6}
oculto | 1 ; 3 ; 7 ; 1 ; 2 ; 2 ; 0 | Jugo x 3 = 9 ⏎ Código 7 no existe ⏎ Sándwich x 2 = 10 ⏎ Total: 19 ⏎ Con descuento: 18 ⏎ Inventario: {"Jugo": 7, "Sándwich": 3, "Alfajor": 8, "Agua": 12, "Fruta": 6}
oculto | 5 ; 6 ; 5 ; 1 ; 0 | Fruta x 6 = 12 ⏎ Fruta x 1 rechazado: quedan 0 ⏎ Total: 12 ⏎ Con descuento: 11 ⏎ Inventario: {"Jugo": 10, "Sándwich": 5, "Alfajor": 8, "Agua": 12, "Fruta": 0}
oculto | 2 ; 9 ; 0 | Sándwich x 9 rechazado: quedan 5 ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Inventario: {"Jugo": 10, "Sándwich": 5, "Alfajor": 8, "Agua": 12, "Fruta": 6}
oculto | 1 ; 1 ; 2 ; 1 ; 3 ; 1 ; 4 ; 1 ; 5 ; 1 ; 0 | Jugo x 1 = 3 ⏎ Sándwich x 1 = 5 ⏎ Alfajor x 1 = 2 ⏎ Agua x 1 = 1 ⏎ Fruta x 1 = 2 ⏎ Total: 13 ⏎ Con descuento: 12 ⏎ Inventario: {"Jugo": 9, "Sándwich": 4, "Alfajor": 7, "Agua": 11, "Fruta": 5}
oculto | 4 ; 99 ; 1 ; 50 ; 0 | Agua x 99 rechazado: quedan 12 ⏎ Jugo x 50 rechazado: quedan 10 ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Inventario: {"Jugo": 10, "Sándwich": 5, "Alfajor": 8, "Agua": 12, "Fruta": 6}
oculto | 9 ; 1 ; 2 ; 9 ; 0 | Código 9 no existe ⏎ Sándwich x 9 rechazado: quedan 5 ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Inventario: {"Jugo": 10, "Sándwich": 5, "Alfajor": 8, "Agua": 12, "Fruta": 6}
oculto | 3 ; 0 ; 0 | Cantidad 0 no válida ⏎ Total: 0 ⏎ Con descuento: 0 ⏎ Inventario: {"Jugo": 10, "Sándwich": 5, "Alfajor": 8, "Agua": 12, "Fruta": 6}
```

```aserciones
- declara-subprograma | InventarioJson | 1 | Falta la función InventarioJson, que recibe la lista de productos.
```

::: pistas
1. Vuelve a tu ficha y a tu plan: ¿qué pasos son del núcleo?
2. Es la caja con stock de la Parte II; solo cambia el cierre.
3. `InventarioJson` recorre los productos y une cada par con comas, entre llaves, como el inventario de la lección 6.2.
4. La primera entrada no lleva coma antes: revisa si el texto todavía es solo la llave. Cierra con la variante.
:::

::: variante
Agrega al cierre cuántas ventas se rechazaron.
:::

::: explicacion
Casos ocultos: una venta inválida en medio, una venta que deja un stock en 0, una que pide más de lo que hay, los cinco productos, cantidades grandes rechazadas, un día con solo rechazos y una cantidad 0. Las claves del JSON son los nombres del catálogo, con mayúscula y tilde.
:::

---
id: procedimental.datos.paralelos-a-registros
leccion: procedimental.datos
tipo: modificar
nivel: arbol
obligatorio: false
titulo: De filas separadas a fichas
---

::: enunciado
Este programa lee tres productos (nombre y precio) en filas separadas y los muestra. Ahora cada producto también trae su stock, que se lee después del precio. Cambia el programa para que muestre cada producto como `Jugo 3 (quedan 10)`.
:::

::: restriccion
Cada producto se guarda como una ficha con sus tres datos juntos, en un vector.
:::

```programa rol=inicial
Algoritmo Productos
  Dimension nombres[3] Como Cadena;
  Dimension precios[3] Como Entero;
  Para i <- 0 Hasta 2 Hacer
    Leer nombres[i];
    Leer precios[i];
  FinPara
  Para i <- 0 Hasta 2 Hacer
    Escribir nombres[i], " ", precios[i];
  FinPara
FinAlgoritmo
```

```programa rol=referencia
Registro Producto
  Definir nombre Como Cadena;
  Definir precio, stock Como Entero;
FinRegistro

Algoritmo Productos
  Definir productos Como Vector<Producto> <- Vector();
  Definir nombre Como Cadena;
  Definir precio, stock Como Entero;
  Para i <- 1 Hasta 3 Hacer
    Leer nombre;
    Leer precio;
    Leer stock;
    productos.Agregar(Producto(nombre, precio, stock));
  FinPara
  Para Cada producto En productos Hacer
    Escribir producto.nombre, " ", producto.precio, " (quedan ", producto.stock, ")";
  FinPara
FinAlgoritmo
```

```casos
visible | Jugo ; 3 ; 10 ; Agua ; 1 ; 12 ; Fruta ; 2 ; 6 | Jugo 3 (quedan 10) ⏎ Agua 1 (quedan 12) ⏎ Fruta 2 (quedan 6)
visible | Alfajor ; 2 ; 0 ; Jugo ; 3 ; 1 ; Agua ; 1 ; 2 | Alfajor 2 (quedan 0) ⏎ Jugo 3 (quedan 1) ⏎ Agua 1 (quedan 2)
oculto | A ; 1 ; 1 ; B ; 2 ; 2 ; C ; 3 ; 3 | A 1 (quedan 1) ⏎ B 2 (quedan 2) ⏎ C 3 (quedan 3)
oculto | Sándwich ; 5 ; 5 ; Sándwich ; 5 ; 4 ; Sándwich ; 5 ; 3 | Sándwich 5 (quedan 5) ⏎ Sándwich 5 (quedan 4) ⏎ Sándwich 5 (quedan 3)
oculto | Chicle ; 1 ; 100 ; Agua ; 1 ; 0 ; Fruta ; 2 ; 50 | Chicle 1 (quedan 100) ⏎ Agua 1 (quedan 0) ⏎ Fruta 2 (quedan 50)
```

::: pistas
1. Con filas separadas, ¿cuántas cosas hay que tocar para agregar el stock?
2. Repasa el final de [la lección](ruta:procedimental.datos): agregar un dato a una ficha es agregar un campo.
3. Define una ficha con nombre, precio y stock, y guarda las tres en un vector.
4. Un registro `Producto` con tres campos, un vector que se llena en el primer bucle y un `Para Cada` que muestra. Cierra con la variante.
:::

::: variante
Muestra al final el producto con menos stock.
:::

::: explicacion
El catálogo de comprobaciones de la app no puede exigir un registro; lo pide la restricción, y los casos exigen el stock nuevo. Error frecuente: agregar una tercera fila separada, que funciona pero deja las tres filas por alinear.
:::

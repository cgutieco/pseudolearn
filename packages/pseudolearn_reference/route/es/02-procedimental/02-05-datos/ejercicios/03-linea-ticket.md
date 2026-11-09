---
id: procedimental.datos.linea-ticket
leccion: procedimental.datos
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Una línea del ticket
---

::: enunciado
Lee el nombre, el precio y la cantidad de un producto, en ese orden, y muestra la línea del ticket con el formato `Jugo x 3 = 9`.
:::

::: restriccion
El nombre y el precio se guardan juntos en un registro `Producto`.
:::

```programa rol=referencia
Registro Producto
  Definir nombre Como Cadena;
  Definir precio Como Entero;
FinRegistro

Algoritmo Linea
  Definir nombre Como Cadena;
  Definir precio, cantidad Como Entero;
  Leer nombre;
  Leer precio;
  Leer cantidad;
  Definir producto Como Producto <- Producto(nombre, precio);
  Escribir producto.nombre, " x ", cantidad, " = ", producto.precio * cantidad;
FinAlgoritmo
```

```casos
visible | Jugo ; 3 ; 3 | Jugo x 3 = 9
visible | Sándwich ; 5 ; 2 | Sándwich x 2 = 10
oculto | Agua ; 1 ; 0 | Agua x 0 = 0
oculto | Fruta ; 2 ; 1 | Fruta x 1 = 2
oculto | Chicle ; 1 ; 25 | Chicle x 25 = 25
```

::: pistas
1. ¿Qué datos describen al producto y cuál describe la venta?
2. Mira el producto del kiosco de [la lección](ruta:procedimental.datos).
3. El registro guarda nombre y precio; la cantidad es de la venta.
4. Crea `Producto(nombre, precio)` y muestra sus campos con la cantidad. Cierra con la variante.
:::

::: variante
Agrega un campo `stock` y muestra cuánto queda después de la venta.
:::

::: explicacion
Casos ocultos: cantidad 0 y precio 1. El registro no cambia la salida; ordena los datos para la variante.
:::

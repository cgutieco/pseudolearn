---
id: objetos.componer.yogur
leccion: objetos.componer
tipo: modificar
nivel: brote
obligatorio: true
titulo: El yogur que no tenía lugar
---

::: enunciado
El programa lee un tipo de producto (1 normal, 2 vence pronto, 3 en oferta del 25 %, 4 las dos cosas) y su precio, y muestra el precio final. Un producto que vence pronto se vende a mitad de precio. El tipo 4 no funciona: se cobra como un producto normal. Reescribe el programa para que los rasgos se combinen, sin cambiar los precios de los otros tipos.
:::

::: restriccion
El producto tiene sus rasgos adentro, en lugar de un caso particular para cada combinación.
:::

```programa rol=inicial
Clase Producto
  Definir precio Como Entero;

  Metodo Constructor(p Como Entero)
    Este.precio <- p;
  FinMetodo

  Metodo PrecioFinal() Como Entero
    Retornar Este.precio;
  FinMetodo
FinClase

Clase ProductoVencible Hereda De Producto
  Metodo Constructor(p Como Entero)
    Super.Constructor(p);
  FinMetodo

  Metodo PrecioFinal() Como Entero
    Retornar Este.precio div 2;
  FinMetodo
FinClase

Clase ProductoEnOferta Hereda De Producto
  Metodo Constructor(p Como Entero)
    Super.Constructor(p);
  FinMetodo

  Metodo PrecioFinal() Como Entero
    Retornar Este.precio - Este.precio * 25 div 100;
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir tipo, precio Como Entero;
  Leer tipo;
  Leer precio;
  Definir producto Como Producto <- Nuevo Producto(precio);
  Si tipo = 2 Entonces
    producto <- Nuevo ProductoVencible(precio);
  FinSi
  Si tipo = 3 Entonces
    producto <- Nuevo ProductoEnOferta(precio);
  FinSi
  Escribir producto.PrecioFinal();
FinAlgoritmo
```

```programa rol=referencia
Clase Oferta
  Definir porcentaje Como Entero;
  Metodo Constructor(p Como Entero)
    Este.porcentaje <- p;
  FinMetodo
  Metodo Aplicar(precio Como Entero) Como Entero
    Retornar precio - precio * Este.porcentaje div 100;
  FinMetodo
FinClase

Clase Vencimiento
  Definir dias Como Entero;
  Metodo Constructor(d Como Entero)
    Este.dias <- d;
  FinMetodo
  Metodo Aplicar(precio Como Entero) Como Entero
    Si Este.dias <= 2 Entonces
      Retornar precio div 2;
    FinSi
    Retornar precio;
  FinMetodo
FinClase

Clase Producto
  Definir nombre Como Cadena;
  Definir precio Como Entero;
  Definir oferta Como Oferta;
  Definir vencimiento Como Vencimiento;
  Metodo Constructor(n Como Cadena, p Como Entero)
    Este.nombre <- n;
    Este.precio <- p;
    Este.oferta <- Nuevo Oferta(0);
    Este.vencimiento <- Nuevo Vencimiento(365);
  FinMetodo
  Metodo PonerOferta(nueva Como Oferta)
    Este.oferta <- nueva;
  FinMetodo
  Metodo PonerVencimiento(fecha Como Vencimiento)
    Este.vencimiento <- fecha;
  FinMetodo
  Metodo PrecioFinal() Como Entero
    Retornar Este.vencimiento.Aplicar(Este.oferta.Aplicar(Este.precio));
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir tipo, precio Como Entero;
  Leer tipo;
  Leer precio;
  Definir producto Como Producto <- Nuevo Producto("Producto", precio);
  Si tipo = 3 O tipo = 4 Entonces
    producto.PonerOferta(Nuevo Oferta(25));
  FinSi
  Si tipo = 2 O tipo = 4 Entonces
    producto.PonerVencimiento(Nuevo Vencimiento(1));
  FinSi
  Escribir producto.PrecioFinal();
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
1. ¿Cuántos casos particulares harían falta si se agregara un rasgo más?
2. Mira el producto que tiene rasgos en [la lección](ruta:objetos.componer).
3. Cada rasgo es una clase que sabe aplicar su parte al precio; el producto tiene cada uno, o no.
4. Un `Producto` que tiene una oferta y un vencimiento (del 0 % y lejano si no aplican), y un `PrecioFinal` que aplica los dos. Cierra con la variante.
:::

::: variante
Agrega el envase retornable, que suma 2 pesos al precio. ¿Cuántas clases nuevas hacen falta?
:::

::: docentes
El catálogo de comprobaciones de la app no puede prohibir que una clase herede de otra; la restricción lo pide y el tipo 4 lo exige, porque con herencia haría falta una clase más. Casos ocultos: cada rasgo solo, la combinación con otro precio y un precio 0.
:::

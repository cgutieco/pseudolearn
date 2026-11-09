---
id: objetos.responsabilidades
numero: "3.6"
tipo: leccion
titulo: ¿A quién le toca?
duracion: 30
problema_breve: La clase del kiosco que hace todo
necesita: [objetos.componer]
introduce: [responsabilidad, tarjeta-de-responsabilidad, colaborador]
usa: [clase, objeto, metodo, encapsulamiento, composicion, interfaz]
---

::: frase
Cada tarea le toca a la clase que tiene la información para hacerla.
:::

## El problema {#problema}

::: problema
Una sola pieza del kiosco, `Kiosco`, lee las ventas, calcula los importes, descuenta el stock, aplica el descuento y escribe el ticket. Cada cambio, por chico que sea, toca esa pieza, y ya tiene **600 líneas**.

**¿Cómo se reparte el trabajo?**
:::

## Inténtalo {#intentalo}

::: intento
Haz una lista de las tareas de `Kiosco` y escribe al lado qué dato necesita cada una para hacerse.
:::

::: respuesta
Calcular un importe necesita el precio del producto. Descontar el stock necesita cuánto queda. Juntar el total y aplicar el descuento necesitan lo vendido. Escribir el ticket necesita las líneas de cada venta. Cada tarea necesita datos distintos: es la pista de que hay piezas distintas.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Lo mismo que antes: lo que cambia es quién hace cada parte.
- **¿A qué se parece?** A los módulos de [la lección 2.7](ruta:procedimental.modulos): juntar lo que cambia por el mismo motivo.
- **¿Quién tiene la información para hacer esto?** Esa pregunta, hecha para cada tarea, reparte el trabajo.

```figura id=ruta-tarjetas
pie: Cada tarjeta dice qué sabe o hace una clase y a quién le pide ayuda.
```

## La herramienta nueva {#herramienta}

No hay construcción nueva. Hay una forma de pensar. Una [[def:responsabilidad|responsabilidad]] es algo que una clase sabe o hace. Para hacerla, a veces le pide ayuda a otras: esas son sus [[def:colaborador|colaboradoras]]. Una [[def:tarjeta-de-responsabilidad|tarjeta de responsabilidad]] anota, para cada clase, lo que le toca y con quién colabora, antes de escribir código.

| Clase | Le toca | Colabora con |
|---|---|---|
| `Producto` | saber su nombre y su precio; calcular el importe de una cantidad | — |
| `Inventario` | saber cuánto queda de cada producto; quitar si alcanza | — |
| `Ticket` | anotar líneas e imprimirlas | — |
| `Caja` | registrar una venta y juntar el total | `Producto`, `Inventario`, `Ticket` |

## Escribir {#escribir fase=3}

```programa id=kiosco-repartido titulo="El kiosco repartido" ejecutar
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
  Definir jugo Como Producto <- Nuevo Producto("Jugo", 3);
  Definir sandwich Como Producto <- Nuevo Producto("Sándwich", 5);
  Definir inventario Como Inventario <- Nuevo Inventario();
  inventario.Cargar("Jugo", 10);
  inventario.Cargar("Sándwich", 5);
  Definir ticket Como Ticket <- Nuevo Ticket();
  Definir caja Como Caja <- Nuevo Caja();
  caja.Vender(jugo, 3, inventario, ticket);
  caja.Vender(sandwich, 6, inventario, ticket);
  caja.Vender(sandwich, 5, inventario, ticket);
  ticket.Imprimir();
  Escribir "Total: ", caja.Total();
FinAlgoritmo
```

```salida
Jugo x 3 = 9
Sándwich x 6 rechazado
Sándwich x 5 = 25
Total: 34
```

## Probar {#probar fase=4}

Las salidas son las mismas que daba la clase única para las mismas ventas: el comportamiento no cambió, cambió el reparto. Y ahora cada pieza se puede probar sola: `Producto.Importe` con una tabla de casos, `Inventario.Quitar` con un stock justo y uno que no alcanza.

## Mejorar {#mejorar fase=5}

En una frase: «Cada clase del kiosco hace lo que le permite su información, y la caja coordina la venta pidiéndoles ayuda».

Cambiar el formato del ticket toca solo `Ticket`. Agregar un impuesto al importe toca solo `Producto`. Con una sola clase, cada uno de esos cambios tocaba el mismo archivo de 600 líneas.

## Lo que aprendiste {#aprendiste}

::: resumen
- {responsabilidad,colaborador} Una responsabilidad es algo que una clase sabe o hace; sus colaboradores son las clases a las que les pide ayuda.
- {tarjeta-de-responsabilidad} Una tarjeta de responsabilidad anota una clase, lo que le toca y con quién colabora.
:::

## Practica {#practica}

::: practica
- objetos.responsabilidades.a-quien-le-toca
- objetos.responsabilidades.dos-disenos
- objetos.responsabilidades.colaboracion
- objetos.responsabilidades.mover-metodo
- objetos.responsabilidades.clase-dios
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Clases con nombre de verbo.** Un «Calculador» suele ser una tarea que le toca a otra clase.
- **Repartir por tamaño y no por información.** Partir una clase grande en dos mitades no ayuda si las dos necesitan los mismos datos.
- **Tarjetas con diez responsabilidades.** Una tarjeta que no entra en el papel es una clase que hace demasiado.
:::

::: siguiente
El kiosco, ahora con objetos.
:::

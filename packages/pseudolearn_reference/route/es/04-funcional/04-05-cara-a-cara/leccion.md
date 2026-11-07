---
id: funcional.cara-a-cara
numero: "4.5"
tipo: leccion
titulo: Cara a cara
duracion: 30
problema_breve: Tres cambios para tres kioscos
necesita: [funcional.tipos-dominio]
introduce: []
usa: [paradigma, programacion-imperativa, programacion-orientada-a-objetos, programacion-funcional, interfaz, funcion-pura, nucleo-puro]
---

::: frase
Ningún paradigma gana siempre: cada uno hace fácil un tipo de cambio.
:::

## El problema {#problema}

::: problema
El kiosco va a recibir tres pedidos de cambio: agregar un **impuesto nuevo**, agregar un **medio de pago** y agregar un **reporte de ventas por día**. La caja está escrita de tres formas: con órdenes que cambian cajas, con piezas que guardan su estado y con cálculos que no cambian nada.

**¿Cuál conviene para cada cambio?**
:::

## Inténtalo {#intentalo}

::: intento
Elige a ojo, antes de mirar el código, qué versión cambiarías con menos esfuerzo para cada pedido.
:::

::: respuesta
El impuesto es una operación nueva sobre los mismos datos: la versión funcional lo agrega con una función. El medio de pago es un tipo nuevo de cosa que cumple un contrato: la versión con objetos lo agrega con una clase. El reporte es otra transformación de las ventas: otra vez, la funcional. La imperativa sirve mientras el programa sea corto.
:::

## Entender y planear {#entender-planear fase=1-2}

::: recuerda termino=paradigma
:::

- **¿Qué entra y qué sale?** Lo mismo en las tres versiones: el pedido de prueba, 3 jugos y 2 sándwiches, y su total.
- **¿A qué se parece?** A las tres cajas de [la Parte I](ruta:imperativo.proyecto), [la Parte III](ruta:objetos.proyecto) y [la lección 4.1](ruta:funcional.sin-cambiar).
- **¿Qué parte es cálculo y qué parte toca el mundo?** El total y el descuento son cálculo; mostrarlos toca el mundo.

```figura id=ruta-tres-kioscos
pie: El mismo ticket, pensado de tres formas.
paso: Órdenes que cambian cajas: el total va acumulando.
paso: Piezas que colaboran: la caja guarda su total y sabe descontar.
paso: Funciones que transforman: el total sale de una expresión.
```

## Escribir {#escribir fase=3}

Las tres versiones muestran lo mismo:

```programa id=kiosco-imperativo titulo="El kiosco imperativo" ejecutar
Algoritmo KioscoImperativo
  Definir total Como Entero <- 0;
  total <- total + 3 * 3;
  total <- total + 5 * 2;
  Escribir "Total: ", total;
  total <- total - total div 10;
  Escribir "Con descuento: ", total;
FinAlgoritmo
```

```salida
Total: 19
Con descuento: 18
```

```programa id=kiosco-objetos titulo="El kiosco con objetos" ejecutar
Clase Caja
  Privado Definir total Como Entero;

  Metodo Constructor()
    Este.total <- 0;
  FinMetodo

  Metodo Vender(precio Como Entero, cantidad Como Entero)
    Este.total <- Este.total + precio * cantidad;
  FinMetodo

  Metodo Total() Como Entero
    Retornar Este.total;
  FinMetodo

  Metodo ConDescuento() Como Entero
    Retornar Este.total - Este.total div 10;
  FinMetodo
FinClase

Algoritmo KioscoObjetos
  Definir caja Como Caja <- Nuevo Caja();
  caja.Vender(3, 3);
  caja.Vender(5, 2);
  Escribir "Total: ", caja.Total();
  Escribir "Con descuento: ", caja.ConDescuento();
FinAlgoritmo
```

```salida
Total: 19
Con descuento: 18
```

```programa id=kiosco-funcional titulo="El kiosco funcional" ejecutar
Funcion importe <- Linea(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Algoritmo KioscoFuncional
  Definir total Como Entero <- Linea(3, 3) + Linea(5, 2);
  Escribir "Total: ", total;
  Escribir "Con descuento: ", ConDescuento(total);
FinAlgoritmo
```

```salida
Total: 19
Con descuento: 18
```

## Probar {#probar fase=4}

Para cada cambio, cuántas partes hay que tocar en cada versión:

| Cambio | Imperativa | Con objetos | Funcional |
|---|---|---|---|
| Un impuesto nuevo | la línea del total y las que lo usan | un método de la caja, y quizá otro | una función nueva y la expresión del total |
| Un medio de pago | una decisión en el cobro | una clase nueva que cumple el contrato | una función nueva y una decisión al elegirla |
| Un reporte por día | otro recorrido con más cajas | un método más en la caja | una función más sobre las mismas ventas |

## Mejorar {#mejorar fase=5}

En una frase: «Se elige el paradigma por el tipo de cambio que se espera, no por gusto».

Un programa real suele mezclarlos: un núcleo funcional para los cálculos, objetos para lo que tiene estado, como el inventario, y un borde imperativo corto que lee y muestra.

## Lo que aprendiste {#aprendiste}

::: resumen
- Los objetos facilitan agregar tipos nuevos de cosas que comparten un contrato.
- Las funciones facilitan agregar operaciones nuevas sobre los mismos datos.
- Lo imperativo es directo para programas cortos que hacen una cosa.
:::

## Practica {#practica}

::: practica
- funcional.cara-a-cara.que-paradigma
- funcional.cara-a-cara.mismo-ticket
- funcional.cara-a-cara.impuesto
- funcional.cara-a-cara.medio-nuevo
- funcional.cara-a-cara.mezcla
:::

::: docentes
- **«Funcional es lo moderno».** Los tres paradigmas tienen décadas; lo que importa es qué cambio facilita cada uno.
- **Elegir por gusto.** Pide que nombren el cambio que esperan antes de elegir.
:::

::: siguiente
El kiosco funcional.
:::

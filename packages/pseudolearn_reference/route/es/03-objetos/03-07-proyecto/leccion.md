---
id: objetos.proyecto
numero: "P·III"
tipo: proyecto
titulo: "Proyecto: el kiosco con objetos"
duracion: 75
problema_breve: La caja con objetos y medios de pago
necesita: [objetos.responsabilidades]
introduce: []
usa: [clase, objeto, encapsulamiento, invariante-de-clase, interfaz, polimorfismo, responsabilidad, tarjeta-de-responsabilidad, colaborador]
---

::: frase
Un programa con objetos bien repartidos crece agregando piezas, no rompiendo las que ya están.
:::

## El problema {#problema}

::: problema
Es la caja con stock de [la Parte II](ruta:procedimental.proyecto), ahora repartida en piezas que cuidan sus propios datos. Al cerrar, el cliente elige pagar en **efectivo** o con **tarjeta**, que tiene un **5 %** de recargo en pesos enteros sobre el total con descuento. El stock **nunca** queda negativo.

**¿Cómo se reparte el trabajo entre las piezas?**
:::

## Inténtalo {#intentalo}

::: intento
Calcula cuánto se paga con tarjeta por las ventas del proyecto anterior: 3 jugos, 6 sándwiches rechazados, 5 sándwiches y un código 9.
:::

::: respuesta
El total con descuento es 31, como antes. Con tarjeta: 31 + `31 * 5 div 100`, es decir, **32**. En efectivo, 31.
:::

## Entender {#entender fase=1}

El formato del ticket es el de la Parte II, con una línea más después del descuento: «A pagar en efectivo: 31» o «A pagar con tarjeta: 32». El medio de pago se lee después del 0 que cierra la caja, como la palabra `efectivo` o `tarjeta`.

El primer ejercicio te pide repartir las responsabilidades en tarjetas.

::: recuerda termino=tarjeta-de-responsabilidad
:::

## Planear {#planear fase=2}

El segundo ejercicio te pide ordenar los pasos del plan. Piensa qué pieza tiene la información de cada paso: el producto sabe su precio, el inventario su stock, la caja su total y el medio de pago cómo se cobra.

## Escribir {#escribir fase=3}

El tercer ejercicio es el programa completo. Empieza por las piezas más simples, que no dependen de nadie: el producto, el inventario y los medios de pago. Después la caja, y al final el principal.

## Probar {#probar fase=4}

| Caso | Por qué |
|---|---|
| Las ventas de la Parte II con tarjeta | el recargo |
| Las mismas en efectivo | sin recargo |
| Un día sin ventas, con los dos medios | el total en 0 también se cobra en 0 |
| Una venta que agota el stock y otra rechazada | el invariante del inventario |

## Mejorar {#mejorar fase=5}

En una frase: «Cada pieza del kiosco cuida sus datos, y la caja coordina la venta y el cobro sin saber cómo cobra cada medio».

Agregar un medio de pago nuevo, como el vale, es una clase más que cumple el contrato. Ninguna otra pieza cambia.

## Lo que aprendiste {#aprendiste}

::: resumen
- Repartir por información deja cada cambio en una sola pieza.
- Un contrato permite agregar casos nuevos, como un medio de pago, sin tocar a quien los usa.
:::

## Practica {#practica}

::: practica
- objetos.proyecto.objetos-tarjetas
- objetos.proyecto.objetos-plan
- objetos.proyecto.kiosco-objetos
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Una pieza que hace todo, con otro nombre.** Cuando la caja calcula importes y descuenta stock, es la pieza que hace todo de la lección 3.6.
- **El stock público.** Cuando el principal puede cambiar el stock, el invariante depende de que nadie se equivoque.
- **Un medio de pago elegido con muchos caminos.** La elección va una sola vez, al cerrar; el cobro lo hace el medio.
:::

::: siguiente
Un día el total del kiosco salió distinto según en qué orden se sumaron los descuentos. ¿Se puede calcular sin cambiar nada?
:::

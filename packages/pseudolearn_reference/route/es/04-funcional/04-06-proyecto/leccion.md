---
id: funcional.proyecto
numero: "P·IV"
tipo: proyecto
titulo: "Proyecto: el kiosco funcional"
duracion: 60
problema_breve: El reporte del día
necesita: [funcional.cara-a-cara]
introduce: []
usa: [nucleo-puro, funcion-pura, mapear, filtrar, reducir, clausura, fabrica-de-funciones, registro, vector]
---

::: frase
Cuando todo el cálculo vive en un núcleo puro, el reporte se arma componiendo piezas que se prueban solas.
:::

## El problema {#problema}

::: problema
Al final del día, la caja tiene la lista de ventas: código de producto y cantidad, hasta un 0. Los precios son los del kiosco. Hay que mostrar un **reporte**: el total, el total con descuento, cuántas ventas superaron los **5 pesos** y el **producto estrella**, el que más unidades vendió. Las cuentas no leen ni muestran nada: eso queda para el principio y el final.

**¿Cómo es el reporte?**
:::

## Inténtalo {#intentalo}

::: intento
Arma a mano el reporte de un día con estas ventas: 3 jugos, 2 sándwiches, 1 alfajor y 1 jugo más.
:::

::: respuesta
Los importes son 9, 10, 2 y 3. El total es **24**; con descuento, **22**. Superan los 5 pesos **2** ventas, la de 9 y la de 10. El producto estrella es el **Jugo**, con 4 unidades.
:::

## Entender {#entender fase=1}

El formato del reporte es exacto. Para el ejemplo de la consigna:

- `Total: 24`
- `Con descuento: 22`
- `Ventas de más de 5 pesos: 2`
- `Producto estrella: Jugo`

Un día sin ventas muestra todo en 0 y `Producto estrella: Ninguno`. Si dos productos empatan en unidades, gana el de menor código.

El primer ejercicio te pide separar las tareas del núcleo y del borde.

::: recuerda termino=nucleo-puro
:::

## Planear {#planear fase=2}

El segundo ejercicio te pide ordenar los pasos del plan. Piensa qué se calcula con cada una de las tres piezas de [la lección 4.2](ruta:funcional.orden-superior): los importes, las ventas grandes y el total.

## Escribir {#escribir fase=3}

El tercer ejercicio es el programa completo. Empieza por las funciones chicas, que se prueban solas: el precio, el importe y el descuento. Después `Mapear`, `Filtrar` y `Reducir`. Para el producto estrella, una fábrica de funciones que cuente las unidades de un código, como en [la lección 4.3](ruta:funcional.clausuras).

## Probar {#probar fase=4}

| Caso | Por qué |
|---|---|
| El ejemplo de la consigna | el caso normal |
| Un día sin ventas | el total en 0 y ningún producto estrella |
| Todas las ventas de 5 pesos o menos | ninguna venta grande |
| Dos productos con las mismas unidades | el desempate |

## Mejorar {#mejorar fase=5}

En una frase: «El reporte lee las ventas en el borde y calcula todo lo demás componiendo funciones puras».

¿Y si mañana piden el promedio por venta? Es otra función sobre los mismos importes: el resto del reporte no cambia.

## Lo que aprendiste {#aprendiste}

::: resumen
- Un reporte entero se arma componiendo funciones puras que se prueban por separado.
- El borde solo lee y muestra; el núcleo hace todas las cuentas.
:::

## Practica {#practica}

::: practica
- funcional.proyecto.reporte-nucleo
- funcional.proyecto.reporte-plan
- funcional.proyecto.reporte
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Mostrar desde una función.** El motor lo rechaza; aprovéchalo para recordar dónde va cada cosa.
- **Recorrer las ventas cuatro veces a mano.** Es correcto, pero el ejercicio pide usar las tres piezas de la Parte IV.
- **El desempate.** Con `>` estricto gana el primero que se revisa, que es el de menor código.
:::

::: siguiente
En la cocina del kiosco trabajan tres personas a la vez. ¿Cómo se escribe un programa donde varias cosas avanzan al mismo tiempo?
:::

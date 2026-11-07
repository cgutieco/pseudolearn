---
id: imperativo.proyecto
numero: "P·I"
tipo: proyecto
titulo: "Proyecto: la caja del kiosco"
duracion: 60
problema_breve: El ticket del día
necesita: [imperativo.estrategias]
introduce: []
usa: [ficha-del-problema, centinela, arreglo, acumulador, contador, mejor-hasta-ahora, caso-borde, esquema]
---

::: frase
Un proyecto es un problema grande que se resuelve con las herramientas que ya tienes.
:::

## El problema {#problema}

::: problema
Durante el recreo, la caja del kiosco anota cada venta como un **código de producto** y una **cantidad**. Al cerrar, escribe el código **0**. Los productos son: 1 Jugo a 3 pesos, 2 Sándwich a 5, 3 Alfajor a 2, 4 Agua a 1 y 5 Fruta a 2. Por cada 10 pesos de compra se descuenta 1 peso.

Hay que mostrar el ticket del día: una línea por venta con el producto, la cantidad y el importe; el total; el total con descuento; y el producto que más unidades vendió. Un código que no existe se informa y se ignora.

**¿Cómo es el programa de la caja?**
:::

## Inténtalo {#intentalo}

::: intento
Arma a mano el ticket de un recreo con estas ventas: 3 jugos, 2 sándwiches, 1 alfajor y 1 jugo más.
:::

::: respuesta
Los importes son 9, 10, 2 y 3. El total es **24**; con el descuento de 2 pesos queda **22**. El más vendido es el **Jugo**, con 4 unidades.
:::

## Entender {#entender fase=1}

Este problema tiene muchos datos, y no todos importan igual. Antes de escribir nada, llena la ficha del problema: es el primer ejercicio del proyecto.

::: recuerda termino=ficha-del-problema
:::

El formato del ticket tiene que ser exacto. Para el ejemplo de la consigna:

- `Jugo x 3 = 9`
- `Sándwich x 2 = 10`
- `Alfajor x 1 = 2`
- `Jugo x 1 = 3`
- `Total: 24`
- `Con descuento: 22`
- `Más vendido: Jugo`

Si una venta trae un código que no existe, por ejemplo el 7, la línea dice «Código 7 no existe» y la cantidad se lee pero se ignora. Un día sin ventas muestra total 0, con descuento 0 y `Más vendido: Ninguno`. Si dos productos empatan en unidades, gana el de menor código.

## Planear {#planear fase=2}

El plan también es tuyo: el segundo ejercicio te pide ordenar sus pasos. Piensa en los esquemas que ya conoces: ¿qué se acumula, qué se cuenta, qué se busca?

::: recuerda termino=esquema
:::

## Escribir {#escribir fase=3}

El tercer ejercicio es el programa completo. Escríbelo paso por paso, ejecutando después de cada parte: primero leer las ventas hasta el 0, después las líneas del ticket, después los totales y al final el más vendido.

## Probar {#probar fase=4}

Antes de dar el programa por terminado, pruébalo con:

| Caso | Por qué |
|---|---|
| El ejemplo de la consigna | el caso normal |
| Un 0 directo | el día sin ventas: total 0 y «Ninguno» |
| Un código inválido en medio | se informa y no rompe lo demás |
| Dos productos empatados | gana el de menor código |
| Una sola venta | el ticket más corto |

## Mejorar {#mejorar fase=5}

En una frase: «El programa lee las ventas hasta el 0, escribe cada línea del ticket y cierra con el total, el descuento y el más vendido».

¿Y si el kiosco agrega un sexto producto? Si los nombres y los precios están en arreglos, alcanza con agrandarlos. Si están repartidos en decisiones, hay que tocar el programa en muchos lugares.

## Lo que aprendiste {#aprendiste}

::: resumen
- Un problema grande se resuelve combinando decisiones, bucles, arreglos y esquemas que ya conoces.
- La ficha y el plan, hechos antes de escribir, ordenan el trabajo y dicen qué probar.
:::

## Practica {#practica}

::: practica
- imperativo.proyecto.caja-ficha
- imperativo.proyecto.caja-plan
- imperativo.proyecto.caja
:::

::: docentes
- **Abrir el editor antes de planear.** Pide la ficha y el plan en papel; el editor se abre después.
- **No probar el día sin ventas.** Es el caso que más programas rompe: el más vendido no existe.
- **El desempate.** Cuando el más vendido se reemplaza también con unidades iguales, gana el de mayor código.
:::

::: siguiente
El programa de la caja ya es largo y difícil de leer de un tirón. ¿Cómo se parte un programa grande en piezas con nombre?
:::

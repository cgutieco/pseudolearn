---
id: procedimental.proyecto
numero: "P·II"
tipo: proyecto
titulo: "Proyecto: el kiosco en partes"
duracion: 60
problema_breve: La caja con stock
necesita: [procedimental.modulos]
introduce: []
usa: [descomposicion, arbol-de-descomposicion, funcion-pura, registro, vector, resultado-con-error, validar, ficha-del-problema]
---

::: frase
Un programa partido en piezas con nombre se puede leer, probar y cambiar de a una pieza por vez.
:::

## El problema {#problema}

::: problema
La caja del kiosco ahora también lleva el **stock**. Cada producto empieza con un stock conocido: jugo **10**, sándwich **5**, alfajor **8**, agua **12** y fruta **6**. Los precios y el descuento son los de siempre.

Una venta que pide más de lo que queda se **rechaza con su motivo**, igual que un código que no existe o una cantidad menor que 1. Al cerrar, con el código 0, se muestran el total, el total con descuento y el **stock que queda** de cada producto.

**¿Cómo es la caja nueva?**
:::

## Inténtalo {#intentalo}

::: intento
Resuelve a mano un recreo con estas ventas: 3 jugos, 6 sándwiches, 5 sándwiches y una venta con el código 9.
:::

::: respuesta
Los 3 jugos se aceptan: quedan 7. Los 6 sándwiches se rechazan, porque solo hay 5. Los 5 sándwiches se aceptan: quedan 0. El código 9 no existe. El total es 9 + 25 = **34**; con el descuento, **31**.
:::

## Entender {#entender fase=1}

Llena la ficha del problema: es el primer ejercicio del proyecto. El formato del ticket tiene que ser exacto. Para el ejemplo de la consigna:

- `Jugo x 3 = 9`
- `Sándwich x 6 rechazado: quedan 5`
- `Sándwich x 5 = 25`
- `Código 9 no existe`
- `Total: 34`
- `Con descuento: 31`
- `Stock final:` y una línea por producto, como `Jugo 7`

Una cantidad menor que 1 se rechaza con la línea «Cantidad 0 no válida» (con la cantidad que llegó).

## Planear {#planear fase=2}

El segundo ejercicio te pide repartir las tareas en un árbol de descomposición, y el tercero, ordenar los pasos del plan. Piensa qué piezas pueden ser funciones puras y qué datos conviene juntar en un registro.

::: recuerda termino=arbol-de-descomposicion
:::

## Escribir {#escribir fase=3}

El cuarto ejercicio es el programa completo. Escríbelo pieza por pieza: primero las funciones puras, que se prueban solas; después el registro de los productos; al final el algoritmo principal que lee, valida y muestra.

## Probar {#probar fase=4}

| Caso | Por qué |
|---|---|
| El ejemplo de la consigna | el caso normal, con los dos tipos de rechazo |
| Una venta que deja el stock justo en 0 | el borde del stock |
| Una venta de 0 unidades | la cantidad inválida |
| Todo rechazado | el total queda en 0 y el stock sin tocar |
| Un 0 directo | el día sin ventas |

## Mejorar {#mejorar fase=5}

En una frase: «La caja valida cada venta, la registra si hay stock y cierra con el total, el descuento y lo que queda».

Compárala con la caja de [la Parte I](ruta:imperativo.proyecto): si cambia el descuento, se toca una función; si cambia el formato del ticket, se tocan las líneas que escriben; si se agrega un producto, una línea del catálogo.

## Lo que aprendiste {#aprendiste}

::: resumen
- Un problema grande se parte en piezas: funciones puras para calcular, registros para los datos que van juntos y un principal que lee y muestra.
- Los errores esperables, como una venta sin stock, se responden con su motivo y el programa sigue.
:::

## Practica {#practica}

::: practica
- procedimental.proyecto.kiosco-ficha
- procedimental.proyecto.kiosco-arbol
- procedimental.proyecto.kiosco-plan
- procedimental.proyecto.kiosco-partes
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Escribir todo en el principal.** Funciona, pero se pierde lo aprendido en la parte. Nombra las piezas antes de escribir.
- **Descontar el stock antes de validar.** Una venta rechazada no debe tocar el stock: el caso «todo rechazado» lo descubre.
- **Olvidar el registro de vuelta.** Una ficha copiada del vector se modifica sola; hay que guardarla otra vez en el vector.
:::

::: siguiente
Una cuenta del kiosco tiene saldo, y a veces alguien deja el saldo negativo por un error. ¿Cómo se juntan los datos con las acciones que los cuidan?
:::

---
id: procedimental.puras
numero: "2.3"
tipo: leccion
titulo: Funciones que no tocan nada
duracion: 30
problema_breve: Un precio que no se puede sumar
necesita: [procedimental.ambito]
introduce: [efecto, funcion-pura]
usa: [subprograma, parametro, valor-de-retorno, paso-por-referencia, caso-de-prueba, diagnostico]
---

::: frase
Una función pura solo recibe datos y devuelve un resultado: no pregunta, no muestra y no cambia nada de afuera.
:::

## El problema {#problema}

::: problema
El kiosco tiene una pieza de programa, `PrecioFinal`, que **pregunta** el descuento, lo aplica y **muestra** el precio. Ahora hay que sumar el precio final de **tres productos**. Cada llamada vuelve a preguntar el descuento, la pantalla se llena de mensajes y el resultado no se puede sumar.

**¿Cómo se escribe para poder usarlo en cualquier cálculo y probarlo con una tabla?**
:::

## Inténtalo {#intentalo}

::: intento
En este subprograma, marca qué líneas preguntan, cuáles muestran y cuáles calculan.

```programa id=precio-final-mezclado titulo="Un subprograma que hace de todo"
SubProceso PrecioFinal(precio Como Entero)
  Definir porcentaje Como Entero;
  Escribir "¿Qué descuento?";
  Leer porcentaje;
  Escribir precio * (100 - porcentaje) div 100;
FinSubProceso
```
:::

::: respuesta
Pregunta en las líneas del `Escribir` del mensaje y del `Leer`. Muestra en el último `Escribir`. Calcula solo dentro de ese último `Escribir`: el cálculo está mezclado con lo que muestra. Para sumar tres precios, el cálculo tendría que devolver un número en lugar de mostrarlo.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran el precio y el porcentaje de descuento; sale el precio con descuento.
- **¿A qué se parece?** A `Promedio` en el boletín de [la lección 2.1](ruta:procedimental.dividir): recibe datos y retorna un número.
- **¿En qué partes se divide?** Una pieza que solo calcula, y otra, el algoritmo principal, que pregunta y muestra.

## La herramienta nueva {#herramienta}

Un [[def:efecto|efecto]] es algo que un subprograma hace además de devolver un resultado: leer, mostrar o cambiar algo de afuera, como una caja prestada. Una [[def:funcion-pura|función pura]] no tiene efectos: con los mismos datos devuelve siempre lo mismo.

```figura id=ruta-maquina-pura
pie: La máquina pura tiene una sola entrada y una sola salida. La otra tiene puertas laterales por donde entra y sale lo que no se ve en la llamada.
```

En PseudoLearn, una `Funcion` tiene que ser pura, y el motor lo comprueba. Se escribe con el nombre de la caja del resultado antes del nombre de la función, y devuelve lo que esa caja tenga al terminar:

```programa id=cuadrado titulo="El cuadrado" ejecutar
Funcion r <- Cuadrado(x Como Entero)
  Definir r Como Entero;
  r <- x * x;
FinFuncion

Algoritmo Principal
  Escribir Cuadrado(3) + Cuadrado(4);
FinAlgoritmo
```

```salida
25
```

Si una `Funcion` intenta mostrar algo, el programa ni siquiera empieza:

```programa id=funcion-que-muestra titulo="Una función que muestra" ejecutar
Funcion r <- Cuadrado(x Como Entero)
  Definir r Como Entero;
  Escribir "calculando";
  r <- x * x;
FinFuncion

Algoritmo Principal
  Escribir Cuadrado(3);
FinAlgoritmo
```

```diagnosticos
pureFunctionSideEffect
```

```figura-especificacion seccion=subprogramas.pureza figura=pureza-grafo
```

::: especificacion
- subprogramas.pureza
:::

## Escribir {#escribir fase=3}

```programa id=precio-final-puro titulo="El precio con descuento, puro" ejecutar
Funcion precioFinal <- ConDescuento(precio Como Entero, porcentaje Como Entero)
  Definir precioFinal Como Entero;
  precioFinal <- precio * (100 - porcentaje) div 100;
FinFuncion

Algoritmo Kiosco
  Definir porcentaje, precio Como Entero;
  Definir total Como Entero <- 0;
  Escribir "¿Qué descuento?";
  Leer porcentaje;
  Para i <- 1 Hasta 3 Hacer
    Leer precio;
    total <- total + ConDescuento(precio, porcentaje);
  FinPara
  Escribir "Total: ", total;
FinAlgoritmo
```

```entrada
10
30
50
20
```

```salida
¿Qué descuento?
Total: 90
```

El descuento se pregunta una sola vez, en el algoritmo principal. `ConDescuento` solo calcula, así que su resultado se puede sumar.

## Probar {#probar fase=4}

Una función pura se prueba sin preparar nada: alcanza con llamarla con datos y comparar.

```programa id=probar-descuento titulo="Una tabla de casos" ejecutar
Funcion precioFinal <- ConDescuento(precio Como Entero, porcentaje Como Entero)
  Definir precioFinal Como Entero;
  precioFinal <- precio * (100 - porcentaje) div 100;
FinFuncion

Algoritmo Pruebas
  Escribir ConDescuento(100, 10);
  Escribir ConDescuento(100, 0);
  Escribir ConDescuento(100, 100);
  Escribir ConDescuento(15, 10);
FinAlgoritmo
```

```salida
90
100
0
13
```

| Precio | Descuento | Esperado | Por qué |
|---|---|---|---|
| 100 | 10 | 90 | caso normal |
| 100 | 0 | 100 | borde: sin descuento |
| 100 | 100 | 0 | borde: todo gratis |
| 15 | 10 | 13 | el resultado se redondea hacia abajo |

## Mejorar {#mejorar fase=5}

En una frase: «`ConDescuento` calcula el precio con descuento sin preguntar ni mostrar nada».

El mismo cálculo sirve ahora para el ticket y para el resumen del día sin cambios: quien llama decide de dónde vienen los datos y qué hace con el resultado.

## Lo que aprendiste {#aprendiste}

::: resumen
- {efecto} Un efecto es leer, mostrar o cambiar algo fuera del subprograma.
- {funcion-pura} Una función pura no tiene efectos: con los mismos datos devuelve siempre lo mismo, y el motor lo comprueba.
:::

## Practica {#practica}

::: practica
- procedimental.puras.puro-o-no
- procedimental.puras.suma-cuadrados
- procedimental.puras.funcion-que-escribe
- procedimental.puras.separar
- procedimental.puras.es-bisiesto
- procedimental.puras.por-que-pura
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«Pura significa sin variables».** `ConDescuento` declara una caja y es pura: lo que importa es que no tenga efectos.
- **Mostrar algo adentro «para ver qué pasa».** El motor lo rechaza. Para mirar un valor, se muestra desde quien llama.
- **Confundir pura con corta.** Una función larga puede ser pura, y una de una línea puede tener un efecto.
:::

::: siguiente
Para mover una torre de discos de un poste a otro hay que mover primero una torre más chica. ¿Puede un subprograma usarse a sí mismo?
:::

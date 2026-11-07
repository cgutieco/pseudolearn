---
id: funcional.orden-superior
numero: "4.2"
tipo: leccion
titulo: Functions that receive functions
duracion: 40
problema_breve: Three loops that change in one line
necesita: [funcional.sin-cambiar]
introduce: [funcion-como-valor, orden-superior, mapear, filtrar, reducir]
usa: [funcion-pura, vector, esquema, acumulador, nucleo-puro, parametro]
---

::: frase
If the only thing that changes between two loops is an operation, the operation can be a value.
:::

## The problem {#problema}

::: problema
The kiosk keeps its prices in a list: **3, 5, 2, 1 and 2**. There are three programs: one **adds 1 peso** to each price, another **doubles** them and another **takes 1 off**. All three have the same walk and change in a single line.

**How is the walk written only once?**
:::

## Try it {#intentalo}

::: intento
Imagine the three programs side by side. Which line is different in each?
:::

::: respuesta
Only the one that computes the new price: `precio + 1`, `precio * 2` or `precio - 1`. Everything else, creating the new vector, walking and adding, is identical. If that line were a value, the walk would be written once.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The prices and the operation go in; a new vector with the changed prices comes out.
- **What does it look like?** The patterns of [lesson 1.6](ruta:imperativo.esquemas): walking, filtering and gathering, always with the same shape.
- **Which part is calculation and which part touches the world?** Everything is calculation: only showing the result touches the world.

```figura id=ruta-cinta
pie: Three machines for collections: one changes each box, another lets some through and another gathers them all into a value.
paso: Each price goes through a machine that changes it: a conveyor of the same length comes out.
paso: A gate lets through only the prices that meet a condition.
paso: A funnel gathers all the prices into a single value.
```

## The new tool {#herramienta}

In PseudoLearn, a function is one more value: it can be kept and passed to another function, by its name. That is treating a [[def:funcion-como-valor|function as a value]]. A function that receives or gives back functions is [[def:orden-superior|higher-order]]. The type of a parameter that is a function says what it receives and what it gives back: `Function(Integer) As Integer`.

```programa id=aplicar-dos-veces titulo="Applying twice" ejecutar
```

```salida
7
```

With functions as parameters, three patterns are written only once. To [[def:mapear|map]] applies a function to each element and gives another vector of the same length. To [[def:filtrar|filter]] keeps the elements that meet a condition. To [[def:reducir|reduce]] combines all the elements into a single value, starting from an initial value.

::: especificacion
- tipos.funciones
- tipos.vectores
- subprogramas.pureza
:::

## Write {#escribir fase=3}

```programa id=mapear-filtrar-reducir titulo="Map, filter and reduce" ejecutar
```

```salida
[4, 6, 3, 2, 3]
[2, 1, 2]
13
```

`Mapear` does not know what `MasUno` does: it only knows that it receives a number and gives back another. The same goes for `Filtrar` with `EsBarato` and `Reducir` with `Sumar`.

## Test {#probar fase=4}

With an empty vector, `Mapear` and `Filtrar` give an empty vector, and `Reducir` gives the initial value: it is the edge case of all three.

| Call | With the prices | With an empty vector |
|---|---|---|
| `Mapear(v, MasUno)` | [4, 6, 3, 2, 3] | [] |
| `Filtrar(v, EsBarato)` | [2, 1, 2] | [] |
| `Reducir(v, Sumar, 0)` | 13 | 0 |

## Improve {#mejorar fase=5}

In one sentence: «The walk is written once, and the operation that changes is given to it as a value».

The three programs of the problem become three calls to `Mapear`, with `MasUno`, `Doble` and `MenosUno`. And they can be composed: the total of the cheap prices with the rise is `Reducir(Mapear(Filtrar(precios, EsBarato), MasUno), Sumar, 0)`.

## What you learned {#aprendiste}

::: resumen
- {funcion-como-valor,orden-superior} A function can be passed as a value; a function that receives or gives back functions is higher-order.
- {mapear,filtrar,reducir} Mapping applies a function to each element; filtering keeps the ones that meet a condition; reducing combines them all into a single value.
:::

## Practise {#practica}

::: practica
- funcional.orden-superior.mapear-predecir
- funcional.orden-superior.cual-de-las-tres
- funcional.orden-superior.pares
- funcional.orden-superior.maximo-reducir
- funcional.orden-superior.tres-en-uno
- funcional.orden-superior.por-que-pasar
:::

::: docentes
- **Calling the function instead of passing it.** `Mapear(v, MasUno(1))` passes a number, not the function. The engine rejects it by type.
- **Reducing with the wrong initial value.** With the greatest, starting at 0 fails with negative numbers.
- **Wanting to map when filtering is needed.** Ask: does the result have the same length or can it be shorter?
:::

::: siguiente
Each week there is a campaign with a different discount percentage, read at the start. Can a function be made from a value?
:::

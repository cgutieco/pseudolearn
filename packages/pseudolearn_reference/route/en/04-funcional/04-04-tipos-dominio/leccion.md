---
id: funcional.tipos-dominio
numero: "4.4"
tipo: leccion
titulo: Data that cannot be wrong
duracion: 40
problema_breve: The order delivered with no time
necesita: [funcional.clausuras]
introduce: [variante, coincidencia-de-patrones, generico, estado-imposible]
usa: [registro, campo, enumerado, resultado-con-error, seleccion-multiple, funcion-pura, inmutabilidad]
---

::: frase
The best error is the one that cannot be written.
:::

## The problem {#problema}

::: problema
The kiosk started making deliveries. An order is kept with four values: `estado` (a text), `repartidor`, `hora` and `motivo`. Orders appeared that were «delivered» **with no time**, «cancelled» **with a courier** and one with the state «delivred».

**How is an order represented so that those errors are impossible?**
:::

## Try it {#intentalo}

::: intento
Write the possible states of an order and which data each one needs.
:::

::: respuesta
Pending: none. On its way: who carries it. Delivered: who carried it and at what time. Cancelled: why. Each state needs different data, and none needs all four.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** An order goes in; its description comes out, or the next order.
- **What does it look like?** The `Result` of [lesson 2.6](ruta:procedimental.fallos): a `Success` carries a value and a `Failure` carries a reason.
- **Which part is calculation and which part touches the world?** Describing and moving an order forward is pure calculation.

```figura id=ruta-estados-pedido
pie: Each state carries only its data. The arrows are the possible changes; no arrow leaves delivered or cancelled.
```

## The new tool {#herramienta}

A [[def:variante|variant]] is a type with several shapes, and each shape carries only the data that belongs to it. With it, an order delivered with no time cannot be written: the shape `Entregado` requires the time.

```figura-especificacion seccion=tipos.variantes figura=variante-formas
```

To use a value of a variant you choose what to do according to its shape and read its data with a `Switch`: that is [[def:coincidencia-de-patrones|pattern matching]].

```programa id=describir titulo="Describing an order" ejecutar
```

```salida
En camino con Sol
```

`Result` and `Optional`, which you already know, are also types of this style, and they are also [[def:generico|generic]]: they work with any type of data inside. `Result<Pedido, String>` is an order or a reason.

A good model makes [[def:estado-imposible|impossible states]] impossible to write: there is no need to check what cannot exist.

::: especificacion
- tipos.variantes
- control.segun
- tipos.genericos
- tipos.inmutable
:::

## Write {#escribir fase=3}

```programa id=pedidos-variante titulo="Moving an order forward" ejecutar
```

```salida
Pendiente
En camino con Sol
Entregado por Sol a las 14
No se puede: ya lo entregó Sol a las 14
```

`Avanzar` does not change the order it receives: it gives back a new one, or a reason. The main algorithm decides what to do with each answer.

## Test {#probar fase=4}

| Order | Moving forward gives | Why |
|---|---|---|
| Pending | On its way | valid change |
| On its way with Sol | Delivered by Sol | valid change |
| Delivered | an error with a reason | it can no longer move forward |
| Cancelled | an error with a reason | it can no longer move forward |

## Improve {#mejorar fase=5}

In one sentence: «Each state of the order carries only its data, and moving forward gives back the next order or the reason why it cannot».

If the state `Devuelto(motivo)` (returned) is added, the engine marks every `Switch` that does not cover it and the program does not run until they are completed. That way, a new shape cannot be forgotten anywhere.

## What you learned {#aprendiste}

::: resumen
- {variante} A variant is a type with several shapes, and each shape carries only the data that belongs to it.
- {coincidencia-de-patrones} Pattern matching chooses what to do according to the shape of a value and reads its data.
- {generico} A generic type works with any type of data, like `Result`.
- {estado-imposible} A good model makes impossible states impossible to write.
:::

## Practise {#practica}

::: practica
- funcional.tipos-dominio.posible-o-no
- funcional.tipos-dominio.segun-pedido
- funcional.tipos-dominio.describir-resolver
- funcional.tipos-dominio.avanzar
- funcional.tipos-dominio.registro-a-variante
- funcional.tipos-dominio.por-que-variante
:::

::: docentes
- **A variant with a «type» field inside.** It is going back to the record: the shape already says the type.
- **A «default» branch that hides new shapes.** When the `Switch` has a case for everything else, the engine cannot warn when a new shape appears.
- **Confusing variant with enumeration.** The enumeration carries no data; the variant does.
:::

::: siguiente
You now know three ways of thinking about a program. Which one suits each problem?
:::

---
id: funcional.tipos-dominio
numero: "4.4"
tipo: leccion
titulo: Datos que no pueden estar mal
duracion: 40
problema_breve: El pedido entregado sin hora
necesita: [funcional.clausuras]
introduce: [variante, coincidencia-de-patrones, generico, estado-imposible]
usa: [registro, campo, enumerado, resultado-con-error, seleccion-multiple, funcion-pura, inmutabilidad]
---

::: frase
El mejor error es el que no se puede escribir.
:::

## El problema {#problema}

::: problema
El kiosco empezó a hacer envíos. Un pedido se guarda con cuatro datos: `estado` (un texto), `repartidor`, `hora` y `motivo`. Aparecieron pedidos «entregados» **sin hora**, «cancelados» **con repartidor** y uno con estado «entrgado».

**¿Cómo se representa un pedido para que esos errores sean imposibles?**
:::

## Inténtalo {#intentalo}

::: intento
Escribe los estados posibles de un pedido y qué dato necesita cada uno.
:::

::: respuesta
Pendiente: ninguno. En camino: quién lo lleva. Entregado: quién lo llevó y a qué hora. Cancelado: por qué. Cada estado necesita datos distintos, y ninguno necesita los cuatro.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra un pedido; sale su descripción, o el pedido siguiente.
- **¿A qué se parece?** Al `Resultado` de [la lección 2.6](ruta:procedimental.fallos): un `Exito` lleva un valor y un `Error` lleva un motivo.
- **¿Qué parte es cálculo y qué parte toca el mundo?** Describir y avanzar un pedido es cálculo puro.

```figura id=ruta-estados-pedido
pie: Cada estado lleva solo sus datos. Las flechas son los cambios posibles; no hay flecha que salga de entregado ni de cancelado.
```

## La herramienta nueva {#herramienta}

Una [[def:variante|variante]] es un tipo con varias formas, y cada forma lleva solo los datos que le corresponden. Con ella, un pedido entregado sin hora no se puede escribir: la forma `Entregado` exige la hora.

```figura-especificacion seccion=tipos.variantes figura=variante-formas
```

Para usar un valor de una variante se elige qué hacer según su forma y se leen sus datos con un `Segun`: es la [[def:coincidencia-de-patrones|coincidencia de patrones]].

```programa id=describir titulo="Describir un pedido" ejecutar
Variante Pedido
  Alternativa Pendiente
  Alternativa EnCamino(repartidor Como Cadena)
  Alternativa Entregado(repartidor Como Cadena, hora Como Entero)
  Alternativa Cancelado(motivo Como Cadena)
FinVariante

Funcion texto <- Describir(pedido Como Pedido)
  Definir texto Como Cadena <- "";
  Segun pedido Hacer
    Pedido.Pendiente: texto <- "Pendiente";
    Pedido.EnCamino(quien): texto <- "En camino con " + quien;
    Pedido.Entregado(quien, hora): texto <- "Entregado por " + quien + " a las " + ConvertirATexto(hora);
    Pedido.Cancelado(motivo): texto <- "Cancelado: " + motivo;
  FinSegun
FinFuncion

Algoritmo Envios
  Escribir Describir(Pedido.EnCamino("Sol"));
FinAlgoritmo
```

```salida
En camino con Sol
```

`Resultado` y `Opcional`, que ya conoces, también son tipos de este estilo, y además son [[def:generico|genéricos]]: funcionan con cualquier tipo de dato adentro. `Resultado<Pedido, Cadena>` es un pedido o un motivo.

Un buen modelo hace que los [[def:estado-imposible|estados imposibles]] no se puedan escribir: no hace falta comprobar lo que no puede existir.

::: especificacion
- tipos.variantes
- control.segun
- tipos.genericos
- tipos.inmutable
:::

## Escribir {#escribir fase=3}

```programa id=pedidos-variante titulo="Avanzar un pedido" ejecutar
Variante Pedido
  Alternativa Pendiente
  Alternativa EnCamino(repartidor Como Cadena)
  Alternativa Entregado(repartidor Como Cadena, hora Como Entero)
  Alternativa Cancelado(motivo Como Cadena)
FinVariante

Funcion texto <- Describir(pedido Como Pedido)
  Definir texto Como Cadena <- "";
  Segun pedido Hacer
    Pedido.Pendiente: texto <- "Pendiente";
    Pedido.EnCamino(quien): texto <- "En camino con " + quien;
    Pedido.Entregado(quien, hora): texto <- "Entregado por " + quien + " a las " + ConvertirATexto(hora);
    Pedido.Cancelado(motivo): texto <- "Cancelado: " + motivo;
  FinSegun
FinFuncion

SubProceso Avanzar(pedido Como Pedido, repartidor Como Cadena, hora Como Entero) Como Resultado<Pedido, Cadena>
  Segun pedido Hacer
    Pedido.Pendiente: Retornar Exito(Pedido.EnCamino(repartidor));
    Pedido.EnCamino(quien): Retornar Exito(Pedido.Entregado(quien, hora));
    Pedido.Entregado(quien, cuando): Retornar Error("ya lo entregó " + quien + " a las " + ConvertirATexto(cuando));
    Pedido.Cancelado(motivo): Retornar Error("está cancelado: " + motivo);
  FinSegun
FinSubProceso

Algoritmo Envios
  Definir pedido Como Pedido <- Pedido.Pendiente;
  Para paso <- 1 Hasta 3 Hacer
    Escribir Describir(pedido);
    Segun Avanzar(pedido, "Sol", 14) Hacer
      Exito(siguiente): pedido <- siguiente;
      Error(motivo): Escribir "No se puede: ", motivo;
    FinSegun
  FinPara
FinAlgoritmo
```

```salida
Pendiente
En camino con Sol
Entregado por Sol a las 14
No se puede: ya lo entregó Sol a las 14
```

`Avanzar` no cambia el pedido que recibe: devuelve uno nuevo, o un motivo. El principal decide qué hacer con cada respuesta.

## Probar {#probar fase=4}

| Pedido | Avanzar da | Por qué |
|---|---|---|
| Pendiente | En camino | transición válida |
| En camino con Sol | Entregado por Sol | transición válida |
| Entregado | un error con motivo | ya no puede avanzar |
| Cancelado | un error con motivo | ya no puede avanzar |

## Mejorar {#mejorar fase=5}

En una frase: «Cada estado del pedido lleva solo sus datos, y avanzar devuelve el pedido siguiente o el motivo por el que no se puede».

Si se agrega el estado `Devuelto(motivo)`, el motor marca cada `Segun` que no lo contempla y el programa no se ejecuta hasta completarlos. Así, una forma nueva no se puede olvidar en ningún lugar.

## Lo que aprendiste {#aprendiste}

::: resumen
- {variante} Una variante es un tipo con varias formas, y cada forma lleva solo los datos que le corresponden.
- {coincidencia-de-patrones} La coincidencia de patrones elige qué hacer según la forma de un valor y lee sus datos.
- {generico} Un tipo genérico funciona con cualquier tipo de dato, como `Resultado`.
- {estado-imposible} Un buen modelo hace que los estados imposibles no se puedan escribir.
:::

## Practica {#practica}

::: practica
- funcional.tipos-dominio.posible-o-no
- funcional.tipos-dominio.segun-pedido
- funcional.tipos-dominio.describir-resolver
- funcional.tipos-dominio.avanzar
- funcional.tipos-dominio.registro-a-variante
- funcional.tipos-dominio.por-que-variante
:::

::: docentes
- **Una variante con un campo «tipo» adentro.** Es volver al registro: la forma ya dice el tipo.
- **Una rama «otro» que esconde formas nuevas.** Cuando el `Segun` tiene un caso para todo lo demás, el motor no puede avisar cuando aparece una forma nueva.
- **Confundir variante con enumerado.** El enumerado no lleva datos; la variante sí.
:::

::: siguiente
Ya conoces tres formas de pensar un programa. ¿Cuál conviene para cada problema?
:::

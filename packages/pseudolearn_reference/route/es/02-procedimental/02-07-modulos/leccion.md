---
id: procedimental.modulos
numero: "2.7"
tipo: leccion
titulo: Programas grandes
duracion: 25
problema_breve: El kiosco repartido en archivos
necesita: [procedimental.fallos]
introduce: [modulo, importar, visibilidad]
usa: [subprograma, descomposicion, arbol-de-descomposicion, funcion-pura]
---

::: frase
Un módulo junta lo que cambia por el mismo motivo y muestra hacia afuera solo lo necesario.
:::

## El problema {#problema}

::: problema
El programa del kiosco tiene el inventario, las ventas y los tickets mezclados en un solo archivo de **400 líneas**. Dos compañeros quieren trabajar a la vez, y una pieza `Total` del ticket choca con otra `Total` de las ventas.

**¿Cómo se reparte en partes que no se pisen?**
:::

## Inténtalo {#intentalo}

::: intento
Agrupa estos nombres en tres montones: `AgregarStock`, `QuitarStock`, `HayStock`, `Importe`, `ConDescuento`, `Vender`, `LineaDeTicket`, `CerrarTicket`, `TotalDelTicket` y `TotalDelDia`.
:::

::: respuesta
Un montón para el inventario (`AgregarStock`, `QuitarStock`, `HayStock`), otro para las ventas (`Importe`, `ConDescuento`, `Vender`, `TotalDelDia`) y otro para los tickets (`LineaDeTicket`, `CerrarTicket`, `TotalDelTicket`). Cada montón cambia por un motivo distinto: el stock, los precios o el formato del papel.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Lo mismo que antes: lo que cambia es cómo está repartido el programa.
- **¿A qué se parece?** Al árbol de descomposición del boletín, en [la lección 2.1](ruta:procedimental.dividir): cada rama grande puede ser un archivo.
- **¿En qué partes se divide?** Se divide en tres archivos, uno por montón, y un cuarto con el algoritmo principal.

```figura id=ruta-kiosco-modulos
pie: Las flechas van de quien usa a quien es usado, y nunca forman un ciclo.
```

## La herramienta nueva {#herramienta}

Un [[def:modulo|módulo]] es un archivo con una responsabilidad. Para usar desde un módulo lo que otro ofrece hay que [[def:importar|importarlo]] con `Importar`. La [[def:visibilidad|visibilidad]] decide qué se puede usar desde afuera: solo lo marcado `Publico` se puede importar; lo demás es privado del módulo.

```figura-especificacion seccion=programas.modulos figura=paquete-modulos
```

```programa id=modulo-ventas titulo="tienda/ventas.psl"
Publico SubProceso Importe(precio Como Entero, cantidad Como Entero) Como Entero
  Retornar precio * cantidad;
FinSubProceso

Publico SubProceso ConDescuento(monto Como Entero) Como Entero
  Retornar monto - monto div 10;
FinSubProceso

SubProceso RedondearCentavos(monto Como Entero) Como Entero
  Retornar monto;
FinSubProceso
```

```programa id=modulo-principal titulo="tienda/principal.psl"
Importar tienda.ventas;

Algoritmo Principal
  Escribir ventas.ConDescuento(ventas.Importe(3, 7));
FinAlgoritmo
```

Un proyecto de varios módulos necesita un archivo que lo describa y se ejecuta entero, por eso estos bloques no tienen botón para ejecutarlos aquí. Cómo se arma un proyecto está en [la Especificación](especificacion:programas.modulos).

::: especificacion
- programas.modulos
- programas.estructura
:::

## Escribir {#escribir fase=3}

El kiosco queda en cuatro módulos:

| Módulo | Responsabilidad | Usa a |
|---|---|---|
| `inventario` | cuánto stock hay de cada producto | — |
| `ventas` | importes, descuentos y el total del día | `inventario` |
| `tickets` | el formato de cada línea y del cierre | `ventas` |
| `principal` | leer las ventas y llamar a los demás | `inventario`, `ventas`, `tickets` |

Ahora `ventas.TotalDelDia` y `tickets.TotalDelTicket` ya no chocan: cada nombre vive en su módulo, y quien los usa los llama con el nombre del módulo adelante.

## Probar {#probar fase=4}

Cada módulo se prueba solo, a través de lo que hace público. `ventas` se prueba llamando a `Importe` y a `ConDescuento` con una tabla de casos, como las funciones puras de [la lección 2.3](ruta:procedimental.puras), sin leer nada ni mirar tickets.

## Mejorar {#mejorar fase=5}

En una frase: «El kiosco se reparte en módulos por responsabilidad, y cada uno muestra solo lo que los demás necesitan».

Volver privado un subprograma auxiliar, como `RedondearCentavos`, no rompe a nadie: nadie más podía usarlo. Volverlo público lo convierte en un compromiso: desde ese momento, otros pueden depender de él.

## Lo que aprendiste {#aprendiste}

::: resumen
- {modulo,importar} Un módulo es un archivo con una responsabilidad; importar es usar lo que otro módulo ofrece.
- {visibilidad} La visibilidad decide qué se puede usar desde afuera: lo público es un compromiso, lo privado se puede cambiar.
:::

## Practica {#practica}

::: practica
- procedimental.modulos.a-que-modulo
- procedimental.modulos.publico-privado
- procedimental.modulos.orden-dependencias
- procedimental.modulos.un-archivo
- procedimental.modulos.ciclo
:::

::: docentes
- **Módulos por tipo de construcción.** Un módulo de «todas las funciones» y otro de «todos los registros» cambian por mil motivos. Pide agrupar por lo que cambia junto.
- **Todo público.** Todo nombre público es una promesa. Pide justificar cada `Publico`.
:::

::: siguiente
Hora de rehacer el kiosco con todo esto.
:::

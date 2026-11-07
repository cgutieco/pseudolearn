---
id: objetos.identidad
numero: "3.3"
tipo: leccion
titulo: Dos nombres, un objeto
duracion: 30
problema_breve: El pedido que se copió mal
necesita: [objetos.invariantes]
introduce: [identidad, alias, referencia-a-objeto]
usa: [objeto, clase, metodo, registro, asignar, vector, encapsulamiento]
pieza: 6
---

::: frase
Asignar un objeto a otra variable no lo copia: le da otro nombre al mismo objeto.
:::

## El problema {#problema}

::: problema
En el kiosco, un pedido guarda su lista de productos y sabe agregarle más. Para armar un pedido parecido, alguien escribió `copia <- pedido` y le agregó un alfajor a `copia`. El ticket del pedido original **también** muestra el alfajor.

**¿Por qué pasó, y cómo se hace una copia de verdad?**
:::

## Inténtalo {#intentalo}

::: intento
Predice qué muestran los dos tickets de este programa.

```programa id=pedido-alias titulo="Un pedido y su «copia»"
Clase Pedido
  Privado Definir productos Como Vector<Cadena>;

  Metodo Constructor()
    Este.productos <- Vector();
  FinMetodo

  Metodo Agregar(producto Como Cadena)
    Este.productos.Agregar(producto);
  FinMetodo

  Metodo Ticket() Como Cadena
    Retornar Unir(Este.productos, ", ");
  FinMetodo

  Metodo Duplicar() Como Pedido
    Definir duplicado Como Pedido <- Nuevo Pedido();
    Para Cada producto En Este.productos Hacer
      duplicado.Agregar(producto);
    FinPara
    Retornar duplicado;
  FinMetodo
FinClase

Algoritmo Pedidos
  Definir pedido Como Pedido <- Nuevo Pedido();
  pedido.Agregar("Jugo");
  pedido.Agregar("Sándwich");
  Definir copia Como Pedido <- pedido;
  copia.Agregar("Alfajor");
  Escribir "Original: ", pedido.Ticket();
  Escribir "Copia: ", copia.Ticket();
FinAlgoritmo
```
:::

::: respuesta
Los dos tickets dicen «Jugo, Sándwich, Alfajor». `copia` y `pedido` son dos nombres para el mismo pedido: lo que se agrega por un nombre se ve por el otro.
:::

## Entender y planear {#entender-planear fase=1-2}

::: recuerda termino=registro
:::

- **¿Qué entra y qué sale?** Entran los productos de cada pedido; salen sus dos tickets, cada uno con lo suyo.
- **¿A qué se parece?** Al registro de [la lección 2.5](ruta:procedimental.datos), pero al revés: un registro sí se copia al asignarlo; un objeto, no.
- **¿Quién tiene la información para hacer esto?** El pedido: sabe qué productos tiene, así que puede armar un pedido nuevo con los mismos.

## La herramienta nueva {#herramienta}

Cada objeto tiene una [[def:identidad|identidad]]: es ese objeto y no otro, aunque haya otro con los mismos datos. Una variable de objeto no guarda el objeto: guarda una [[def:referencia-a-objeto|referencia]], una flecha hacia él. Dos variables con la misma flecha son [[def:alias|alias]] del mismo objeto.

```figura-especificacion seccion=objetos.copia figura=alias-copia
```

```figura id=ruta-flechas-pedido
pie: Asignar copia la flecha, no el pedido. Para tener dos pedidos hay que crear el segundo.
paso: `pedido` y `copia` apuntan al mismo pedido.
paso: Se agrega un alfajor por `copia`: el pedido es uno solo, así que se ve también por `pedido`.
paso: Con una copia real hay dos pedidos, cada uno con su propia lista.
```

`Copiar(objeto)` crea un objeto nuevo, pero copia un solo nivel: si el objeto tiene adentro otro objeto o un vector, la copia lo comparte. Los detalles están en [la Especificación](especificacion:objetos.copia). Por eso, cuando el objeto tiene una lista, conviene que él mismo sepa duplicarse.

::: especificacion
- objetos.copia
:::

## Escribir {#escribir fase=3}

```programa id=pedidos titulo="Un alias, una copia a medias y una copia real" ejecutar
Clase Pedido
  Privado Definir productos Como Vector<Cadena>;

  Metodo Constructor()
    Este.productos <- Vector();
  FinMetodo

  Metodo Agregar(producto Como Cadena)
    Este.productos.Agregar(producto);
  FinMetodo

  Metodo Ticket() Como Cadena
    Retornar Unir(Este.productos, ", ");
  FinMetodo

  Metodo Duplicar() Como Pedido
    Definir duplicado Como Pedido <- Nuevo Pedido();
    Para Cada producto En Este.productos Hacer
      duplicado.Agregar(producto);
    FinPara
    Retornar duplicado;
  FinMetodo
FinClase

Algoritmo Pedidos
  Definir pedido Como Pedido <- Nuevo Pedido();
  pedido.Agregar("Jugo");
  pedido.Agregar("Sándwich");
  Definir copia Como Pedido <- pedido;
  copia.Agregar("Alfajor");
  Escribir "Original: ", pedido.Ticket();
  Definir superficial Como Pedido <- Copiar(pedido);
  superficial.Agregar("Fruta");
  Escribir "Original: ", pedido.Ticket();
  Definir otro Como Pedido <- pedido.Duplicar();
  otro.Agregar("Agua");
  Escribir "Original: ", pedido.Ticket();
  Escribir "Otro: ", otro.Ticket();
FinAlgoritmo
```

```salida
Original: Jugo, Sándwich, Alfajor
Original: Jugo, Sándwich, Alfajor, Fruta
Original: Jugo, Sándwich, Alfajor, Fruta
Otro: Jugo, Sándwich, Alfajor, Fruta, Agua
```

El alias y la copia a medias cambian el original. Solo `Duplicar`, que arma un pedido nuevo con una lista nueva, deja al original tranquilo.

## Probar {#probar fase=4}

| Cómo se armó | ¿Comparte la lista con el original? | Agregar por el nuevo nombre… |
|---|---|---|
| `copia <- pedido` | sí: es el mismo pedido | cambia el original |
| `Copiar(pedido)` | sí: copia un solo nivel | cambia el original |
| `pedido.Duplicar()` | no | no cambia el original |

## Mejorar {#mejorar fase=5}

En una frase: «Asignar un pedido le da otro nombre; para tener otro pedido, hay que pedirle al pedido que se duplique».

Compartir no siempre es un error. Si todas las pantallas del kiosco tienen que ver el mismo inventario actualizado, conviene que lo compartan. Si cada pedido es de un cliente distinto, cada uno necesita el suyo.

## Lo que aprendiste {#aprendiste}

::: resumen
- {identidad} La identidad es lo que hace que un objeto sea ese objeto y no otro igual.
- {alias,referencia-a-objeto} Una variable de objeto guarda una referencia al objeto; dos variables con la misma referencia son alias.
:::

## Practica {#practica}

::: practica
- objetos.identidad.alias-predecir
- objetos.identidad.mismo-o-distinto
- objetos.identidad.pedido-copia
- objetos.identidad.dos-tarjetas
- objetos.identidad.registro-u-objeto
:::

::: docentes
- **«Asignar copia».** Con registros sí; con objetos, no. El programa del inténtalo lo muestra.
- **Comparar objetos con igual esperando comparar el contenido.** Dos pedidos con los mismos productos no son el mismo objeto; los detalles están en [la Especificación](especificacion:objetos.copia).
- **«El alias es siempre un error».** A veces se quiere justamente compartir.
:::

::: siguiente
La caja cobra en efectivo, con tarjeta y con vale, y cada medio nuevo obliga a tocar la caja. ¿Se puede agregar un medio sin tocarla?
:::

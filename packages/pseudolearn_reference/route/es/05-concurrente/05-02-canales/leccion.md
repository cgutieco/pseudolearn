---
id: concurrente.canales
numero: "5.2"
tipo: leccion
titulo: Pasarse mensajes
duracion: 35
problema_breve: El mostrador donde caben 2 platos
necesita: [concurrente.tareas]
introduce: [canal, aislamiento, productor-consumidor]
usa: [tarea, agenda, concurrencia]
---

::: frase
Dos tareas se coordinan mejor pasándose mensajes que compartiendo cajas.
:::

## El problema {#problema}

::: problema
La cocina prepara los pedidos **1, 2 y 3** y los deja en un **mostrador donde caben 2 platos**. El mostrador entrega cada pedido apenas llega y, cuando la cocina cierra, dice cuántos entregó. Si el mostrador está lleno, la cocina espera.

**¿Cómo se comunican la cocina y el mostrador sin pisarse?**
:::

## Inténtalo {#intentalo}

::: intento
¿Cuántos pedidos entrega el mostrador, y en qué orden?
:::

::: respuesta
**3**, en el orden en que la cocina los dejó: 1, 2 y 3.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran los pedidos que prepara la cocina; sale cada entrega y, al final, cuántas hubo.
- **¿A qué se parece?** A la cocina de la lección anterior, pero ahora los platos salen de a uno, sin esperar el final.
- **¿Qué puede pasar a la vez y qué tiene que esperar?** La cocina y el mostrador trabajan a la vez; el mostrador espera cuando no hay platos y la cocina espera cuando no hay lugar.

## La herramienta nueva {#herramienta}

Un [[def:canal|canal]] es una fila de mensajes entre tareas: una tarea envía, otra recibe, y los mensajes salen en el orden en que entraron. `Canal(2)` crea uno donde caben dos mensajes; si está lleno, quien envía espera.

```figura-especificacion seccion=tareas.canales figura=canal-cola
```

```figura id=ruta-mostrador
pie: Los pedidos salen del canal en el orden en que entraron.
paso: La cocina deja el pedido 1.
paso: Deja el 2: el canal está lleno y la cocina espera.
paso: El mostrador recibe el 1 y queda lugar.
paso: La cocina deja el pedido 3.
```

Este reparto tiene nombre: el esquema [[def:productor-consumidor|productor y consumidor]]. Una tarea produce mensajes y otra los consume, y el canal entre las dos hace que cada una espere solo cuando hace falta.

```programa id=tuberia-mini titulo="Una tubería chica" ejecutar
SubProceso Suspendible Producir(fila Como Canal<Entero>)
  Para valor <- 10 Hasta 30 Con Paso 10 Hacer
    Definir aceptado Como Logico <- Aguardar fila.Enviar(valor);
    Si No aceptado Entonces
      Escribir "canal cerrado";
    FinSi
  FinPara
  fila.Cerrar();
FinSubProceso

SubProceso Suspendible Consumir(fila Como Canal<Entero>)
  Repetir
    Segun Aguardar fila.Recibir() Hacer
      Algo(valor): Escribir "recibido ", valor;
      Nada: Salir;
    FinSegun
  Hasta Que Falso
FinSubProceso

Algoritmo TuberiaMini
  Definir fila Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Producir(fila);
    Lanzar Consumir(fila);
  FinTareas
FinAlgoritmo
```

```salida
recibido 10
recibido 20
recibido 30
```

`Enviar` devuelve si el canal aceptó el mensaje: un canal cerrado no acepta nada. `Recibir` devuelve un `Opcional`: `Algo` con el mensaje, o `Nada` cuando el canal se cerró y ya no quedan mensajes. Por eso el consumidor termina con `Salir`.

::: especificacion
- tareas.canales
:::

## Escribir {#escribir fase=3}

```programa id=mostrador titulo="El mostrador del kiosco" ejecutar
SubProceso Suspendible Cocinar(mostrador Como Canal<Entero>)
  Para pedido <- 1 Hasta 3 Hacer
    Definir aceptado Como Logico <- Aguardar mostrador.Enviar(pedido);
    Si No aceptado Entonces
      Escribir "El mostrador cerró";
    FinSi
  FinPara
  mostrador.Cerrar();
FinSubProceso

Algoritmo Kiosco
  Definir mostrador Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Cocinar(mostrador);
    Definir entregados Como Entero <- 0;
    Repetir
      Segun Aguardar mostrador.Recibir() Hacer
        Algo(pedido):
          Escribir "Entrego el pedido ", pedido;
          entregados <- entregados + 1;
        Nada: Salir;
      FinSegun
    Hasta Que Falso
    Escribir "Entregados: ", entregados;
  FinTareas
FinAlgoritmo
```

```salida
Entrego el pedido 1
Entrego el pedido 2
Entrego el pedido 3
Entregados: 3
```

La cocina es una tarea; el mostrador es el propio algoritmo, que recibe hasta que el canal se cierra. La cuenta de entregados se declara y se cambia dentro del ámbito, junto a quien la usa.

## Probar {#probar fase=4}

Garantizado: el orden 1, 2, 3, porque un canal entrega en el orden en que se envía, y `Entregados` al final, porque se escribe después de recibir todo.

Caso borde: la cocina cierra sin enviar nada. El primer `Recibir` da `Nada` y el mostrador muestra `Entregados: 0`.

Caso raro: nadie cierra el canal. El mostrador espera para siempre un pedido que no llega, y el motor lo detecta:

```programa id=bloqueo titulo="Un canal que nadie cierra" ejecutar
SubProceso Suspendible Cocinar(mostrador Como Canal<Entero>)
  Para pedido <- 1 Hasta 3 Hacer
    Definir aceptado Como Logico <- Aguardar mostrador.Enviar(pedido);
    Si No aceptado Entonces
      Escribir "El mostrador cerró";
    FinSi
  FinPara
FinSubProceso

Algoritmo Kiosco
  Definir mostrador Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Cocinar(mostrador);
    Definir entregados Como Entero <- 0;
    Repetir
      Segun Aguardar mostrador.Recibir() Hacer
        Algo(pedido):
          Escribir "Entrego el pedido ", pedido;
          entregados <- entregados + 1;
        Nada: Salir;
      FinSegun
    Hasta Que Falso
    Escribir "Entregados: ", entregados;
  FinTareas
FinAlgoritmo
```

```salida
Entrego el pedido 1
Entrego el pedido 2
Entrego el pedido 3
```

```diagnosticos
taskDeadlock
```

## Mejorar {#mejorar fase=5}

En una frase: «La cocina envía los pedidos por un canal y el mostrador los recibe en orden hasta que el canal se cierra».

¿Y si las dos tareas escribieran en la misma caja, una cuenta compartida? Cada una tendría que adivinar qué hizo la otra entre turno y turno. El lenguaje empuja a otra forma de trabajo, el [[def:aislamiento|aislamiento]]: cada tarea guarda sus propios datos y solo comparte lo que envía por un canal.

Queda un problema abierto: si hay dos proveedores, ¿a cuál se le hace caso?

## Lo que aprendiste {#aprendiste}

::: resumen
- {canal} Un canal es una fila de mensajes entre tareas, con lugar para unos pocos; entrega en el orden en que se envió.
- {productor-consumidor} El esquema productor y consumidor reparte el trabajo: una tarea produce mensajes y otra los consume.
- {aislamiento} Con aislamiento, cada tarea guarda sus datos y solo comparte lo que envía por un canal.
:::

## Practica {#practica}

::: practica
- concurrente.canales.canal-suma
- concurrente.canales.canal-tabla
- concurrente.canales.pedidos-contar
- concurrente.canales.quien-es-quien
- concurrente.canales.sin-cerrar
- concurrente.canales.promedio-sensor
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«Dos tareas pueden escribir la misma caja sin problema».** Vuelve al aislamiento: lo compartido viaja por el canal.
- **Olvidar cerrar el canal.** El programa del bloqueo muestra qué pasa.
- **Esperar que un canal lleno descarte mensajes.** No descarta: quien envía espera hasta que haya lugar.
:::

::: siguiente
Dos proveedores pueden traer el pan. ¿Cómo se atiende al que llega primero y se deja de esperar lo que ya no hace falta?
:::

---
id: concurrente.tareas
numero: "5.1"
tipo: apertura
titulo: Varias cosas a la vez
duracion: 35
problema_breve: La bandeja que espera a todos
necesita: [funcional.proyecto]
introduce: [programacion-concurrente, concurrencia, tarea, agenda]
usa: [paradigma, subprograma, funcion-pura, programacion-funcional]
---

::: frase
Un programa concurrente reparte el trabajo en tareas que avanzan por turnos, y espera a todas antes de seguir.
:::

## El problema {#problema}

::: problema
La cocina del kiosco tiene **tres cocineros**: uno prepara **3 jugos** de 3 pesos, otro **2 sándwiches** de 5 pesos y otro **4 frutas** de 2 pesos. La bandeja sale al mostrador **solo cuando los tres terminaron**, y en el ticket va el valor total de la bandeja. Hasta ahora, cada programa hacía una cosa después de otra.

**¿Cómo se escribe una cocina donde los tres trabajan a la vez y la bandeja espera a todos?**
:::

## Inténtalo {#intentalo}

::: intento
Calcula el valor de la bandeja y di qué tiene que pasar antes de entregarla.
:::

::: respuesta
9 + 10 + 8 = **27 pesos**. La bandeja espera a que terminen los tres, sin importar quién termina primero.
:::

## Un paradigma nuevo {#paradigma}

::: recuerda termino=paradigma
:::

Hasta ahora, cada programa era una sola fila de órdenes: la siguiente empezaba cuando terminaba la anterior. La [[def:programacion-concurrente|programación concurrente]] propone otra forma de organizarlo.

::: paradigma
- pregunta: ¿y si un programa fuera un equipo de trabajadores que avanzan por turnos y se esperan cuando hace falta?
- metafora: una cocina con varios cocineros y una sola hornalla que se turnan. Deja de valer en un punto: un cocinero puede decidir solo cuándo deja la hornalla; una tarea cede su turno solo cuando espera algo.
- historia: en 1965, Edsger Dijkstra publicó cómo coordinar procesos que comparten recursos. En 1978, Tony Hoare describió procesos que se comunican enviándose mensajes, la idea que usa la lección siguiente.
- costo: hay que pensar qué puede pasar a la vez y qué tiene que esperar; algunos errores aparecen solo con ciertos turnos.
:::

La [[def:concurrencia|concurrencia]] es esa posibilidad: que varias partes de un programa avancen sin esperar a que la anterior termine del todo.

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran tres pedidos con precio y cantidad; sale el valor de la bandeja.
- **¿A qué se parece?** Al boletín de la Parte II: tres cálculos iguales con datos distintos.
- **¿Qué puede pasar a la vez y qué tiene que esperar?** Los tres platos son independientes; la bandeja espera a los tres.

## La herramienta nueva {#herramienta}

Una [[def:tarea|tarea]] es un trabajo que se lanza para que avance por su cuenta. Se escribe como un subprograma `Suspendible`, se lanza con `Lanzar` dentro de un ámbito `Tareas` y su resultado se pide con `Aguardar`. Al llegar a `FinTareas`, el ámbito espera a todas sus tareas: ninguna sigue viva después.

```figura-especificacion seccion=tareas.ambitos figura=ambito-tareas
```

```programa id=dos-saludos titulo="Dos saludos" ejecutar
SubProceso Suspendible Saludar(nombre Como Cadena)
  Escribir "Hola, ", nombre;
FinSubProceso

Algoritmo DosSaludos
  Tareas
    Lanzar Saludar("Ana");
    Lanzar Saludar("Leo");
  FinTareas
  Escribir "todas terminaron";
FinAlgoritmo
```

```salida
Hola, Ana
Hola, Leo
todas terminaron
```

Lo único garantizado es la última línea: `todas terminaron` sale después de los dos saludos, porque `FinTareas` espera a las dos tareas. Que Ana salude antes que Leo es lo que hoy da el motor, pero el programa no lo promete.

¿Cómo avanzan «a la vez» en una sola computadora? Por turnos. La [[def:agenda|agenda]] es la fila de tareas listas: le da el turno a una, y cuando esa tarea espera algo, cede el turno a la siguiente.

```figura-especificacion seccion=motor.agenda figura=agenda-cola
```

```figura id=ruta-cocina-turnos
pie: Una sola tarea avanza en cada turno; la que espera cede el suyo.
paso: El algoritmo lanza las tres tareas, que quedan en la fila.
paso: El algoritmo aguarda los jugos y cede su turno.
paso: Los jugos terminan; siguen los sándwiches.
paso: Siguen las frutas.
paso: Las tres terminaron: el algoritmo recibe los resultados y suma 27.
paso: Al cerrar el ámbito no queda ninguna tarea viva.
```

::: especificacion
- tareas.suspendible
- tareas.ambitos
- motor.agenda
:::

## Escribir {#escribir fase=3}

```programa id=cocina titulo="La cocina del kiosco" ejecutar
SubProceso Suspendible Cocinar(plato Como Cadena, precio Como Entero, porciones Como Entero) Como Entero
  Escribir "Empieza ", plato;
  Retornar precio * porciones;
FinSubProceso

Algoritmo Cocina
  Tareas
    Definir jugos Como Tarea<Entero> <- Lanzar Cocinar("jugos", 3, 3);
    Definir sandwiches Como Tarea<Entero> <- Lanzar Cocinar("sándwiches", 5, 2);
    Definir frutas Como Tarea<Entero> <- Lanzar Cocinar("frutas", 2, 4);
    Escribir "Bandeja: ", Aguardar jugos + Aguardar sandwiches + Aguardar frutas, " pesos";
  FinTareas
  Escribir "Bandeja entregada";
FinAlgoritmo
```

```salida
Empieza jugos
Empieza sándwiches
Empieza frutas
Bandeja: 27 pesos
Bandeja entregada
```

Cada cocinero es una tarea que devuelve el valor de su plato. `Tarea<Entero>` es la forma de pedir ese valor más tarde: `Aguardar` lo entrega cuando la tarea terminó, y si todavía no terminó, espera.

## Probar {#probar fase=4}

Qué está garantizado y qué no:

| Línea | ¿Garantizada? | Por qué |
|---|---|---|
| `Bandeja: 27 pesos` después de los tres `Empieza` | sí | espera los tres resultados |
| `Bandeja entregada` al final | sí | `FinTareas` espera a todas |
| El orden entre los tres `Empieza` | no | lo decide la agenda |

Caso borde: un cocinero con 0 porciones. La bandeja suma 0 por él y, aun así, espera a los tres.

## Mejorar {#mejorar fase=5}

En una frase: «Cada cocinero es una tarea, y la bandeja aguarda los tres resultados antes de salir».

| | Qué organiza el programa | Qué cuesta |
|---|---|---|
| Imperativo | órdenes que cambian cajas, una tras otra | seguir la historia de cada caja |
| Procedimental | subprogramas con nombre | decidir cómo partir el problema |
| Objetos | objetos que guardan su estado | decidir quién es responsable de qué |
| Funcional | funciones puras que componen valores | poner aparte todo lo que toca el mundo |
| Concurrente | tareas que avanzan por turnos | pensar qué puede pasar a la vez |

Queda un problema abierto: si la cocina tiene que avisarle al mostrador plato por plato, esperar el final de todo no alcanza.

## Lo que aprendiste {#aprendiste}

::: resumen
- {programacion-concurrente,concurrencia} La programación concurrente organiza un programa en partes que pueden avanzar a la vez; la concurrencia es esa posibilidad de avanzar por turnos.
- {tarea} Una tarea es un trabajo que se lanza para que avance por su cuenta; su ámbito la espera antes de seguir.
- {agenda} La agenda reparte los turnos entre las tareas; una tarea que espera cede su turno a otra.
:::

## Practica {#practica}

::: practica
- concurrente.tareas.suma-tareas
- concurrente.tareas.que-espera
- concurrente.tareas.bandeja
- concurrente.tareas.final-garantizado
- concurrente.tareas.turnos-ordenar
- concurrente.tareas.doble-romper
:::

::: docentes
- **«Las tareas corren al mismo tiempo».** Avanzan por turnos en una sola computadora: muestra la figura de la cocina.
- **«El orden de la salida siempre será este».** Separa lo garantizado de lo observado con la tabla de la fase 4.
- **Lanzar una tarea fuera de su ámbito.** El motor lo rechaza; envía a la sección de ámbitos de la Especificación en vez de explicar el diagnóstico.
:::

::: por-dentro
La agenda guarda las tareas listas en una fila y le da el turno a la primera; una tarea que espera sale de la fila hasta que lo que espera esté listo.

::: especificacion
- motor.agenda
:::
:::

::: siguiente
La cocina termina los platos de a uno. ¿Cómo le avisa al mostrador cada plato apenas sale, sin que los dos toquen la misma caja?
:::

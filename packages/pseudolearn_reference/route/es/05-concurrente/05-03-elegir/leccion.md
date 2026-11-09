---
id: concurrente.elegir
numero: "5.3"
tipo: leccion
titulo: Lo primero que llegue
duracion: 35
problema_breve: Tres proveedores y un pedido
necesita: [concurrente.canales]
introduce: [cancelacion]
usa: [tarea, canal, agenda, resultado-con-error]
---

::: frase
Cuando varias respuestas pueden llegar, se atiende la primera y se corta lo que ya no hace falta.
:::

## El problema {#problema}

::: problema
El kiosco pide fruta a **tres proveedores** a la vez: Norte, Sur y Oeste. Si **alguno no tiene stock**, el pedido completo se suspende y no tiene sentido seguir esperando a los demás.

**¿Cómo se escribe el pedido para que el primer problema detenga todo, y cómo se sabe cuántas consultas se cortaron?**
:::

## Inténtalo {#intentalo}

::: intento
Norte no tiene stock; Sur tiene 5 y Oeste tiene 3. ¿Qué pasa con el pedido?
:::

::: respuesta
El pedido se suspende por Norte. Las consultas que todavía no habían terminado se cortan: con los turnos que da hoy el motor, son las otras **dos**.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra el stock de cada proveedor; sale si el pedido se confirma o por qué se suspendió.
- **¿A qué se parece?** A la bandeja de la lección 5.1: tres tareas en un mismo ámbito.
- **¿Qué puede pasar a la vez y qué tiene que esperar?** Las tres consultas van a la vez; la primera que falla corta a las otras.

## La herramienta nueva {#herramienta}

A veces solo importa la primera respuesta. `Elegir` espera en varios canales a la vez y atiende el primero que está listo; los demás quedan sin atender.

```figura id=ruta-carrera
pie: Se atiende la primera respuesta; lo que ya no hace falta se corta.
paso: Las dos ofertas salen a la vez.
paso: La del Norte llega primero y se atiende.
paso: La del Sur ya no hace falta: se corta.
```

```programa id=primera-oferta titulo="La primera oferta" ejecutar
SubProceso Suspendible Ofrecer(oferta Como Canal<Entero>, precio Como Entero)
  Definir aceptado Como Logico <- Aguardar oferta.Enviar(precio);
  Si No aceptado Entonces
    Escribir "La oferta llegó tarde";
  FinSi
FinSubProceso

Algoritmo PrimeraOferta
  Definir norte Como Canal<Entero> <- Canal(1);
  Definir sur Como Canal<Entero> <- Canal(1);
  Tareas
    Lanzar Ofrecer(norte, 12);
    Lanzar Ofrecer(sur, 10);
    Elegir
      Recibir deNorte Desde norte:
        Segun deNorte Hacer
          Algo(precio): Escribir "Norte ofrece ", precio;
          Nada: Escribir "Norte no ofrece";
        FinSegun
      Recibir deSur Desde sur:
        Segun deSur Hacer
          Algo(precio): Escribir "Sur ofrece ", precio;
          Nada: Escribir "Sur no ofrece";
        FinSegun
    FinElegir
  FinTareas
FinAlgoritmo
```

```salida
Norte ofrece 12
```

Cuál oferta llega primero lo decide la agenda: hoy el motor atiende la del Norte, pero el programa no puede darlo por hecho.

La [[def:cancelacion|cancelación]] es cortar una tarea que ya no hace falta. Dentro de un ámbito pasa sola: si una tarea termina con `Error`, el ámbito cancela a sus hermanas. Con `Tareas fallo`, el ámbito guarda qué pasó en `fallo`, un `Opcional`: `Nada` si todo salió bien, o `Algo` con un informe. El informe dice el primer error, en `Primero`, y cuántas tareas se cortaron, en `Canceladas`.

::: especificacion
- tareas.canales
- tareas.ambitos
:::

## Escribir {#escribir fase=3}

```programa id=proveedores titulo="El pedido a tres proveedores" ejecutar
SubProceso Suspendible Consultar(nombre Como Cadena, stock Como Entero) Como Resultado<Entero, Cadena>
  Si stock = 0 Entonces
    Retornar Error(nombre + " no tiene stock");
  FinSi
  Retornar Exito(stock);
FinSubProceso

Algoritmo Pedido
  Tareas fallo
    Lanzar Consultar("Norte", 0);
    Lanzar Consultar("Sur", 5);
    Lanzar Consultar("Oeste", 3);
  FinTareas
  Segun fallo Hacer
    Algo(problema):
      Escribir "Falló: ", problema.Primero;
      Escribir "Canceladas: ", problema.Canceladas;
    Nada: Escribir "Todos confirmaron";
  FinSegun
FinAlgoritmo
```

```salida
Falló: Norte no tiene stock
Canceladas: 2
```

Cada consulta devuelve un `Resultado`: `Exito` con el stock o `Error` con el motivo. Ninguna escribe nada; el algoritmo decide qué mostrar después de cerrar el ámbito.

## Probar {#probar fase=4}

| Caso | Qué pasa |
|---|---|
| Los tres con stock | `Todos confirmaron` |
| Solo el último sin stock | falla igual; se cortan las consultas que no terminaron |
| Los tres sin stock | manda el primer error |

Lo garantizado es que, si alguno falla, el pedido se suspende y el informe trae un error. Qué error es «el primero» cuando fallan dos, y cuántas consultas alcanzan a cortarse, depende de los turnos: los ejercicios no lo preguntan.

## Mejorar {#mejorar fase=5}

En una frase: «Las tres consultas van a la vez, y el primer error suspende el pedido y corta las demás».

Compara `Elegir` con esperar las respuestas una tras otra. Si solo importa una respuesta, esperar todas desperdicia la espera: con `Elegir`, la primera lista ya se atiende.

## Lo que aprendiste {#aprendiste}

::: resumen
- {cancelacion} Cancelar es cortar una tarea que ya no hace falta; en un ámbito, el primer error cancela a las hermanas.
:::

## Practica {#practica}

::: practica
- concurrente.elegir.canceladas
- concurrente.elegir.todos-bien
- concurrente.elegir.pedido-resolver
- concurrente.elegir.elegir-o-esperar
- concurrente.elegir.cancelar-clasificar
- concurrente.elegir.pedido-pruebas
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«Siempre gana el mismo canal».** Lo decide la agenda: no se asume.
- **«Cancelar borra lo que la tarea ya hizo».** Lo ya escrito queda; cancelar solo corta lo que faltaba.
- **Confundir cancelar con fallar.** Falla una tarea; las que se cortan por eso no fallaron.
:::

::: siguiente
Al cerrar el kiosco, todo lo que el programa sabía se pierde. ¿Cómo se guarda para mañana?
:::

---
id: tareas.canales
numero: "11.3"
tipo: concepto
titulo: "Canales y `Elegir`"
anclas: [LANG.TASK.CHANNEL#R1, LANG.TASK.CHANNEL#R2, LANG.TASK.CHANNEL#R3, LANG.TASK.CHANNEL#R4, LANG.TASK.CHANNEL#R5, LANG.TASK.CHANNEL#R6, LANG.TASK.CHANNEL#R7, LANG.TASK.CHANNEL#R8]
diagnosticos: [channelElementNotTransferable, channelCapacityInvalid, channelCapacityExceeded, channelOperationWithoutAwait, pureFunctionTaskOperation, selectNeedsTwoBranches]
terminos: [canal, capacidad, productor, consumidor]
---

::: frase
Un canal es una cola con capacidad fija por la que unas tareas envían valores y otras los reciben, en orden y sin compartir memoria.
:::

## Cómo funciona {#funciona}

`Canal<T>` es el tipo y `Canal(n)` crea uno con capacidad `n`. Tres operaciones:

| Operación | Qué hace |
|---|---|
| `Aguardar c.Enviar(v)` | encola `v`; si está lleno, espera. Devuelve `Falso` si el canal está cerrado |
| `Aguardar c.Recibir()` | saca el primero como `Algo(v)`; si está vacío, espera. Cerrado y vacío da `Nada` |
| `c.Cerrar()` | cierra el canal sin perder lo encolado |

```figura id=canal-cola
pie: Un canal de capacidad 2. El productor espera cuando está lleno; el consumidor, cuando está vacío. Los valores salen en el orden en que entraron.
```

```programa id=tuberia titulo="Un productor y un consumidor" ejecutar
SubProceso Suspendible Productor(canal Como Canal<Entero>)
  Para i <- 1 Hasta 3 Hacer
    Si NO Aguardar canal.Enviar(i * 10) Entonces
      Salir;
    FinSi
  FinPara
  canal.Cerrar();
FinSubProceso

Algoritmo Tuberia
  Definir canal Como Canal<Entero> <- Canal(2);
  Tareas
    Lanzar Productor(canal);
    Definir seguir Como Logico <- Verdadero;
    Mientras seguir Hacer
      Segun Aguardar canal.Recibir() Hacer
        Algo(valor):
          Escribir "recibido ", valor;
        Nada:
          seguir <- Falso;
      FinSegun
    FinMientras
  FinTareas
FinAlgoritmo
```

```salida
recibido 10
recibido 20
recibido 30
```

## Elegir {#elegir}

`Elegir` espera en **varios** canales a la vez y atiende al primero que tenga algo. Si varios están listos, gana la primera rama escrita: el resultado es siempre el mismo.

```programa id=elegir titulo="Atender al primero que llegue" ejecutar
SubProceso Suspendible Avisar(canal Como Canal<Cadena>)
  Si Aguardar canal.Enviar("aviso urgente") Entonces
    canal.Cerrar();
  FinSi
FinSubProceso

SubProceso Anunciar(origen Como Cadena, mensaje Como Opcional<Cadena>)
  Segun mensaje Hacer
    Algo(texto): Escribir origen, ": ", texto;
    Nada: Escribir origen, ": cerrado";
  FinSegun
FinSubProceso

Algoritmo Elige
  Definir noticias Como Canal<Cadena> <- Canal(1);
  Definir avisos Como Canal<Cadena> <- Canal(1);
  Tareas
    Lanzar Avisar(avisos);
    Elegir
      Recibir n Desde noticias:
        Anunciar("noticias", n);
      Recibir a Desde avisos:
        Anunciar("avisos", a);
    FinElegir
  FinTareas
FinAlgoritmo
```

```salida
avisos: aviso urgente
```

::: limite
- La capacidad es como mínimo 1; una constante menor es `channelCapacityInvalid`.
- Solo viajan valores transferibles: ni objetos ni registros con objetos dentro.
- `Elegir` necesita al menos dos ramas.
:::

::: resumen
- Un canal es una cola acotada entre tareas.
- `Enviar` y `Recibir` se usan con `Aguardar`; `Cerrar`, sin él.
- `Elegir` atiende al primer canal listo, con desempate por orden escrito.
:::

::: vease
- [Ámbitos de tareas](#tareas.ambitos)
- [Opcional y Resultado](#tipos.opcional-resultado)
:::

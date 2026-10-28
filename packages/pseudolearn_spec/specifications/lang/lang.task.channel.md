---
{
  "formato": "see/1",
  "id": "LANG.TASK.CHANNEL",
  "titulo": "Canales acotados y elección determinista",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Canales acotados y elección determinista",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TASK.SCOPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Canales acotados y elección determinista

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Canal<T> solo admite elementos transferibles transitivamente; un registro con campo de clase también se rechaza con channelElementNotTransferable. No admite igualdad, orden ni escritura.",
  "verificacion": [
    "C17",
    "C21"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Canal(n) con contexto de tipo crea un canal abierto de capacidad explícita n >= 1. Una constante menor que uno produce channelCapacityInvalid en análisis; un valor dinámico inválido falla con ese código. Superar el máximo configurado produce channelCapacityExceeded. Identidad monotónica desde uno y coste de 1 + n × max(1, ancho(T)) celdas.",
  "verificacion": [
    "C1",
    "C2",
    "C13",
    "C16",
    "C19",
    "C20"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Aguardar canal.Enviar(v) devuelve Logico: cerrado da Falso; un receptor esperando recibe directamente; con espacio encola; lleno suspende al emisor en FIFO. La recepción libera espacio, encola el valor del primer emisor y lo despierta con Verdadero.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C6"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Aguardar canal.Recibir() devuelve Opcional<T>: consume la cabeza; cerrado y vacío da Nada; abierto y vacío suspende en FIFO.",
  "verificacion": [
    "C5",
    "C7"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Cerrar no suspende, es idempotente, conserva datos encolados y despierta emisores con Falso y receptores con Nada en orden de espera.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Enviar y Recibir requieren Aguardar, o producen channelOperationWithoutAwait. Una Funcion no puede operar canales (pureFunctionTaskOperation), aunque sí crearlos.",
  "verificacion": [
    "C14",
    "C15",
    "C18"
  ]
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Elegir exige al menos dos ramas Recibir x Desde canal:, con x inmutable Opcional<T> local a su rama. Evalúa los canales una sola vez en orden textual. Gana la primera rama lista (datos, emisor o cierre). Si ninguna está lista, registra todas y suspende; el primer envío o cierre completa una sola rama y retira las demás inscripciones atómicamente. Repetir canal elige la primera rama textual. Menos de dos ramas produce selectNeedsTwoBranches.",
  "verificacion": [
    "C9",
    "C10",
    "C11",
    "C12"
  ]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Elegir emite statement_entered, decision de rama caso con índice textual ganador y statement_exited.",
  "verificacion": [
    "C9"
  ]
}
```


















```caso
{
  "id": "C1",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir firstAccepted Como Logico <- Aguardar stream.Enviar(1);\nSi firstAccepted Entonces\nFinSi\nDefinir secondAccepted Como Logico <- Aguardar stream.Enviar(2);\nSi secondAccepted Entonces\nFinSi\nstream.Cerrar();\nFinSubProceso\nSubProceso Suspendible Consume(stream Como Canal<Entero>)\nRepetir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Salir;\nFinSegun\nHasta Que Falso\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Produce(stream);\nLanzar Consume(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Produce(stream as channel<integer>)\ndefine firstAccepted as boolean <- await stream.send(1);\nif firstAccepted then\nendIf\ndefine secondAccepted as boolean <- await stream.send(2);\nif secondAccepted then\nendIf\nstream.close();\nendSubroutine\nsubroutine suspendable Consume(stream as channel<integer>)\nrepeat\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: break;\nendSwitch\nuntil false\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Produce(stream);\nspawn Consume(stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir firstAccepted Como Logico <- Aguardar stream.Enviar(1);\nSi firstAccepted Entonces\nFinSi\nDefinir secondAccepted Como Logico <- Aguardar stream.Enviar(2);\nSi secondAccepted Entonces\nFinSi\nstream.Cerrar();\nFinSubProceso\nSubProceso Suspendible Consume(stream Como Canal<Entero>)\nRepetir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Salir;\nFinSegun\nHasta Que Falso\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(4);\nTareas\nLanzar Produce(stream);\nLanzar Consume(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Produce(stream as channel<integer>)\ndefine firstAccepted as boolean <- await stream.send(1);\nif firstAccepted then\nendIf\ndefine secondAccepted as boolean <- await stream.send(2);\nif secondAccepted then\nendIf\nstream.close();\nendSubroutine\nsubroutine suspendable Consume(stream as channel<integer>)\nrepeat\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: break;\nendSwitch\nuntil false\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(4);\ntasks\nspawn Produce(stream);\nspawn Consume(stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir firstAccepted Como Logico <- Aguardar stream.Enviar(1);\nSi firstAccepted Entonces\nFinSi\nDefinir secondAccepted Como Logico <- Aguardar stream.Enviar(2);\nSi secondAccepted Entonces\nFinSi\nstream.Cerrar();\nFinSubProceso\nSubProceso Suspendible Consume(stream Como Canal<Entero>)\nRepetir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Salir;\nFinSegun\nHasta Que Falso\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Produce(stream);\nLanzar Consume(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Produce(stream as channel<integer>)\ndefine firstAccepted as boolean <- await stream.send(1);\nif firstAccepted then\nendIf\ndefine secondAccepted as boolean <- await stream.send(2);\nif secondAccepted then\nendIf\nstream.close();\nendSubroutine\nsubroutine suspendable Consume(stream as channel<integer>)\nrepeat\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: break;\nendSwitch\nuntil false\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Produce(stream);\nspawn Consume(stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Produce(stream Como Canal<Entero>)\nDefinir firstAccepted Como Logico <- Aguardar stream.Enviar(1);\nSi firstAccepted Entonces\nFinSi\nDefinir secondAccepted Como Logico <- Aguardar stream.Enviar(2);\nSi secondAccepted Entonces\nFinSi\nstream.Cerrar();\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Produce(stream);\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nSegun Aguardar stream.Recibir() Hacer\nAlgo(nextValue): Escribir nextValue;\nNada: Escribir 0;\nFinSegun\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Produce(stream as channel<integer>)\ndefine firstAccepted as boolean <- await stream.send(1);\nif firstAccepted then\nendIf\ndefine secondAccepted as boolean <- await stream.send(2);\nif secondAccepted then\nendIf\nstream.close();\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Produce(stream);\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nswitch await stream.receive() do\nsome(nextValue): write nextValue;\nnone: write 0;\nendSwitch\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir accepted Como Logico <- Aguardar stream.Enviar(7);\nSi accepted Entonces\nFinSi\nstream.Cerrar();\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nSegun Aguardar stream.Recibir() Hacer\nAlgo(lastValue): Escribir lastValue;\nNada: Escribir \"closed\";\nFinSegun\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine accepted as boolean <- await stream.send(7);\nif accepted then\nendIf\nstream.close();\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nswitch await stream.receive() do\nsome(lastValue): write lastValue;\nnone: write \"closed\";\nendSwitch\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\nclosed\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Send(stream Como Canal<Entero>)\nDefinir accepted Como Logico <- Aguardar stream.Enviar(2);\nSi accepted Entonces\nEscribir \"sent\";\nSino\nEscribir \"closed\";\nFinSi\nFinSubProceso\nSubProceso Suspendible Close(stream Como Canal<Entero>)\nstream.Cerrar();\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir accepted Como Logico <- Aguardar stream.Enviar(1);\nSi accepted Entonces\nFinSi\nTareas\nLanzar Send(stream);\nLanzar Send(stream);\nLanzar Close(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Send(stream as channel<integer>)\ndefine accepted as boolean <- await stream.send(2);\nif accepted then\nwrite \"sent\";\nelse\nwrite \"closed\";\nendIf\nendSubroutine\nsubroutine suspendable Close(stream as channel<integer>)\nstream.close();\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine accepted as boolean <- await stream.send(1);\nif accepted then\nendIf\ntasks\nspawn Send(stream);\nspawn Send(stream);\nspawn Close(stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "closed\nclosed\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Receive(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir \"closed\";\nFinSegun\nFinSubProceso\nSubProceso Suspendible Close(stream Como Canal<Entero>)\nstream.Cerrar();\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Receive(stream);\nLanzar Receive(stream);\nLanzar Close(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Receive(stream as channel<integer>)\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write \"closed\";\nendSwitch\nendSubroutine\nsubroutine suspendable Close(stream as channel<integer>)\nstream.close();\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Receive(stream);\nspawn Receive(stream);\nspawn Close(stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "closed\nclosed\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nstream.Cerrar();\nstream.Cerrar();\nDefinir accepted Como Logico <- Aguardar stream.Enviar(1);\nSi accepted Entonces\nEscribir \"sent\";\nSino\nEscribir \"closed\";\nFinSi\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\nstream.close();\nstream.close();\ndefine accepted as boolean <- await stream.send(1);\nif accepted then\nwrite \"sent\";\nelse\nwrite \"closed\";\nendIf\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "closed\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir other Como Canal<Entero> <- Canal(4);\nDefinir firstAccepted Como Logico <- Aguardar stream.Enviar(7);\nSi firstAccepted Entonces\nFinSi\nDefinir secondAccepted Como Logico <- Aguardar other.Enviar(8);\nSi secondAccepted Entonces\nFinSi\nElegir\nRecibir first Desde stream:\nSegun first Hacer\nAlgo(value): Escribir value;\nNada: Escribir 1;\nFinSegun\nRecibir second Desde other:\nSegun second Hacer\nAlgo(otherValue): Escribir otherValue;\nNada: Escribir 2;\nFinSegun\nFinElegir\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine other as channel<integer> <- channel(4);\ndefine firstAccepted as boolean <- await stream.send(7);\nif firstAccepted then\nendIf\ndefine secondAccepted as boolean <- await other.send(8);\nif secondAccepted then\nendIf\nselect\nreceive first from stream:\nswitch first do\nsome(value): write value;\nnone: write 1;\nendSwitch\nreceive second from other:\nswitch second do\nsome(otherValue): write otherValue;\nnone: write 2;\nendSwitch\nendSelect\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nstream.Cerrar();\nElegir\nRecibir first Desde stream:\nSegun first Hacer\nAlgo(value): Escribir value;\nNada: Escribir 1;\nFinSegun\nRecibir second Desde stream:\nSegun second Hacer\nAlgo(otherValue): Escribir otherValue;\nNada: Escribir 2;\nFinSegun\nFinElegir\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\nstream.close();\nselect\nreceive first from stream:\nswitch first do\nsome(value): write value;\nnone: write 1;\nendSwitch\nreceive second from stream:\nswitch second do\nsome(otherValue): write otherValue;\nnone: write 2;\nendSwitch\nendSelect\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Close(stream Como Canal<Entero>)\nstream.Cerrar();\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir other Como Canal<Entero> <- Canal(4);\nTareas\nLanzar Close(other);\nElegir\nRecibir first Desde stream:\nSegun first Hacer\nAlgo(value): Escribir value;\nNada: Escribir 1;\nFinSegun\nRecibir second Desde other:\nSegun second Hacer\nAlgo(otherValue): Escribir otherValue;\nNada: Escribir 2;\nFinSegun\nFinElegir\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Close(stream as channel<integer>)\nstream.close();\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine other as channel<integer> <- channel(4);\ntasks\nspawn Close(other);\nselect\nreceive first from stream:\nswitch first do\nsome(value): write value;\nnone: write 1;\nendSwitch\nreceive second from other:\nswitch second do\nsome(otherValue): write otherValue;\nnone: write 2;\nendSwitch\nendSelect\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nElegir\nRecibir value Desde stream:\nFinElegir\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\nselect\nreceive value from stream:\nendSelect\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "selectNeedsTwoBranches",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(65536);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(65536);\nstream.close();\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir accepted Como Logico <- Aguardar stream.Enviar(1);\nSi accepted Entonces\nFinSi\nDefinir received Como Opcional<Entero> <- stream.Recibir();\nSegun received Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine accepted as boolean <- await stream.send(1);\nif accepted then\nendIf\ndefine received as optional<integer> <- stream.receive();\nswitch received do\nsome(value): write value;\nnone: write 0;\nendSwitch\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelOperationWithoutAwait",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir accepted Como Logico <- stream.Enviar(1);\nEscribir accepted;\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine accepted as boolean <- stream.send(1);\nwrite accepted;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelOperationWithoutAwait",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable capacity Como Entero <- 0;\ncapacity <- capacity - 1;\nDefinir stream Como Canal<Entero> <- Canal(capacity);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine mutable capacity as integer <- 0;\ncapacity <- capacity - 1;\ndefine stream as channel<integer> <- channel(capacity);\nstream.close();\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "channelCapacityInvalid"
    }
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Vector<Entero>> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<vector<integer>> <- channel(1);\nstream.close();\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelElementNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Funcion Close(stream Como Canal<Entero>)\nstream.Cerrar();\nFinFuncion\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "function Close(stream as channel<integer>)\nstream.close();\nendSubroutine\nAlgoritmo P\n\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTaskOperation",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(65537);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(65537);\nstream.close();\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "channelCapacityExceeded"
    }
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(0);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(0);\nstream.close();\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelCapacityInvalid",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Clase Customer\nFinClase\nRegistro Request\nDefinir customer Como Customer;\nFinRegistro\nAlgoritmo P\nDefinir stream Como Canal<Request> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "class Customer\nendClass\nrecord Request\ndefine customer as Customer;\nendRecord\nAlgoritmo P\ndefine stream as channel<Request> <- channel(1);\nstream.close();\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelElementNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```


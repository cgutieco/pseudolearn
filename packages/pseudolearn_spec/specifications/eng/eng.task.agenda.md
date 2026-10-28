---
{
  "formato": "see/1",
  "id": "ENG.TASK.AGENDA",
  "titulo": "Diagnóstico de bloqueo de tareas",
  "dominio": "motor",
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
  "resumen": "Diagnóstico de bloqueo de tareas",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TASK.CHANNEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Diagnóstico de bloqueo de tareas

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Si no hay tarea ejecutable ni efectos pendientes capaces de reanudar una tarea viva, la ejecución termina failed con taskDeadlock. Los efectos abandonados no cuentan. Si existe al menos un efecto pendiente no abandonado, devuelve awaiting_effect. El diagnóstico conserva como ubicaciones relacionadas los sitios de suspensión de las tareas bloqueadas, por identidad.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
  ]
}
```






```caso
{
  "id": "C1",
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
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "Algoritmo P\ndefine stream as channel<integer> <- channel(1);\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "taskDeadlock"
    }
  }
}
```

```caso
{
  "id": "C2",
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
    "es": "SubProceso Suspendible Receive(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Receive(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Receive(stream as channel<integer>)\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Receive(stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "taskDeadlock"
    }
  }
}
```

```caso
{
  "id": "C3",
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
    "es": "SubProceso Suspendible Receive(first Como Canal<Entero>, second Como Canal<Entero>)\nSegun Aguardar first.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nDefinir accepted Como Logico <- Aguardar second.Enviar(1);\nSi accepted Entonces\nFinSi\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir other Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Receive(stream, other);\nLanzar Receive(other, stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Receive(first as channel<integer>, second as channel<integer>)\nswitch await first.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\ndefine accepted as boolean <- await second.send(1);\nif accepted then\nendIf\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ndefine other as channel<integer> <- channel(1);\ntasks\nspawn Receive(stream, other);\nspawn Receive(other, stream);\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "taskDeadlock"
    }
  }
}
```

```caso
{
  "id": "C4",
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
    "es": "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Wait();\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait()\ndiscard await requestTimer();\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Wait();\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nendTasks\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "awaiting_effect",
    "efecto_pendiente": {
      "effect_seq": 1,
      "capability_kind": "timer",
      "operation": "request_timer"
    }
  },
  "anfitrion": {
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ],
    "detached": true
  }
}
```

```caso
{
  "id": "C5",
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
    "es": "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas failureReport\nLanzar Wait();\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nSegun Aguardar stream.Recibir() Hacer\nAlgo(receivedValue): Escribir receivedValue;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait()\ndiscard await requestTimer();\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nAlgoritmo P\ndefine stream as channel<integer> <- channel(1);\ntasks failureReport\nspawn Wait();\nspawn Fail();\nendTasks\ndiscard failureReport;\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "taskDeadlock"
    }
  },
  "anfitrion": {
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ],
    "detached": true
  }
}
```


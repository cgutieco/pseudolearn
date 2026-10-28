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
    "en": "algorithm P\ndefine stream as channel<integer> <- channel(1);\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
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
    "en": "subroutine suspendable Receive(stream as channel<integer>)\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Receive(stream);\nendTasks\nendAlgorithm\n"
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
    "en": "subroutine suspendable Receive(first as channel<integer>, second as channel<integer>)\nswitch await first.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\ndefine accepted as boolean <- await second.send(1);\nif accepted then\nendIf\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ndefine other as channel<integer> <- channel(1);\ntasks\nspawn Receive(stream, other);\nspawn Receive(other, stream);\nendTasks\nendAlgorithm\n"
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
    "en": "subroutine suspendable Wait()\ndiscard await requestTimer();\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Wait();\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nendTasks\nendAlgorithm\n"
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
    "en": "subroutine suspendable Wait()\ndiscard await requestTimer();\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ntasks failureReport\nspawn Wait();\nspawn Fail();\nendTasks\ndiscard failureReport;\nswitch await stream.receive() do\nsome(receivedValue): write receivedValue;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
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

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La raíz tiene identidad cero; cada Lanzar asigna la siguiente identidad monotónica desde uno sin reutilizarla.",
  "verificacion": [
    "C6"
  ]
}
```
```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Solo una tarea ejecuta; las demás están listas, suspendidas con causa o terminadas.",
  "verificacion": [
    "C12"
  ]
}
```
```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La cola de tareas listas es FIFO: nuevas, despertadas y las que ceden entran al final; un despertar múltiple conserva el orden de espera.",
  "verificacion": [
    "C7"
  ]
}
```
```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Al suspenderse o terminar la tarea actual se reanuda la cabeza de la cola. Lanzar no desplaza al padre.",
  "verificacion": [
    "C13"
  ]
}
```
```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Cada tarea acumula masa de sentencia desde su reanudación, incluyendo las llamadas síncronas. Solo las aristas de retorno de bucles de unidades suspendibles comprueban el cuanto 1024. Si no se alcanza, la masa se conserva. Al alcanzar el cuanto, se pone a cero; con cola lista no vacía se cede al final, con cola vacía continúa sin suspensión.",
  "verificacion": [
    "C8",
    "C9",
    "C10"
  ]
}
```
```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Los efectos concurrentes suspenden solo su tarea; el anfitrión entrega resultados únicamente cuando la agenda no tiene tareas listas. Los efectos abandonados no mantienen una espera de efecto.",
  "verificacion": [
    "C11"
  ]
}
```

```caso
{
  "id": "C6",
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
    "es": "SubProceso Suspendible Say(name Como Cadena)\nEscribir name;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Say(\"alpha\");\nLanzar Say(\"beta\");\nLanzar Say(\"gamma\");\nEscribir \"parent\";\nFinTareas\nEscribir \"joined\";\nFinAlgoritmo\n",
    "en": "subroutine suspendable Say(name as string)\nwrite name;\nendSubroutine\nalgorithm Main\ntasks\nspawn Say(\"alpha\");\nspawn Say(\"beta\");\nspawn Say(\"gamma\");\nwrite \"parent\";\nendTasks\nwrite \"joined\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "parent\nalpha\nbeta\ngamma\njoined\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
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
    "es": "SubProceso Suspendible Waiter(name Como Cadena, stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir name;\nNada: Escribir name;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Closer(stream Como Canal<Entero>)\nEscribir \"closing\";\nstream.Cerrar();\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Waiter(\"alpha\", stream);\nLanzar Waiter(\"beta\", stream);\nLanzar Waiter(\"gamma\", stream);\nLanzar Closer(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Waiter(name as string, stream as channel<integer>)\nswitch await stream.receive() do\nsome(value): write name;\nnone: write name;\nendSwitch\nendSubroutine\nsubroutine suspendable Closer(stream as channel<integer>)\nwrite \"closing\";\nstream.close();\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Waiter(\"alpha\", stream);\nspawn Waiter(\"beta\", stream);\nspawn Waiter(\"gamma\", stream);\nspawn Closer(stream);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "closing\nalpha\nbeta\ngamma\n",
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
    "es": "SubProceso Suspendible Work(marker Como Entero)\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < 1024 Hacer\nEscribir marker;\ncounter <- counter + 1;\nFinMientras\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(1);\nLanzar Work(2);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(marker as integer)\ndefine mutable counter as integer <- 0;\nwhile counter < 1024 do\nwrite marker;\ncounter <- counter + 1;\nendWhile\nendSubroutine\nalgorithm Main\ntasks\nspawn Work(1);\nspawn Work(2);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n1\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
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
    "es": "SubProceso Suspendible Work(marker Como Entero)\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < 10 Hacer\nEscribir marker;\ncounter <- counter + 1;\nFinMientras\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(1);\nLanzar Work(2);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(marker as integer)\ndefine mutable counter as integer <- 0;\nwhile counter < 10 do\nwrite marker;\ncounter <- counter + 1;\nendWhile\nendSubroutine\nalgorithm Main\ntasks\nspawn Work(1);\nspawn Work(2);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n2\n2\n2\n2\n2\n2\n2\n2\n2\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
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
    "es": "SubProceso Suspendible Work(marker Como Entero)\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < 1024 Hacer\nEscribir marker;\ncounter <- counter + 1;\nFinMientras\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(1);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(marker as integer)\ndefine mutable counter as integer <- 0;\nwhile counter < 1024 do\nwrite marker;\ncounter <- counter + 1;\nendWhile\nendSubroutine\nalgorithm Main\ntasks\nspawn Work(1);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
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
    "es": "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nEscribir \"late\";\nFinSubProceso\nSubProceso Suspendible Say()\nEscribir \"early\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Wait();\nLanzar Say();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait()\ndiscard await requestTimer();\nwrite \"late\";\nendSubroutine\nsubroutine suspendable Say()\nwrite \"early\";\nendSubroutine\nalgorithm Main\ntasks\nspawn Wait();\nspawn Say();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "early\nlate\n",
    "terminacion": "completed"
  },
  "anfitrion": {
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ]
  }
}
```

```caso
{
  "id": "C12",
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
    "es": "SubProceso Suspendible Work(marker Como Entero)\nDefinir Mutable counter Como Entero <- 0;\nMientras counter < 5 Hacer\nEscribir marker;\ncounter <- counter + 1;\nFinMientras\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(1);\nLanzar Work(2);\nLanzar Work(3);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(marker as integer)\ndefine mutable counter as integer <- 0;\nwhile counter < 5 do\nwrite marker;\ncounter <- counter + 1;\nendWhile\nendSubroutine\nalgorithm Main\ntasks\nspawn Work(1);\nspawn Work(2);\nspawn Work(3);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n1\n1\n1\n1\n2\n2\n2\n2\n2\n3\n3\n3\n3\n3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
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
    "es": "SubProceso Suspendible Say(name Como Cadena)\nEscribir name;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Say(\"child\");\nEscribir \"first\";\nEscribir \"second\";\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Say(name as string)\nwrite name;\nendSubroutine\nalgorithm Main\ntasks\nspawn Say(\"child\");\nwrite \"first\";\nwrite \"second\";\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "first\nsecond\nchild\n",
    "terminacion": "completed"
  }
}
```

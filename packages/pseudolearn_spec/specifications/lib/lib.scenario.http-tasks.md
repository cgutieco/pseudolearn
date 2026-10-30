---
{
  "formato": "see/1",
  "id": "LIB.SCENARIO.HTTP-TASKS",
  "titulo": "Escenario integrador de HTTP y tareas",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": ["responsable-lenguaje"],
  "sujetos": ["engine", "aot"],
  "resumen": "Composición de respuestas HTTP, fallos de tareas, cancelación y límites de red.",
  "titulo_en": "Integrated HTTP and tasks scenario",
  "depende_de": [
    {"id": "LIB.HTTP", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "LANG.TASK.SCOPE", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "ENG.EFFECT.TAPE", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "ENG.LIMITS", "version": ">=1.0.0, <2.0.0", "tipo": "usa"},
    {"id": "API.STATE.QUERY", "version": ">=1.0.0, <2.0.0", "tipo": "usa"}
  ],
  "revisado_por": ["Cesar Antonio Gutierrez Contreras"]
}
---

# Escenario integrador de HTTP y tareas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La composición usa LIB.HTTP@1.0.0#R2, R5 y R7, LANG.TASK.SCOPE@1.0.0#R15, ENG.EFFECT.TAPE@1.0.0#R6, ENG.LIMITS@1.0.0#R13 y API.STATE.QUERY@1.0.0#R5. Las hijas envían una petición por recurso: una respuesta 500 es RespuestaHttp y no un error de transporte; una conexión fallida se conserva en FalloTareas.Primero y cancela las hermanas vivas; Canceladas cuenta las hijas canceladas. Una respuesta vacía conserva longitud cero. Sin permiso red no se envía ninguna solicitud. La cancelación de una hermana mientras POST sigue pendiente registra network_send como abandoned y sella la cinta uncertain_external_state. max_pending_network agotado produce LimiteExcedido antes de enviar la petición excedente. Consultar un evento anterior al envío después de completarlo no vuelve a enviar la petición ni aumenta las llamadas del anfitrión.",
  "verificacion": ["C1", "C2", "C3", "C4", "C5", "C6", "C7"]
}
```

```cobertura
{
  "id": "V1",
  "regla": "LIB.SCENARIO.HTTP-TASKS#R1",
  "sin_ri": "El contrato fija composición observable de biblioteca y anfitrión; no introduce instrucciones de RI."
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "SubProceso Suspendible Fetch(net Como RedCap, url Como Cadena) Como Resultado<Entero, Cadena>\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, url)) Hacer\nExito(response): Escribir response.Estado(); Retornar Exito(response.Estado());\nError(problem): Retornar Error(problem.Codigo);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas failureReport\nLanzar Fetch(net, \"https://fake.test/status-500\");\nLanzar Fetch(net, \"https://fake.test/offline\");\nLanzar Fetch(net, \"https://fake.test/status-200\");\nFinTareas\nSegun failureReport Hacer\nNada: Escribir \"sin_fallos\";\nAlgo(problem): Escribir problem.Primero; Escribir problem.Canceladas;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fetch(net as NetworkCap, url as string) as result<integer, string>\nswitch await net.send(HttpRequest(HttpMethod.GET, url)) do\nsuccess(response): write response.status(); return success(response.status());\nfailure(problem): return failure(problem.code);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks failureReport\nspawn Fetch(net, \"https://fake.test/status-500\");\nspawn Fetch(net, \"https://fake.test/offline\");\nspawn Fetch(net, \"https://fake.test/status-200\");\nendTasks\nswitch failureReport do\nnone: write \"sin_fallos\";\nsome(problem): write problem.first; write problem.cancelled;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "500\nconexion_fallida\n1\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 3, "estado_cinta": "uncertain_external_state"}
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/status-500": {"estado": 500},
      "GET https://fake.test/offline": {"fallo": "conexion_fallida", "incierto": false},
      "GET https://fake.test/status-200": {"estado": 200}
    }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "SubProceso Suspendible Fetch(net Como RedCap, url Como Cadena)\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, url)) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(net, \"https://fake.test/status-500\");\nLanzar Fetch(net, \"https://fake.test/status-200\");\nLanzar Fetch(net, \"https://fake.test/status-204\");\nFinTareas\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fetch(net as NetworkCap, url as string)\nswitch await net.send(HttpRequest(HttpMethod.GET, url)) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks\nspawn Fetch(net, \"https://fake.test/status-500\");\nspawn Fetch(net, \"https://fake.test/status-200\");\nspawn Fetch(net, \"https://fake.test/status-204\");\nendTasks\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "500\n200\n204\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 4, "estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/status-500": {"estado": 500},
      "GET https://fake.test/status-200": {"estado": 200},
      "GET https://fake.test/status-204": {"estado": 204}
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/empty\")) Hacer\nExito(response): Escribir response.Cuerpo().Longitud();\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net):\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/empty\")) do\nsuccess(response): write response.body().length();\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 2, "estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/empty": {"estado": 200, "cuerpo": ""}},
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/denied\")) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net):\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/denied\")) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 0, "estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": [],
    "requested_permissions": ["red"]
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "programas": {
    "es": "SubProceso Suspendible Fetch(net Como RedCap, url Como Cadena)\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, url)) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(net, \"https://fake.test/first\");\nLanzar Fetch(net, \"https://fake.test/second\");\nFinTareas\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fetch(net as NetworkCap, url as string)\nswitch await net.send(HttpRequest(HttpMethod.GET, url)) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks\nspawn Fetch(net, \"https://fake.test/first\");\nspawn Fetch(net, \"https://fake.test/second\");\nendTasks\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "limites": {"max_pending_network": 1},
  "espera": {
    "salida": "200\nlimite_excedido\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 2, "estado_cinta": "reproducible"}
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/first": {"estado": 200},
      "GET https://fake.test/second": {"estado": 201}
    }
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto"],
  "programas": {
    "es": "SubProceso Suspendible Wait(net Como RedCap)\nDescartar Aguardar net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/pending\"));\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"fallo\");\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas failureReport\nLanzar Wait(net);\nLanzar Fail();\nFinTareas\nSegun failureReport Hacer\nNada: Escribir \"sin_fallos\";\nAlgo(problem): Escribir problem.Primero; Escribir problem.Canceladas;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait(net as NetworkCap)\ndiscard await net.send(HttpRequest(HttpMethod.POST, \"https://fake.test/pending\"));\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"fallo\");\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks failureReport\nspawn Wait(net);\nspawn Fail();\nendTasks\nswitch failureReport do\nnone: write \"sin_fallos\";\nsome(problem): write problem.first; write problem.cancelled;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {"operation": "create_analysis"},
      {"operation": "start", "resource_from": 0, "arguments": {"host": {"permissions": ["red"], "requested_permissions": ["red"], "detached": true}}},
      {"operation": "advance", "resource_from": 1, "arguments": {"batch_size": 64}},
      {"operation": "effect_result", "resource_from": 1, "arguments": {"effect_seq": 1, "result": {"outcome": "committed", "value": {"kind": "capability", "value": {"slot": 0, "generation": 1, "rights": 4, "kind": 6}}}}},
      {"operation": "advance", "resource_from": 1, "arguments": {"batch_size": 64}}
    ]
  },
  "espera": {
    "api": {
      "results": [
        {"value": {}},
        {"value": {}},
        {"value": {"termination": {"kind": "awaiting_effect", "effect_seq": 1, "capability_kind": "network", "operation": "request_network"}}},
        {"value": null},
        {"value": {"output": "fallo\n1\n", "termination": {"kind": "completed"}, "effect_tape": {"status": "uncertain_external_state", "entries": [{"effect_seq": 1, "operation": "request_network", "outcome": "committed"}, {"effect_seq": 3, "operation": "write", "outcome": "committed"}, {"effect_seq": 4, "operation": "write", "outcome": "committed"}, {"effect_seq": 2, "operation": "network_send", "outcome": "abandoned"}]}}}
      ]
    }
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "antes\n200\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 2, "estado_cinta": "reproducible"},
    "estado_en": {
      "evento": 1,
      "estado": {"marcos": [{"unidad": "Main", "variables": {}}], "objetos": {}}
    }
  },
  "programa": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/once\"));\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nEscribir \"antes\";\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
  "perfil_base": "es",
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/once": {"estado": 200}},
    "grabar_y_reproducir": true
  }
}
```

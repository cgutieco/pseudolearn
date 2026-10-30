---
{
  "formato": "see/1",
  "id": "RT.HOST.INTERFACE",
  "titulo": "Interfaz con el anfitrión",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Capacidades inyectadas, grabables y fuente aleatoria fijada.",
  "depende_de": [
    {
      "id": "LIB.CORE.RANDOM",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "refina"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Host interface",
  "revisado_por": [
    "revision-independiente-automatizada-r9",
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Interfaz con el anfitrión

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La salida, la entrada y la semilla se inyectan al iniciar. El reloj, los archivos y la red requieren capacidades concedidas explícitamente por el anfitrión; no se leen variables de entorno ni hay fuente aleatoria ambiental implícita.",
  "verificacion": [
    "C1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir azar() < 1.0;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda capacidad del anfitrión, presente o futura, es grabable: su resultado se puede guardar en la cinta de la ejecución y reproducirse para obtener la misma ejecución sin volver a consultar al anfitrión.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "casos con entrada y azar del corpus"
  },
  "propiedad": "Reproducir una ejecución desde su cinta grabada produce las mismas observaciones.",
  "oraculo": "Ejecución original con el anfitrión real.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La fuente aleatoria es xoshiro256** cuyo estado inicial son las cuatro primeras salidas de SplitMix64 a partir de la semilla, un entero con signo de 64 bits reinterpretado en complemento a dos. Cada llamada a azar toma la siguiente salida s de 64 bits y devuelve (s desplazado 11 bits a la derecha) × 2⁻⁵³. La semilla por omisión es 42.",
  "verificacion": [
    "C2",
    "C3",
    "C4"
  ]
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5415695640260286\n6735350249106120\n927921571702396\n3752300831360421\n6602248042049669\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "semilla": 0
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "755370490430936\n3413550631330343\n6125286505004179\n8328893607999084\n8933375477570955\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "semilla": 42
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5043065146658773\n6912440677258288\n4569322158181384\n6734172366359527\n5109097669343124\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "semilla": -1
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo recurso asignado en la frontera del anfitrión se libera de manera forzosa e inmediata ante terminación cancelled, limit_reached o failed, incluida la desconexión o cancelación del anfitrión mientras una operación espera en awaiting_effect. En tales cortes, ninguna capacidad del anfitrión permanece abierta tras finalizar la sesión, la cinta se sella como Incomplete y no se ejecutan nuevos efectos de usuario dentro de Diferir.",
  "verificacion": [
    "C5",
    "C6",
    "C7"
  ]
}
```


## Oráculo

Los valores esperados de R3 se calculan con el oráculo independiente de see_oracles, que implementa SplitMix64 y xoshiro256** desde su definición; multiplicar por 2⁵³ y truncar recupera exactamente los 53 bits superiores de cada salida.

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "divisionByZero"
    },
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0,
      "estado_cinta": "incomplete",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "filesystem",
          "operation": "request_directory",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "filesystem",
          "operation": "file_open",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe(directory Como DirectorioCap) Como Resultado<Entero, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir Mutable zero Como Entero <- 0;\nRetornar Exito(10 div zero);\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Probe(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe(directory as DirCap) as result<integer, IoError>\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\ndefine mutable zero as integer <- 0;\nreturn success(10 div zero);\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Probe(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    }
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "cancelled",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0,
      "estado_cinta": "incomplete",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "filesystem",
          "operation": "request_directory",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "filesystem",
          "operation": "file_open",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe(directory Como DirectorioCap) Como Resultado<Entero, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir Mutable n Como Entero <- 0;\nMientras Verdadero Hacer\nn <- n + 1;\nFinMientras\nRetornar Exito(n);\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Probe(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe(directory as DirCap) as result<integer, IoError>\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\ndefine mutable n as integer <- 0;\nwhile true do\nn <- n + 1;\nendWhile\nreturn success(n);\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Probe(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    }
  },
  "cancelacion": 40,
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "cancelled",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0,
      "estado_cinta": "incomplete",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "filesystem",
          "operation": "request_directory",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "filesystem",
          "operation": "file_open",
          "outcome": "committed"
        },
        {
          "effect_seq": 3,
          "capability_kind": "filesystem",
          "operation": "file_read_text",
          "outcome": "requested"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Probe(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\nreturn file.readText();\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Probe(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    },
    "cancel_on_awaiting_effect": 3
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El anfitrión recibe la lista de efectos pendientes solo cuando ninguna tarea puede avanzar y devuelve los resultados de uno en uno; el orden en que decide entregarlos es una entrada más de la ejecución y queda registrado en la cinta.",
  "verificacion": [
    "C8"
  ]
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n1\n2\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 3,
          "task_id": 3,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 1
        },
        {
          "effect_seq": 1,
          "task_id": 1,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 3
        },
        {
          "effect_seq": 2,
          "task_id": 2,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 5
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Pause(label Como Entero)\nDescartar Aguardar SolicitarTemporizador();\nEscribir label;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Pause(1);\nLanzar Pause(2);\nLanzar Pause(3);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Pause(label as integer)\ndiscard await requestTimer();\nwrite label;\nendSubroutine\nalgorithm Main\ntasks\nspawn Pause(1);\nspawn Pause(2);\nspawn Pause(3);\nendTasks\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ],
    "grabar_y_reproducir": true,
    "orden_entrega": [
      3,
      1,
      2
    ]
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El anfitrión de memoria acepta respuestas HTTP declaradas en anfitrion.http, indexadas por método y URL. Cada respuesta declara estado y puede declarar cabeceras repetidas, cuerpo textual o bytes, fallo e incertidumbre. El proveedor de memoria nunca abre sockets ni resuelve nombres.",
  "verificacion": ["C9"]
}
```

```caso
{
  "id": "C9",
  "regla": "R6",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 2}
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\ndefine response as HttpResponse <- propagate net.send(request);\nreturn success(response.status());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/a": {"estado": 200}}
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La capacidad RedCap solo se concede cuando el anfitrión autoriza red y limita sus orígenes a los declarados. Sin permiso no se concede; una petición fuera del conjunto se rechaza antes de consultar al proveedor.",
  "verificacion": ["C10"]
}
```

```caso
{
  "id": "C10",
  "regla": "R7",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 0}
  },
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net): Escribir \"concedida\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net): write \"granted\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [],
    "requested_permissions": ["red"]
  }
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un adaptador que realiza solicitudes HTTP reales entrega las respuestas 3xx al programa sin seguirlas, no añade ni persiste cookies, no consulta proxies ambientales o del sistema y siempre valida certificados TLS. Solo el anfitrión puede añadir raíces de confianza de prueba; el programa no puede desactivar la validación.",
  "verificacion": ["revision_humana"],
  "justificacion": "Las pruebas locales validan que la configuración TLS solo representa validación obligatoria y raíces del anfitrión. El adaptador y las pruebas con certificado y proxy reales se incorporan en la batería excluida de esta iteración."
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un adaptador nativo resuelve cada host una sola vez, comprueba todas las direcciones devueltas y conecta solo a una de ese conjunto comprobado. Deniega loopback, redes privadas, enlace local, únicas locales, multidifusión, direcciones no especificadas, broadcast e IPv4 mapeadas en IPv6 que pertenezcan a esos rangos; una concesión local de prueba solo admite direcciones loopback.",
  "verificacion": ["revision_humana"],
  "justificacion": "Las pruebas unitarias cubren los rangos y la resolución única con resolvedor inyectado. La conexión fijada a una IP comprobada se integra con el transporte nativo y queda en la batería excluida de esta iteración."
}
```

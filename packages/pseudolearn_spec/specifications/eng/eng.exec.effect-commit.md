---
{
  "formato": "see/1",
  "id": "ENG.EXEC.EFFECT-COMMIT",
  "titulo": "Confirmación lógica de efectos y estado externo incierto",
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
  "resumen": "Fases de solicitud y confirmación de efectos, orden estricto de effect_seq y estado incierto.",
  "titulo_en": "Effect logical commit and uncertain external state",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-ORDER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Confirmación lógica de efectos y estado externo incierto

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda operación de efecto atraviesa exactamente dos fases en el modelo de ejecución: Requested (cuando todos los argumentos han sido evaluados y se emite la petición asignando el siguiente effect_seq monotónico) y Resolved (cuando el anfitrión o proveedor entrega el resultado). Ningún efecto asigna effect_seq antes de completar la evaluación de sus propios argumentos de izquierda a derecha.",
  "verificacion": [
    "C1",
    "C2"
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
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "estado_cinta": "reproducible",
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
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
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
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C2",
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
    "salida": "100200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "clock",
          "operation": "request_clock",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "clock",
          "operation": "clock_now",
          "outcome": "committed"
        },
        {
          "effect_seq": 3,
          "capability_kind": "clock",
          "operation": "clock_now",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir first Como Entero <- Propagar clock.Ahora();\nDefinir second Como Entero <- Propagar clock.Ahora();\nRetornar Exito(first * 1000 + second);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\ndefine first as integer <- propagate clock.now();\ndefine second as integer <- propagate clock.now();\nreturn success(first * 1000 + second);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "reloj"
    ],
    "requested_permissions": [
      "reloj"
    ],
    "clock": [
      100,
      200
    ],
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La fase Resolved produce exactamente uno de tres resultados de confirmación: Committed (completado con éxito en el anfitrión), Failed (rechazado o fallido de forma determinista antes de mutar estado externo) o Uncertain (resultado incierto tras cruzar al anfitrión en operaciones con potencial de mutación).",
  "verificacion": [
    "C3",
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
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
    "salida": "no_encontrado\ncierto\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "estado_cinta": "reproducible",
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
          "outcome": "failed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo; Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code; if problem.uncertain then write \"incierto\"; else write \"cierto\"; endIf\nendSwitch\nendAlgorithm\n"
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
    "faults": [
      {
        "operation": "file_read_text",
        "code": "no_encontrado"
      }
    ],
    "grabar_y_reproducir": true
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "interrumpido\nincierto\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "estado_cinta": "uncertain_external_state",
      "reproduccion_fallo": "replay_non_reproducible",
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
          "operation": "file_write_text",
          "outcome": "uncertain"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"escritura\");\nRetornar file.EscribirTexto(\"x\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo; Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"write\");\nreturn file.writeText(\"x\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code; if problem.uncertain then write \"incierto\"; else write \"cierto\"; endIf\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "requested_permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "files": {},
    "faults": [
      {
        "operation": "file_write_text",
        "code": "interrumpido",
        "uncertain": true
      }
    ]
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones de solo lectura jamás producen Uncertain: ante fallo externo se resuelven siempre como Failed. El resultado Uncertain marca de inmediato el estado de reproducibilidad de la cinta como UncertainExternalState, impidiendo su reproducción determinista autónoma.",
  "verificacion": [
    "C3",
    "C4"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando una expresión combina múltiples operaciones de efecto en secuencia, cada efecto solicita y resuelve su entrada antes de que el siguiente comience a evaluar sus argumentos. Los identificadores effect_seq resultantes son contiguos y respetan estrictamente el orden de evaluación.",
  "verificacion": [
    "C5"
  ]
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
    "salida": "100200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "clock",
          "operation": "request_clock",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "clock",
          "operation": "clock_now",
          "outcome": "committed"
        },
        {
          "effect_seq": 3,
          "capability_kind": "clock",
          "operation": "clock_now",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar Exito((Propagar clock.Ahora()) * 1000 + (Propagar clock.Ahora()));\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn success((propagate clock.now()) * 1000 + (propagate clock.now()));\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "reloj"
    ],
    "requested_permissions": [
      "reloj"
    ],
    "clock": [
      100,
      200
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
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
    "salida": "permiso_denegado\ncierto\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "filesystem",
          "operation": "request_directory",
          "outcome": "failed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo; Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code; if problem.uncertain then write \"incierto\"; else write \"cierto\"; endIf\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [],
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
  "id": "C7",
  "regla": "R2",
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
    "salida": "interrumpido\ncierto\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "estado_cinta": "reproducible",
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
          "operation": "file_write_text",
          "outcome": "failed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"escritura\");\nRetornar file.EscribirTexto(\"x\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo; Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"write\");\nreturn file.writeText(\"x\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code; if problem.uncertain then write \"incierto\"; else write \"cierto\"; endIf\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "requested_permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "files": {},
    "faults": [
      {
        "operation": "file_write_text",
        "code": "interrumpido",
        "uncertain": false
      }
    ],
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En las operaciones HTTP, GET y HEAD son de solo lectura y nunca producen Uncertain. POST, PUT, PATCH y DELETE tienen potencial de mutación. Un fallo antes del primer byte enviado se resuelve como Failed con Incierto falso; un fallo después de iniciar el envío y antes de recibir la respuesta completa se conserva como Uncertain con Incierto verdadero. El anfitrión registra exactamente un efecto network_send por llamada y no lo reintenta automáticamente.",
  "verificacion": ["C8", "C9", "C10"]
}
```

```caso
{
  "id": "C8",
  "regla": "R5",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "uncertain_external_state",
      "efectos": [
        {"effect_seq": 1, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 2, "capability_kind": "network", "operation": "network_send", "outcome": "uncertain"}
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/write\");\nSegun net.Enviar(request) Hacer\nExito(response): Escribir \"completado\";\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/write\");\nswitch net.send(request) do\nsuccess(response): write \"committed\";\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"POST https://fake.test/write": {"fallo": "conexion_fallida", "incierto": true}}
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "reproducible",
      "efectos": [
        {"effect_seq": 1, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 2, "capability_kind": "network", "operation": "network_send", "outcome": "failed"}
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/read-cut\")) Hacer\nExito(response): Escribir Verdadero;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/read-cut\")) do\nsuccess(response): write true;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/read-cut": {"fallo": "conexion_fallida", "incierto": false}}
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R5",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "uncertain_external_state",
      "efectos": [
        {"effect_seq": 1, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 2, "capability_kind": "network", "operation": "network_send", "outcome": "uncertain"}
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.DELETE, \"https://fake.test/delete-cut\")) Hacer\nExito(response): Escribir Falso;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.DELETE, \"https://fake.test/delete-cut\")) do\nsuccess(response): write false;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"DELETE https://fake.test/delete-cut": {"fallo": "conexion_fallida", "incierto": true}}
  }
}
```

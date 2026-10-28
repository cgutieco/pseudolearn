---
{
  "formato": "see/1",
  "id": "ENG.EXEC.MODEL",
  "titulo": "Modelo de ejecución",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Ejecución determinista y sus cinco terminaciones.",
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.IO.INPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution model",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Modelo de ejecución

```definicion
{
  "id": "D1",
  "termino": "terminaciones",
  "texto": "completed: el algoritmo principal alcanzó su cierre. failed: un diagnóstico de ejecución detuvo el programa. awaiting_input: Leer necesita un valor que el anfitrión no entregó. awaiting_effect: una operación de capacidad requiere un efecto externo que el anfitrión debe resolver mediante effect_result. cancelled: el anfitrión canceló la ejecución. limit_reached: se agotó un presupuesto del anfitrión. El bloqueo de tareas sin efecto pendiente no abandonado es failed con taskDeadlock."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda ejecución de un programa sin errores de análisis se encuentra en exactamente una de las terminaciones de D1. awaiting_input y awaiting_effect son suspensiones reanudables; completed, failed, cancelled y limit_reached son finales y no producen efectos posteriores.",
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
    "salida": "1\n2\n3\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es"
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
    "salida": "",
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nx <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C3",
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
    "salida": "",
    "terminacion": "awaiting_input"
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C4",
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
    "salida": "1\n2\n",
    "terminacion": "limit_reached",
    "limite": "sentencias"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "sentencias": 2
  }
}
```

```caso
{
  "id": "C5",
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
    "salida": "1\n2\n",
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 3
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La ejecución es determinista: el mismo programa, perfil, rigor, semilla, configuración de límites y secuencia de entradas producen la misma salida, terminación, diagnósticos y traza en cualquier plataforma.",
  "verificacion": [
    "C6",
    "P1"
  ]
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
    "salida": "42\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "21"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "todos los casos execute y trace del corpus",
    "repeticiones": 2
  },
  "propiedad": "Dos ejecuciones con la misma configuración producen observaciones idénticas.",
  "oraculo": "Comparación exacta de salida, terminación, diagnósticos y eventos entre ejecuciones.",
  "justificacion": "El ejecutor de propiedades corresponde al sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cancelación surte efecto en la siguiente entrada a sentencia o evaluación de condición o prueba de bucle. El punto cancelado no produce efectos parciales; se conservan los efectos anteriores y la terminación es cancelled sin diagnóstico. Una cancelación posterior al final no altera una ejecución terminada.",
  "verificacion": [
    "C7",
    "C8",
    "C9"
  ]
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 1
}
```

```caso
{
  "id": "C8",
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
    "salida": "1\n2\n3\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 10
}
```

## Cancelación en los casos

El campo cancelacion de un caso indica la entrada a sentencia, contada desde uno, en la que surte efecto la cancelación que pide el anfitrión.

```caso
{
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
  "programas": {
    "es": "Algoritmo P\nMientras Verdadero Hacer\nFinMientras\nFinAlgoritmo\n",
    "en": "algorithm P\nwhile true do\nendWhile\nendAlgorithm\n"
  },
  "espera": {
    "salida": "",
    "terminacion": "cancelled"
  },
  "cancelacion_prueba": 2,
  "id": "C9"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Se distingue estrictamente entre fallo controlado de efecto (que produce un valor Resultado::Error que recorre normalmente las cláusulas Diferir), trampa del programa (que finaliza con failed) y corte o terminación por el anfitrión (cancelled o limit_reached). Ante un corte del anfitrión, incluido el que ocurre mientras una operación espera en awaiting_effect, la ejecución se detiene de inmediato, la tabla de capacidades del anfitrión se libera forzosamente, la cinta de efectos se sella como Incomplete y no se ejecutan nuevos efectos de usuario dentro de Diferir.",
  "verificacion": [
    "C10",
    "C12",
    "C13"
  ]
}
```

```caso
{
  "id": "C10",
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
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 1
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La terminación awaiting_effect representa una suspensión en la que el programa espera la resolución asíncrona o desacoplada de un efecto externo por parte del anfitrión. Expone effect_seq, capability_kind, operation, arguments_summary y source_node_id; cuando varias tareas esperan efectos a la vez, los pendientes se listan además en orden de effect_seq y, con un solo pendiente, la forma es la de un efecto único. Es estrictamente distinta de awaiting_input y solo puede ser reanudada mediante la operación effect_result. Si el anfitrión se desconecta o cancela la ejecución mientras espera en awaiting_effect, la sesión termina con cancelled sin esperar effect_result ni ejecutar nuevos efectos en Diferir, sella la cinta como Incomplete, deja el efecto pendiente en estado requested y rechaza cualquier effect_result posterior como error de uso. La reproducción desde cinta y la búsqueda histórica resuelven todo efecto desde la cinta y nunca producen awaiting_effect. La ausencia de tareas ejecutables solo es awaiting_effect si quedan efectos no abandonados capaces de reanudar una tarea viva; en otro caso es failed con taskDeadlock y sitios de suspensión relacionados por identidad de tarea.",
  "verificacion": [
    "C11",
    "C14",
    "C15"
  ]
}
```

```caso
{
  "id": "C11",
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
    "salida": "",
    "terminacion": "awaiting_effect",
    "efecto_pendiente": {
      "effect_seq": 1,
      "capability_kind": "clock",
      "operation": "request_clock"
    },
    "anfitrion_observado": {
      "llamadas": 0,
      "recursos_abiertos": 0,
      "estado_cinta": "incomplete",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "clock",
          "operation": "request_clock",
          "outcome": "requested"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "reloj"
    ],
    "requested_permissions": [
      "reloj"
    ],
    "detached": true
  }
}
```

```caso
{
  "id": "C12",
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
    "terminacion": "limit_reached",
    "limite": "sentencias",
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
  "limites": {
    "sentencias": 40
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
  "cancelacion": 40
}
```

```caso
{
  "id": "C14",
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
  "operacion": "api",
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDiferir\nDescartar directory.Abrir(\"cleanup\", \"lectura\");\nFinDiferir\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar Exito(1);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefer\ndiscard directory.open(\"cleanup\", \"read\");\nendDefer\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn success(1);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "api": {
    "calls": [
      {
        "operation": "create_analysis"
      },
      {
        "operation": "start",
        "resource_from": 0,
        "arguments": {
          "host": {
            "permissions": [
              "archivos_lectura"
            ],
            "requested_permissions": [
              "archivos_lectura"
            ],
            "detached": true
          }
        }
      },
      {
        "operation": "advance",
        "resource_from": 1,
        "arguments": {
          "batch_size": 64
        }
      },
      {
        "operation": "effect_result",
        "resource_from": 1,
        "arguments": {
          "effect_seq": 1,
          "result": {
            "outcome": "committed",
            "value": {
              "kind": "capability",
              "value": {
                "slot": 0,
                "generation": 1,
                "rights": 1,
                "kind": 2
              }
            }
          }
        }
      },
      {
        "operation": "advance",
        "resource_from": 1,
        "arguments": {
          "batch_size": 64
        }
      },
      {
        "operation": "cancel",
        "resource_from": 1
      },
      {
        "operation": "advance",
        "resource_from": 1,
        "arguments": {
          "batch_size": 64
        }
      },
      {
        "operation": "effect_result",
        "resource_from": 1,
        "arguments": {
          "effect_seq": 2,
          "result": {
            "outcome": "committed",
            "value": {
              "kind": "capability",
              "value": {
                "slot": 1,
                "generation": 1,
                "rights": 1,
                "kind": 3
              }
            }
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {}
        },
        {
          "value": {}
        },
        {
          "value": {
            "termination": {
              "kind": "awaiting_effect",
              "effect_seq": 1,
              "capability_kind": "filesystem",
              "operation": "request_directory"
            }
          }
        },
        {
          "value": null
        },
        {
          "value": {
            "termination": {
              "kind": "awaiting_effect",
              "effect_seq": 2,
              "capability_kind": "filesystem",
              "operation": "file_open"
            }
          }
        },
        {
          "value": null
        },
        {
          "value": {
            "termination": {
              "kind": "cancelled"
            },
            "effect_tape": {
              "status": "incomplete",
              "entries": [
                {
                  "effect_seq": 1,
                  "operation": "request_directory",
                  "outcome": "committed"
                },
                {
                  "effect_seq": 2,
                  "operation": "file_open",
                  "outcome": "requested"
                }
              ]
            },
            "host_observation": {
              "open_resources": 0
            }
          }
        },
        {
          "failure": {
            "family": "usage"
          }
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C15",
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
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nSegun Aguardar stream.Recibir() Hacer\nNada: Escribir 0;\nAlgo(value): Escribir value;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine stream as channel<integer> <- channel(1);\nswitch await stream.receive() do\nnone: write 0;\nsome(value): write value;\nendSwitch\nendAlgorithm\n"
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

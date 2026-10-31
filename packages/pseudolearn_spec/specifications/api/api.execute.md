---
{
  "formato": "see/1",
  "id": "API.EXECUTE",
  "titulo": "Ejecución",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Iniciar, avanzar por lotes o hasta una condición, entregar entrada, cancelar y posicionarse.",
  "depende_de": [
    {
      "id": "API.ANALYZE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.STEP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Execution",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Ejecución

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Iniciar una ejecución recibe un análisis sin errores, semilla, límites y entradas iniciales; iniciar desde un análisis con errores devuelve un error de uso.",
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

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Avanzar entrega lotes de eventos de un tamaño máximo o avanza hasta una condición de ENG.TRACE.STEP; cada respuesta indica si la ejecución sigue, espera entrada o terminó.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
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
  "operacion": "trace",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "output",
        "linea": 2,
        "datos": {
          "texto": "1\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 2
      },
      {
        "clase": "statement_entered",
        "linea": 3
      },
      {
        "clase": "output",
        "linea": 3,
        "datos": {
          "texto": "2\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Entregar entrada reanuda una ejecución que espera; cancelar la termina en la siguiente entrada a sentencia o evaluación de condición o prueba de bucle con cancelled, sin efectos parciales del punto cancelado.",
  "verificacion": [
    "C3"
  ]
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
    "salida": "1\n",
    "terminacion": "cancelled"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "cancelacion": 2
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Con la capacidad seek, la ejecución puede posicionarse en un evento pasado para consultar su estado; posicionarse no repite efectos externos ni cambia la continuación.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R4",
  "generador": {
    "programas": "casos trace del corpus",
    "posiciones": "cada evento"
  },
  "propiedad": "Posicionarse en k y continuar produce los mismos eventos posteriores que no haberse posicionado, sin repetir salida.",
  "oraculo": "Traza completa sin posicionamiento.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API distingue tres modos de ejecución mutuamente excluyentes: LiveRecord (ejecuta contra el anfitrión y graba la cinta de efectos), ReplayFromTape (reproduce fielmente a partir de la cinta sin consultar al anfitrión) y HistorySeek (reconstruye estados pasados para inspección interactiva desconectado del anfitrión). En ReplayFromTape y HistorySeek el aislamiento externo es absoluto: ninguna llamada a disco, red ni reloj real es realizada.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
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
    "salida": "holamundo\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir second Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nDefinir left Como Cadena <- Propagar file.LeerTexto();\nDefinir right Como Cadena <- Propagar second.LeerTexto();\nRetornar Exito(left + right);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine second as FileCap <- propagate directory.open(\"b\", \"read\");\ndefine left as string <- propagate file.readText();\ndefine right as string <- propagate second.readText();\nreturn success(left + right);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola",
      "b": "mundo"
    },
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API proyecta la terminación awaiting_effect con su efecto pendiente (y, cuando hay más de uno, la lista pending_effects con todos en orden de effect_seq, cada uno con su task_id) y proporciona la operación effect_result para reanudar la ejecución con el resultado entregado por el anfitrión. Enviar input cuando se espera effect_result o effect_result cuando se espera input produce un error de uso.",
  "verificacion": [
    "C5",
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R6",
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
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nDefinir Mutable offset Como Entero <- 0;\nLeer offset;\nSegun Probe() Hacer\nExito(value): Escribir value + offset;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\ndefine mutable offset as integer <- 0;\nread offset;\nswitch Probe() do\nsuccess(value): write value + offset;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
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
              "reloj"
            ],
            "requested_permissions": [
              "reloj"
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
        "operation": "input",
        "resource_from": 1,
        "arguments": {
          "text": "25"
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
          "effect_seq": 2,
          "result": {
            "outcome": "committed",
            "value": {
              "kind": "capability",
              "value": {
                "slot": 0,
                "generation": 1,
                "rights": 4,
                "kind": 4
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
        "operation": "effect_result",
        "resource_from": 1,
        "arguments": {
          "effect_seq": 3,
          "result": {
            "outcome": "committed",
            "value": {
              "kind": "integer",
              "value": 100
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
              "kind": "awaiting_input"
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
              "capability_kind": "clock",
              "operation": "request_clock"
            },
            "pending_effect": {
              "effect_seq": 2,
              "operation": "request_clock"
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
              "effect_seq": 3,
              "capability_kind": "clock",
              "operation": "clock_now"
            },
            "pending_effect": {
              "effect_seq": 3,
              "operation": "clock_now"
            }
          }
        },
        {
          "value": null
        },
        {
          "value": {
            "output": "125\n",
            "termination": {
              "kind": "completed"
            },
            "effect_tape": {
              "status": "reproducible"
            }
          }
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R6",
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
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo; Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code; if problem.uncertain then write \"incierto\"; else write \"cierto\"; endIf\nendSwitch\nendAlgorithm\n"
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
              "reloj"
            ],
            "requested_permissions": [
              "reloj"
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
                "rights": 4,
                "kind": 4
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
        "operation": "effect_result",
        "resource_from": 1,
        "arguments": {
          "effect_seq": 2,
          "result": {
            "outcome": "failed",
            "value": {
              "code": "tiempo_agotado",
              "uncertain": false
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
              "capability_kind": "clock",
              "operation": "request_clock"
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
              "capability_kind": "clock",
              "operation": "clock_now"
            }
          }
        },
        {
          "value": null
        },
        {
          "value": {
            "output": "tiempo_agotado\ncierto\n",
            "termination": {
              "kind": "completed"
            },
            "effect_tape": {
              "status": "reproducible",
              "entries": [
                {
                  "effect_seq": 1,
                  "operation": "request_clock",
                  "outcome": "committed"
                },
                {
                  "effect_seq": 2,
                  "operation": "clock_now",
                  "outcome": "failed"
                },
                {
                  "effect_seq": 3,
                  "operation": "write",
                  "outcome": "committed"
                },
                {
                  "effect_seq": 4,
                  "operation": "write",
                  "outcome": "committed"
                }
              ]
            }
          }
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R6",
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
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nDefinir Mutable pending Como Entero <- 0;\nLeer pending;\nSegun Probe() Hacer\nExito(value): Escribir value + pending;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\ndefine mutable pending as integer <- 0;\nread pending;\nswitch Probe() do\nsuccess(value): write value + pending;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
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
              "reloj"
            ],
            "requested_permissions": [
              "reloj"
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
                "rights": 4,
                "kind": 4
              }
            }
          }
        }
      },
      {
        "operation": "input",
        "resource_from": 1,
        "arguments": {
          "text": "10"
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
        "operation": "input",
        "resource_from": 1,
        "arguments": {
          "text": "20"
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
              "kind": "awaiting_input"
            }
          }
        },
        {
          "failure": {
            "family": "usage"
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
              "capability_kind": "clock",
              "operation": "request_clock"
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

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El control de depuración conserva el mismo recurso de ejecución. debug_configure recibe resource, breakpoints con source_id, line y column opcional, y stop_on_entry; devuelve breakpoints resueltos con verified y stop_generation. debug_control recibe resource, command continue, next, step_in, step_out, step_back o pause y task_id opcional; configura el predicado que advance bombea por lotes y devuelve el estado de depuración. No recompila ni inicia otra ejecución. Entry, breakpoint, next y step_in paran en statement_entered antes de sus efectos; step_out para en el return del marco seleccionado. La selección de tarea no altera la agenda. pause conserva el evento confirmado, las esperas y la continuación sin cancelar. Una orden inválida o concurrente devuelve uso sin avanzar.",
  "verificacion": [
    "C8",
    "C9",
    "C10"
  ]
}
```

```caso
{
  "id": "C8",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "create_analysis",
        "arguments": {}
      },
      {
        "operation": "start",
        "arguments": {
          "observe": "events",
          "seed": 42
        },
        "resource_from": 0
      },
      {
        "operation": "debug_configure",
        "arguments": {
          "breakpoints": [],
          "stop_on_entry": true
        },
        "resource_from": 1
      },
      {
        "operation": "debug_control",
        "arguments": {
          "command": "continue"
        },
        "resource_from": 1
      },
      {
        "operation": "advance",
        "arguments": {
          "batch_size": 64
        },
        "resource_from": 1
      },
      {
        "operation": "debug_state",
        "arguments": {},
        "resource_from": 1
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
            "breakpoints": []
          }
        },
        {
          "value": {}
        },
        {
          "value": {}
        },
        {
          "value": {
            "stopped": true,
            "reason": "entry",
            "output": ""
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ],
  "programa": "Algoritmo P\nDefinir Mutable total Como Entero <- 20;\ntotal <- total + 22;\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C9",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "create_analysis",
        "arguments": {}
      },
      {
        "operation": "start",
        "arguments": {
          "observe": "events",
          "seed": 42
        },
        "resource_from": 0
      },
      {
        "operation": "debug_configure",
        "arguments": {
          "breakpoints": [],
          "stop_on_entry": true
        },
        "resource_from": 1
      },
      {
        "operation": "debug_control",
        "arguments": {
          "command": "invalid"
        },
        "resource_from": 1
      },
      {
        "operation": "debug_control",
        "arguments": {
          "command": "pause"
        },
        "resource_from": 1
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
            "breakpoints": []
          }
        },
        {
          "failure": {
            "family": "usage"
          }
        },
        {
          "value": {
            "stopped": true
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ],
  "programa": "Algoritmo P\nDefinir Mutable total Como Entero <- 20;\ntotal <- total + 22;\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C10",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "debug_control",
        "arguments": {
          "resource": 0,
          "command": "continue"
        }
      },
      {
        "operation": "debug_configure",
        "arguments": {
          "resource": 0,
          "breakpoints": []
        }
      },
      {
        "operation": "debug_state",
        "arguments": {
          "resource": 0
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "failure": {
            "family": "usage"
          }
        },
        {
          "failure": {
            "family": "usage"
          }
        },
        {
          "failure": {
            "family": "usage"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "history_events recibe resource, start, count y direction opcional forward o backward y devuelve una ventana acotada de eventos retenidos, su horizonte y posición. count está entre cero y 4096; una posición anterior al horizonte, futura o una dirección inválida devuelve uso, sin aproximación. El cursor de inspección es independiente de la punta viva. Consultar, retroceder y volver a la punta conserva salida emitida, cinta, agenda y continuación; avanzar después de inspeccionar no repite efectos físicos ni reenvía salida histórica.",
  "verificacion": [
    "C11",
    "C12"
  ]
}
```

```caso
{
  "id": "C11",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "create_analysis",
        "arguments": {}
      },
      {
        "operation": "start",
        "arguments": {
          "observe": "events",
          "seed": 42
        },
        "resource_from": 0
      },
      {
        "operation": "advance",
        "arguments": {
          "batch_size": 8
        },
        "resource_from": 1
      },
      {
        "operation": "history_events",
        "arguments": {
          "start": 0,
          "count": 0
        },
        "resource_from": 1
      },
      {
        "operation": "history_events",
        "arguments": {
          "start": 0,
          "count": 4097
        },
        "resource_from": 1
      },
      {
        "operation": "history_events",
        "arguments": {
          "start": 0,
          "count": 1,
          "direction": "sideways"
        },
        "resource_from": 1
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
          "value": {}
        },
        {
          "value": {
            "events": []
          }
        },
        {
          "failure": {
            "family": "usage"
          }
        },
        {
          "failure": {
            "family": "usage"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ],
  "programa": "Algoritmo P\nDefinir Mutable total Como Entero <- 20;\ntotal <- total + 22;\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C12",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "history_events",
        "arguments": {
          "resource": 0,
          "start": 0,
          "count": 1
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "failure": {
            "family": "usage"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

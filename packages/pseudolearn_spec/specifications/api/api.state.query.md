---
{
  "formato": "see/1",
  "id": "API.STATE.QUERY",
  "titulo": "Consulta de estado",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Consulta por referencia y por instante con horizonte declarado.",
  "depende_de": [
    {
      "id": "API.EXECUTE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.STATE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "State query"
}
---

# Consulta de estado

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El estado se consulta por referencia: la lista de marcos, las variables de un marco, un objeto por identidad y un intervalo de celdas de un arreglo por desplazamiento y cantidad, sin materializar el estado completo.",
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "estado_en": {
      "evento": 3,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {
              "a": {
                "ref": 1
              }
            }
          }
        ],
        "objetos": {
          "1": {
            "arreglo": {
              "dimensiones": [
                2
              ],
              "celdas": [
                {
                  "valor": "5"
                },
                {
                  "sin_valor": true
                }
              ]
            }
          }
        }
      }
    }
  },
  "programa": "Algoritmo P\nDimension a[2] Como Entero;\na[0] <- 5;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda consulta indica el instante como índice de evento; con seek puede ser un evento pasado y sin seek solo el actual.",
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
    "salida": "3\n",
    "terminacion": "completed",
    "estado_en": {
      "evento": 1,
      "estado": {
        "marcos": [
          {
            "unidad": "P",
            "variables": {}
          }
        ],
        "objetos": {
          "1": {
            "arreglo": {
              "dimensiones": [
                1
              ],
              "celdas": [
                {
                  "sin_valor": true
                }
              ]
            }
          }
        }
      }
    }
  },
  "programa": "Algoritmo P\nDimension a[1] Como Entero;\na[0] <- 3;\nEscribir a[0];\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La ejecución declara su horizonte retenido: el primer evento consultable. Consultar un evento anterior al horizonte devuelve un error de uso, nunca un estado aproximado.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "ejecuciones": "ejecuciones largas con presupuesto de retención pequeño"
  },
  "propiedad": "Toda consulta dentro del horizonte es exacta y fuera de él es un error de uso.",
  "oraculo": "Estado completo registrado.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un sujeto que anuncia state_pages acepta una consulta paginada con consulta, evento, tamaño de página y cursor opcional. Devuelve los elementos, un indicador de truncamiento y un cursor opaco cuando quedan elementos. El cursor queda ligado a la sesión, documento y revisión, ejecución, consulta, evento y tamaño de página que lo originaron. Usarlo con otra identidad, revisión, ejecución, consulta, evento o tamaño devuelve un error de uso y no cambia la ejecución.",
  "verificacion": ["C4", "C5", "C6", "C7"]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "estado_en": {
      "evento": 1,
      "estado": {
        "elements": [
          {
            "sin_valor": true
          },
          {
            "sin_valor": true
          }
        ],
        "truncated": true,
        "next_cursor": "opaque"
      }
    }
  },
  "paginacion": {
    "query": "array_cells",
    "target": 1,
    "event": 1,
    "page_size": 2,
    "cursor": null
  },
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "fallo": {
      "codigo": "usage"
    },
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "paginacion": {
    "query": "array_cells",
    "target": 1,
    "event": 1,
    "page_size": 2,
    "cursor": "cursor_from_event_2"
  },
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "fallo": {
      "codigo": "usage"
    },
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "paginacion": {
    "query": "array_cells",
    "target": 0,
    "event": 1,
    "page_size": 2,
    "cursor": null
  },
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "fallo": {
      "codigo": "usage"
    },
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "paginacion": {
    "query": "array_cells",
    "target": 1,
    "event": 3,
    "page_size": 2,
    "cursor": null
  },
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las consultas de estado retrospectivas y el reposicionamiento seek en modo HistorySeek reconstruyen estados intermedios exclusivamente a partir de los puntos de control y la cinta de efectos grabada, sin reejecutar llamadas de entrada y salida ni consultar al anfitrión.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2
    },
    "estado_en": {
      "evento": 11,
      "estado": {
        "marcos": [
          {
            "unidad": "Main",
            "variables": {
              "total": {
                "valor": "0"
              }
            }
          }
        ],
        "objetos": {}
      }
    }
  },
  "programa": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nDefinir Mutable total Como Entero <- 0;\nSegun Probe() Hacer\nExito(value): total <- value;\nError(problem): total <- 0 - 1;\nFinSegun\nFinAlgoritmo\n",
  "perfil_base": "es",
  "anfitrion": {
    "permissions": [
      "reloj"
    ],
    "requested_permissions": [
      "reloj"
    ],
    "clock": [
      100
    ]
  }
}
```

## Colecciones e interfaces

Una colección se conserva como referencia con identidad compartida. Su entrada de heap describe vector con longitud y elementos, o diccionario con longitud y entradas en inserción, cada una con clave y valor. Las hojas de registros se presentan por campo y las funciones conservan su marcador. La observación no cambia capacidad ni versión. Los metadatos internos de disposición no se proyectan como campos de objetos ordinarios.

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando el programa tiene tareas además de la raíz, el estado en un evento incluye tareas con un resumen de todas ellas en orden de identidad: tarea, padre (nulo para la raíz), estado (ready, running, waiting, cancel_requested, cleaning, completed, failed o cancelled), causa y objetivo de la espera (nulos si no espera). Los marcos listan los de la tarea en ejecución y la unidad de entrada de una tarea hija se nombra task: seguido de la unidad lanzada. El estado de un programa sin tareas no incluye tareas. El estado refleja el instante posterior a la instrucción que produjo el evento.",
  "verificacion": [
    "C9"
  ]
}
```

```caso
{
  "id": "C9",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed",
    "estado_en": {
      "evento": 10,
      "estado": {
        "marcos": [
          {
            "unidad": "task:Take",
            "variables": {}
          }
        ],
        "objetos": {},
        "tareas": [
          {
            "tarea": 0,
            "padre": null,
            "estado": "waiting",
            "causa": "join",
            "objetivo": 0
          },
          {
            "tarea": 1,
            "padre": 0,
            "estado": "running",
            "causa": null,
            "objetivo": null
          }
        ]
      }
    }
  },
  "programa": "SubProceso Suspendible Take(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Take(stream);\nAguardar stream.Enviar(7);\nFinTareas\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "query_frame y query_variables admiten task opcional para consultar el contexto de una tarea activa o suspendida en event sin activarla ni cambiar la agenda. query_page añade task a la identidad de su cursor y conserva el límite de 4096 elementos. La tarea raíz conserva identidad cero. Un identificador desconocido, un marco ajeno o un cursor de otro stop, tarea, sesión o revisión devuelve uso. Las páginas de variables, campos y colecciones se leen por rango sin materializar el conjunto entero.",
  "verificacion": [
    "C10",
    "C11"
  ]
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
          "batch_size": 1
        },
        "resource_from": 1
      },
      {
        "operation": "query_frame",
        "arguments": {
          "event": 0,
          "frame": 0,
          "task": 0
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
            "unidad": "P"
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
  "id": "C11",
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
        "operation": "query_frame",
        "arguments": {
          "event": 0,
          "frame": 0,
          "task": 999
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

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "inspect_expression recibe resource, event, task_id opcional, frame y expression, sobre la revisión inmutable de la ejecución. Admite literales escalares, nombres léxicos, campos de datos, índices y operadores puros del lenguaje; rechaza llamadas, constructores ejecutables, asignación, propagación, espera, creación de tareas y capacidades. Reutiliza parser con EOF, resolución de tipos, lowering y operadores de VM existentes, sobre copia aislada sin anfitrión. Devuelve type y value como texto canónico de Rust y reference opcional. Texto mayor de 8192 bytes, más de 1024 nodos o profundidad mayor de 64 produce uso. El presupuesto temporal no supera 4096 sentencias, 64 marcos y 65536 celdas ni los límites menores del programa. Éxito, error o límite conservan variables, heap, azar, cinta, salida, agenda y continuación vivos.",
  "verificacion": [
    "C12",
    "C13",
    "C14",
    "C15"
  ]
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
          "batch_size": 2
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "task_id": 0,
          "expression": "total + 22"
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
            "type": "integer",
            "value": "42"
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
  "id": "C13",
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
          "batch_size": 2
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "expression": "Azar(10)"
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "expression": "total <- 4"
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "expression": "total 22"
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
  ],
  "programa": "Algoritmo P\nDefinir Mutable total Como Entero <- 20;\ntotal <- total + 22;\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C14",
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
          "batch_size": 2
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "expression": "9223372036854775807"
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "expression": "1 / 0"
        },
        "resource_from": 1
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "event": 1,
          "frame": 0,
          "expression": ""
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
            "type": "integer",
            "value": "9223372036854775807"
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
  "id": "C15",
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
        "operation": "inspect_expression",
        "arguments": {
          "resource": 0,
          "event": 0,
          "frame": 0,
          "expression": "1"
        }
      },
      {
        "operation": "inspect_expression",
        "arguments": {
          "resource": 0,
          "event": 0,
          "frame": 0,
          "expression": "                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 "
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
        }
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

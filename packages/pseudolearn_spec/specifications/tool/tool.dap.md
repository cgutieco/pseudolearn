---
{
  "formato": "see/1",
  "id": "TOOL.DAP",
  "titulo": "Adaptador de depuración de la VM",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Protocolo DAP de escritorio sobre un recurso vivo de VM, inspección inmutable y navegación histórica sin efectos nuevos.",
  "titulo_en": "VM debug adapter",
  "depende_de": [
    {
      "id": "API.EXECUTE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.STATE.QUERY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.ERRORS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.STEP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "cesar-antonio-gutierrez-contreras"
  ]
}
---

# Adaptador de depuración de la VM

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo dap usa stdio con cabecera Content-Length por longitud UTF-8; acepta fragmentación y conserva límites de 8192 bytes de cabecera y 8388608 bytes de cuerpo antes de reservar. Rechaza longitud duplicada, negativa, excesiva, JSON inválido y EOF incompleto sin filtrar pánico. La salida estándar contiene solo DAP.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: -1\r\n\r\n",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 1
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La secuencia es initialize, launch, initialized, configuración y configurationDone; launch permite recibir initialized sin interbloqueo. Solo se anuncian capacidades implementadas de VM. attach, escritura de variables, condiciones, logpoints, reverseContinue, restart y AOT no se anuncian. Launch recibe archivo o proyecto guardado, configuración explícita y snapshot inmutable; un estado inválido no crea otra ejecución.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 89\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{\"adapterID\":\"pseudolearn\"}}Content-Length: 64\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "setBreakpoints sustituye el conjunto de una fuente y resuelve source_id, revisión, línea y columna a una entrada ejecutable exacta. Una línea no ejecutable o sourceModified produce verified false con motivo; no traslada a otra sentencia. source entrega el texto del snapshot ejecutado cuando se usa sourceReference.",
  "verificacion": [
    "C3",
    "C13"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 123\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"p.pseudo\"},\"breakpoints\":[{\"line\":2}]}}Content-Length: 64\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "continue, next, stepIn y stepOut configuran el predicado de API.EXECUTE y bombean advance del mismo recurso; cada parada es global. next no entra en un marco más profundo de la tarea seleccionada, stepIn para en su próxima entrada y stepOut en su return. pause conserva esperas y efecto en vuelo, sin cancel. Solo hay un control activo; una petición inválida no avanza.",
  "verificacion": [
    "C4",
    "C11",
    "C15"
  ]
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
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 74\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"continue\",\"arguments\":{\"threadId\":1}}Content-Length: 64\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "continue",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "threads proyecta tareas lógicas con IDs DAP int32 positivos, incluida la raíz cero mediante tabla; no reutiliza IDs de tareas terminadas. stackTrace, scopes y variables consultan tarea, evento y generación sin cambiar la agenda. Referencias opacas de otro stop, sesión o revisión fallan; las páginas no materializan la colección entera. Las fuentes y revisiones son las del snapshot.",
  "verificacion": [
    "C5",
    "C12",
    "C14"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 78\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"stackTrace\",\"arguments\":{\"threadId\":999}}Content-Length: 64\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "stackTrace",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "evaluate usa inspect_expression del núcleo sobre marco y snapshot concreto, con el mismo subconjunto limitado sin llamadas para hover, watch y repl. No interpreta comandos ni cambia heap, azar, cinta, salida o continuación, incluso ante error. No contiene parser ni evaluador alternativo en CLI o extensión.",
  "verificacion": [
    "C6",
    "C10"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 103\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"evaluate\",\"arguments\":{\"expression\":\"Azar(10)\",\"context\":\"watch\"}}Content-Length: 64\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "evaluate",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
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
  "texto": "stepBack mueve solo el cursor de inspección al evento anterior retenido de entrada a sentencia; continue desde historia recorre eventos hasta la punta antes de producir nuevos. Ninguna consulta ni avance histórico repite output, HTTP, escrituras o reloj. Un evento anterior al horizonte o una cinta inválida falla sin reiniciar ni recurrir a LiveRecord.",
  "verificacion": [
    "C7"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 74\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"stepBack\",\"arguments\":{\"threadId\":1}}Content-Length: 64\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "stepBack",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La entrada del programa usa evento pseudolearn/awaitingInput con token opaco de sesión, generación y espera y request pseudolearn/input con token y acción de línea o cancelación. Una cadena vacía es entrada válida; token ajeno, duplicado o tardío falla sin alimentar otra espera. El REPL queda reservado a evaluación de inspección.",
  "verificacion": [
    "C8"
  ]
}
```

```caso
{
  "id": "C8",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 98\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"pseudolearn/input\",\"arguments\":{\"token\":\"foreign\",\"text\":\"\"}}Content-Length: 64\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "pseudolearn/input",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "terminate, disconnect y EOF cancelan la punta y cierran recursos, entrada y transportes propios una sola vez. Launch acepta args como lista de cadenas y cwd como carpeta de trabajo; tiene autoridad plena sin claves de permisos. Ejecutar exige Workspace Trust del editor. El proceso se crea sin shell y con binario verificado. EOF sin cierre completo se informa como terminación anormal.",
  "verificacion": [
    "C9"
  ]
}
```

```caso
{
  "id": "C9",
  "regla": "R9",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 64\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {}
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "disconnect",
          "success": true
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R6",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 100\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"launch\",\"arguments\":{\"program\":\"p.pseudo\",\"stopOnEntry\":false}}Content-Length: 123\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"p.pseudo\"},\"breakpoints\":[{\"line\":3}]}}Content-Length: 71\r\n\r\n{\"seq\":4,\"type\":\"request\",\"command\":\"configurationDone\",\"arguments\":{}}Content-Length: 76\r\n\r\n{\"seq\":5,\"type\":\"request\",\"command\":\"stackTrace\",\"arguments\":{\"threadId\":1}}Content-Length: 116\r\n\r\n{\"seq\":6,\"type\":\"request\",\"command\":\"evaluate\",\"arguments\":{\"expression\":\"total + 1\",\"frameId\":1,\"context\":\"watch\"}}Content-Length: 116\r\n\r\n{\"seq\":7,\"type\":\"request\",\"command\":\"evaluate\",\"arguments\":{\"expression\":\"total <- 9\",\"frameId\":1,\"context\":\"repl\"}}Content-Length: 64\r\n\r\n{\"seq\":8,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir Mutable total Como Entero <- 1;\ntotal <- total + 1;\nEscribir total;\nFinAlgoritmo\n"
    }
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "launch",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "line": 3,
                "verified": true
              }
            ]
          }
        },
        {
          "command": "configurationDone",
          "success": true
        },
        {
          "command": "stackTrace",
          "success": true,
          "body": {
            "stackFrames": [
              {
                "name": "P",
                "line": 3
              }
            ]
          }
        },
        {
          "command": "evaluate",
          "success": true,
          "body": {
            "result": "2",
            "type": "integer"
          }
        },
        {
          "command": "evaluate",
          "success": false
        },
        {
          "command": "disconnect",
          "success": true
        }
      ],
      "events": [
        {
          "event": "initialized"
        },
        {
          "event": "stopped",
          "body": {
            "reason": "breakpoint",
            "threadId": 1
          }
        },
        {
          "event": "terminated"
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R4",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 115\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"launch\",\"arguments\":{\"program\":\"p.pseudo\",\"profile\":\"en\",\"stopOnEntry\":false}}Content-Length: 134\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"p.pseudo\"},\"breakpoints\":[{\"line\":3},{\"line\":3}]}}Content-Length: 71\r\n\r\n{\"seq\":4,\"type\":\"request\",\"command\":\"configurationDone\",\"arguments\":{}}Content-Length: 76\r\n\r\n{\"seq\":5,\"type\":\"request\",\"command\":\"stackTrace\",\"arguments\":{\"threadId\":1}}Content-Length: 116\r\n\r\n{\"seq\":6,\"type\":\"request\",\"command\":\"evaluate\",\"arguments\":{\"expression\":\"total * 5\",\"frameId\":1,\"context\":\"hover\"}}Content-Length: 74\r\n\r\n{\"seq\":7,\"type\":\"request\",\"command\":\"continue\",\"arguments\":{\"threadId\":1}}Content-Length: 64\r\n\r\n{\"seq\":8,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {
      "p.pseudo": "algorithm P\ndefine mutable total as integer <- 1;\ntotal <- total + 1;\nwrite total;\nendAlgorithm\n"
    }
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "launch",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "line": 3,
                "verified": true
              },
              {
                "line": 3,
                "verified": true
              }
            ]
          }
        },
        {
          "command": "configurationDone",
          "success": true
        },
        {
          "command": "stackTrace",
          "success": true,
          "body": {
            "stackFrames": [
              {
                "name": "P",
                "line": 3
              }
            ]
          }
        },
        {
          "command": "evaluate",
          "success": true,
          "body": {
            "result": "5",
            "type": "integer"
          }
        },
        {
          "command": "continue",
          "success": true
        },
        {
          "command": "disconnect",
          "success": true
        }
      ],
      "events": [
        {
          "event": "initialized"
        },
        {
          "event": "stopped",
          "body": {
            "reason": "breakpoint",
            "threadId": 1
          }
        },
        {
          "event": "continued",
          "body": {
            "threadId": 1
          }
        },
        {
          "event": "output",
          "body": {
            "category": "stdout",
            "output": "2\n"
          }
        },
        {
          "event": "exited",
          "body": {
            "exitCode": 0
          }
        },
        {
          "event": "terminated"
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 112\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"launch\",\"arguments\":{\"project\":\".\",\"entry\":\"app/main\",\"stopOnEntry\":false}}Content-Length: 130\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"app/math.pseudo\"},\"breakpoints\":[{\"line\":2}]}}Content-Length: 71\r\n\r\n{\"seq\":4,\"type\":\"request\",\"command\":\"configurationDone\",\"arguments\":{}}Content-Length: 61\r\n\r\n{\"seq\":5,\"type\":\"request\",\"command\":\"threads\",\"arguments\":{}}Content-Length: 76\r\n\r\n{\"seq\":6,\"type\":\"request\",\"command\":\"stackTrace\",\"arguments\":{\"threadId\":1}}Content-Length: 74\r\n\r\n{\"seq\":7,\"type\":\"request\",\"command\":\"continue\",\"arguments\":{\"threadId\":1}}Content-Length: 64\r\n\r\n{\"seq\":8,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {
      "app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n",
      "app/main.pseudo": "Importar app.worker.Work;\nAlgoritmo Main\nDefinir number Como Entero <- 20;\nTareas\nLanzar Work(number);\nLanzar Work(number + 1);\nFinTareas\nFinAlgoritmo\n",
      "app/worker.pseudo": "Importar app.math.Double;\nPublico SubProceso Suspendible Work(number Como Entero)\nEscribir Double(number);\nFinSubProceso\n",
      "app/math.pseudo": "Publico SubProceso Double(number Como Entero) Como Entero\nRetornar number * 2;\nFinSubProceso\n"
    }
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "launch",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "line": 2,
                "verified": true
              }
            ]
          }
        },
        {
          "command": "configurationDone",
          "success": true
        },
        {
          "command": "threads",
          "success": true,
          "body": {
            "threads": [
              {
                "name": "Task 0"
              },
              {
                "name": "Task 1"
              },
              {
                "name": "Task 2"
              }
            ]
          }
        },
        {
          "command": "stackTrace",
          "success": true,
          "body": {
            "stackFrames": [
              {
                "name": "app.math.Double",
                "line": 2
              },
              {
                "name": "app.worker.Work",
                "line": 3
              },
              {
                "name": "task:app.worker.Work",
                "line": 2
              }
            ]
          }
        },
        {
          "command": "continue",
          "success": true
        },
        {
          "command": "disconnect",
          "success": true
        }
      ],
      "events": [
        {
          "event": "initialized"
        },
        {
          "event": "stopped",
          "body": {
            "reason": "breakpoint",
            "threadId": 1
          }
        },
        {
          "event": "continued",
          "body": {
            "threadId": 1
          }
        },
        {
          "event": "output",
          "body": {
            "category": "stdout",
            "output": "40\n"
          }
        },
        {
          "event": "stopped",
          "body": {
            "reason": "breakpoint",
            "threadId": 3
          }
        },
        {
          "event": "terminated"
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 100\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"launch\",\"arguments\":{\"program\":\"p.pseudo\",\"stopOnEntry\":false}}Content-Length: 145\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"p.pseudo\"},\"breakpoints\":[{\"line\":3}],\"sourceModified\":true}}Content-Length: 135\r\n\r\n{\"seq\":4,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"p.pseudo\"},\"breakpoints\":[{\"line\":99},{\"line\":5}]}}Content-Length: 71\r\n\r\n{\"seq\":5,\"type\":\"request\",\"command\":\"configurationDone\",\"arguments\":{}}Content-Length: 87\r\n\r\n{\"seq\":6,\"type\":\"request\",\"command\":\"variables\",\"arguments\":{\"variablesReference\":999}}",
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir Mutable total Como Entero <- 1;\ntotal <- total + 1;\nEscribir total;\nFinAlgoritmo\n"
    }
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "launch",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "verified": false
              }
            ]
          }
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "line": 99,
                "verified": false
              },
              {
                "line": 5,
                "verified": false
              }
            ]
          }
        },
        {
          "command": "configurationDone",
          "success": true
        },
        {
          "command": "variables",
          "success": false
        }
      ],
      "events": [
        {
          "event": "initialized"
        },
        {
          "event": "output",
          "body": {
            "category": "stdout",
            "output": "2\n"
          }
        },
        {
          "event": "exited",
          "body": {
            "exitCode": 0
          }
        },
        {
          "event": "terminated"
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 100\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"launch\",\"arguments\":{\"program\":\"p.pseudo\",\"stopOnEntry\":false}}Content-Length: 123\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"p.pseudo\"},\"breakpoints\":[{\"line\":5}]}}Content-Length: 71\r\n\r\n{\"seq\":4,\"type\":\"request\",\"command\":\"configurationDone\",\"arguments\":{}}Content-Length: 76\r\n\r\n{\"seq\":5,\"type\":\"request\",\"command\":\"stackTrace\",\"arguments\":{\"threadId\":1}}Content-Length: 71\r\n\r\n{\"seq\":6,\"type\":\"request\",\"command\":\"scopes\",\"arguments\":{\"frameId\":1}}Content-Length: 105\r\n\r\n{\"seq\":7,\"type\":\"request\",\"command\":\"variables\",\"arguments\":{\"variablesReference\":2,\"start\":1,\"count\":1}}Content-Length: 64\r\n\r\n{\"seq\":8,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir first Como Entero <- 1;\nDefinir second Como Entero <- 2;\nDefinir third Como Entero <- 3;\nEscribir first + second + third;\nFinAlgoritmo\n"
    }
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "launch",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "line": 5,
                "verified": true
              }
            ]
          }
        },
        {
          "command": "configurationDone",
          "success": true
        },
        {
          "command": "stackTrace",
          "success": true,
          "body": {
            "stackFrames": [
              {
                "name": "P",
                "line": 5
              }
            ]
          }
        },
        {
          "command": "scopes",
          "success": true,
          "body": {
            "scopes": [
              {
                "name": "Locals"
              }
            ]
          }
        },
        {
          "command": "variables",
          "success": true,
          "body": {
            "variables": [
              {
                "name": "second",
                "value": "2"
              }
            ]
          }
        },
        {
          "command": "disconnect",
          "success": true
        }
      ],
      "events": [
        {
          "event": "initialized"
        },
        {
          "event": "stopped",
          "body": {
            "reason": "breakpoint",
            "threadId": 1
          }
        },
        {
          "event": "terminated"
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "cli": {
    "argumentos": [
      "dap"
    ],
    "entorno": {},
    "entrada": "Content-Length: 64\r\n\r\n{\"seq\":1,\"type\":\"request\",\"command\":\"initialize\",\"arguments\":{}}Content-Length: 112\r\n\r\n{\"seq\":2,\"type\":\"request\",\"command\":\"launch\",\"arguments\":{\"project\":\".\",\"entry\":\"app/main\",\"stopOnEntry\":false}}Content-Length: 130\r\n\r\n{\"seq\":3,\"type\":\"request\",\"command\":\"setBreakpoints\",\"arguments\":{\"source\":{\"path\":\"app/math.pseudo\"},\"breakpoints\":[{\"line\":2}]}}Content-Length: 71\r\n\r\n{\"seq\":4,\"type\":\"request\",\"command\":\"configurationDone\",\"arguments\":{}}Content-Length: 73\r\n\r\n{\"seq\":5,\"type\":\"request\",\"command\":\"stepOut\",\"arguments\":{\"threadId\":1}}Content-Length: 76\r\n\r\n{\"seq\":6,\"type\":\"request\",\"command\":\"stackTrace\",\"arguments\":{\"threadId\":1}}Content-Length: 64\r\n\r\n{\"seq\":7,\"type\":\"request\",\"command\":\"disconnect\",\"arguments\":{}}",
    "archivos": {
      "app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n",
      "app/main.pseudo": "Importar app.worker.Work;\nAlgoritmo Main\nDefinir number Como Entero <- 20;\nTareas\nLanzar Work(number);\nLanzar Work(number + 1);\nFinTareas\nFinAlgoritmo\n",
      "app/worker.pseudo": "Importar app.math.Double;\nPublico SubProceso Suspendible Work(number Como Entero)\nEscribir Double(number);\nFinSubProceso\n",
      "app/math.pseudo": "Publico SubProceso Double(number Como Entero) Como Entero\nRetornar number * 2;\nFinSubProceso\n"
    }
  },
  "espera": {
    "codigo_salida": 0,
    "dap": {
      "responses": [
        {
          "command": "initialize",
          "success": true
        },
        {
          "command": "launch",
          "success": true
        },
        {
          "command": "setBreakpoints",
          "success": true,
          "body": {
            "breakpoints": [
              {
                "line": 2,
                "verified": true
              }
            ]
          }
        },
        {
          "command": "configurationDone",
          "success": true
        },
        {
          "command": "stepOut",
          "success": true
        },
        {
          "command": "stackTrace",
          "success": true,
          "body": {
            "stackFrames": [
              {
                "name": "app.worker.Work",
                "line": 3
              },
              {
                "name": "task:app.worker.Work",
                "line": 2
              }
            ]
          }
        },
        {
          "command": "disconnect",
          "success": true
        }
      ],
      "events": [
        {
          "event": "initialized"
        },
        {
          "event": "stopped",
          "body": {
            "reason": "breakpoint",
            "threadId": 1
          }
        },
        {
          "event": "continued",
          "body": {
            "threadId": 1
          }
        },
        {
          "event": "stopped",
          "body": {
            "reason": "step",
            "threadId": 1
          }
        },
        {
          "event": "terminated"
        }
      ]
    }
  }
}
```

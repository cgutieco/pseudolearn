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
    "C3"
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
    "C4"
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
    "C5"
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
    "C6"
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
  "texto": "terminate, disconnect y EOF cancelan la punta y cierran recursos, entrada y transportes propios una sola vez. Launch no concede permisos desde launch.json; ejecutar exige Workspace Trust y concesiones personales explícitas. El proceso se crea sin shell y con binario verificado. EOF sin cierre completo se informa como terminación anormal.",
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

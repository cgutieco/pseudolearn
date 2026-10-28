---
{
  "formato": "see/1",
  "id": "ENG.TRACE.EVENTS",
  "titulo": "Eventos observables de la ejecución",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "app"
  ],
  "resumen": "Alfabeto cerrado de eventos, su nodo fuente, sus datos y su orden.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.PROGRAM.VIEW",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Observable execution events"
}
---

# Eventos observables de la ejecución

```definicion
{
  "id": "D1",
  "termino": "traceEvents",
  "texto": "Alfabeto cerrado de clases de evento con las claves de datos admitidas por cada una. rama toma afirmativa, negativa, caso, otro o ninguna; indice es la posición desde cero de la rama elegida entre las ramas con etiquetas.",
  "valor": {
    "statement_entered": {
      "datos": []
    },
    "statement_exited": {
      "datos": []
    },
    "decision": {
      "datos": [
        "rama",
        "indice"
      ]
    },
    "call": {
      "datos": [
        "nombre"
      ]
    },
    "return": {
      "datos": [
        "nombre"
      ]
    },
    "output": {
      "datos": [
        "texto"
      ]
    },
    "input_requested": {
      "datos": []
    },
    "input_received": {
      "datos": [
        "texto"
      ]
    },
    "failure": {
      "datos": [
        "codigo"
      ]
    },
    "task_spawned": {
      "datos": [
        "task",
        "parent",
        "scope"
      ]
    },
    "task_suspended": {
      "datos": [
        "task",
        "cause",
        "target"
      ]
    },
    "task_ready": {
      "datos": [
        "task",
        "cause"
      ]
    },
    "task_resumed": {
      "datos": [
        "task"
      ]
    },
    "task_completed": {
      "datos": [
        "task",
        "outcome"
      ]
    },
    "task_cancel_requested": {
      "datos": [
        "task",
        "reason",
        "origin"
      ]
    },
    "scope_joined": {
      "datos": [
        "task",
        "outcome"
      ]
    },
    "channel_created": {
      "datos": [
        "channel",
        "capacity"
      ]
    },
    "channel_sent": {
      "datos": [
        "channel"
      ]
    },
    "channel_received": {
      "datos": [
        "channel",
        "present"
      ]
    },
    "channel_closed": {
      "datos": [
        "channel"
      ]
    },
    "effect_delivered": {
      "datos": [
        "effect_seq",
        "delivery_seq",
        "task"
      ]
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una ejecución observada produce solo eventos de las clases de D1, en el orden del alfabeto que la codificación binaria numera desde cero. No hay eventos de micro-paso ni de evaluación de subexpresiones.",
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
    "salida": "1\n",
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
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada evento lleva la línea de inicio del tramo de su nodo fuente, los datos de su clase y una referencia source con revisión, node_id y tramo de API.PROGRAM.VIEW. statement_entered y statement_exited usan la sentencia; decision, la condición o el selector; call, la expresión de llamada; return, la misma expresión de llamada; output e input_*, la sentencia Escribir o Leer; failure, la operación que falló. El identificador y el tramo pertenecen a la misma revisión que la ejecución y no se reconstruyen únicamente desde el número de línea.",
  "verificacion": [
    "C2",
    "C3",
    "C14"
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
    "salida": "4\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
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
        "clase": "input_requested",
        "linea": 3
      },
      {
        "clase": "input_received",
        "linea": 3,
        "datos": {
          "texto": "4"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_entered",
        "linea": 4
      },
      {
        "clase": "output",
        "linea": 4,
        "datos": {
          "texto": "4\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 4
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "4"
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "divisionByZero"
    },
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
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
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_entered",
        "linea": 4
      },
      {
        "clase": "failure",
        "linea": 4,
        "datos": {
          "codigo": "divisionByZero"
        }
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nx <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El orden de los eventos es total y sigue el orden de ocurrencia. statement_entered precede a todo evento de su sentencia y statement_exited los sigue cuando la sentencia termina normalmente. Una sentencia interrumpida por fallo, cancelación o límite no produce statement_exited; una sentencia suspendida por Leer lo produce al terminar tras reanudarse. failure es el último evento de una ejecución fallida.",
  "verificacion": [
    "C4"
  ]
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "awaiting_input",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
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
        "clase": "input_requested",
        "linea": 3
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sentencia compuesta produce statement_entered antes de evaluar su condición o selector y statement_exited después de terminar. Cada evaluación de la condición de Si, Mientras, Repetir o de la prueba de Para produce decision con rama afirmativa si la condición es verdadera o la iteración continúa y negativa en caso contrario. Segun produce una decision con rama caso e indice, otro si ejecuta De Otro Modo o ninguna si no ejecuta ninguna rama. Elegir emite una sola decisión caso con el índice textual de la recepción ganadora; los vínculos implícitos de las ramas no añaden sentencias observables.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C15"
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
  "operacion": "trace",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "decision",
        "linea": 2,
        "datos": {
          "rama": "afirmativa"
        }
      },
      {
        "clase": "statement_entered",
        "linea": 3
      },
      {
        "clase": "output",
        "linea": 3,
        "datos": {
          "texto": "1\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "programa": "Algoritmo P\nSi 1 < 2 Entonces\nEscribir 1;\nSiNo\nEscribir 2;\nFinSi\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
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
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_entered",
        "linea": 4
      },
      {
        "clase": "decision",
        "linea": 4,
        "datos": {
          "rama": "afirmativa"
        }
      },
      {
        "clase": "statement_entered",
        "linea": 5
      },
      {
        "clase": "statement_exited",
        "linea": 5
      },
      {
        "clase": "decision",
        "linea": 4,
        "datos": {
          "rama": "negativa"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 4
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\ni <- 0;\nMientras i < 1 Hacer\ni <- i + 1;\nFinMientras\nFinAlgoritmo\n",
  "perfil_base": "es"
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
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
        "clase": "decision",
        "linea": 3,
        "datos": {
          "rama": "afirmativa"
        }
      },
      {
        "clase": "decision",
        "linea": 3,
        "datos": {
          "rama": "negativa"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable i Como Entero <- 0;\nPara i <- 1 Hasta 1 Con Paso 1 Hacer\nFinPara\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C8",
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
  "operacion": "trace",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
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
          "texto": "1\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "decision",
        "linea": 4,
        "datos": {
          "rama": "afirmativa"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "programa": "Algoritmo P\nRepetir\nEscribir 1;\nHasta Que 1 = 1\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C9",
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
  "operacion": "trace",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "decision",
        "linea": 2,
        "datos": {
          "rama": "caso",
          "indice": 1
        }
      },
      {
        "clase": "statement_entered",
        "linea": 4
      },
      {
        "clase": "output",
        "linea": 4,
        "datos": {
          "texto": "2\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 4
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "programa": "Algoritmo P\nSegun 2 Hacer\n1: Escribir 1;\n2: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
  "perfil_base": "es"
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
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "decision",
        "linea": 2,
        "datos": {
          "rama": "ninguna"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 2
      }
    ]
  },
  "programa": "Algoritmo P\nSegun 3 Hacer\n1: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Entrar en un subprograma, método o constructor declarado produce call después de evaluar los argumentos; terminar su ejecución produce return. nombre es el nombre declarado del subprograma, el de la clase seguido de punto y del método, o el de la clase para un constructor. El constructor implícito y las funciones incorporadas no producen eventos de llamada.",
  "verificacion": [
    "C11",
    "C12"
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
  "operacion": "trace",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 5
      },
      {
        "clase": "call",
        "linea": 5,
        "datos": {
          "nombre": "f"
        }
      },
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
        "clase": "return",
        "linea": 5,
        "datos": {
          "nombre": "f"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 5
      }
    ]
  },
  "programa": "SubProceso f()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C12",
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
  "operacion": "trace",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 5
      },
      {
        "clase": "call",
        "linea": 5,
        "datos": {
          "nombre": "f"
        }
      },
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "statement_exited",
        "linea": 2
      },
      {
        "clase": "return",
        "linea": 5,
        "datos": {
          "nombre": "f"
        }
      },
      {
        "clase": "output",
        "linea": 5,
        "datos": {
          "texto": "5\n"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 5
      }
    ]
  },
  "programa": "SubProceso f() Como Entero\nRetornar 5;\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada sentencia Escribir que produce texto genera un evento output cuyo texto es exactamente el producido, incluido el salto de línea; Escribir sin expresiones y con Sin Saltar no genera output. Cada valor consumido por Leer genera input_received con el texto entregado.",
  "verificacion": [
    "C13"
  ]
}
```

```caso
{
  "id": "C13",
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
  "operacion": "trace",
  "espera": {
    "salida": "{{lexema:booleanTrue}}",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
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
          "texto": "{{lexema:booleanTrue}}"
        }
      },
      {
        "clase": "statement_exited",
        "linea": 3
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir Sin Saltar;\nEscribir Verdadero Sin Saltar;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C14",
  "regla": "R2",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "eventos": [
      {"clase": "statement_entered", "linea": 2, "fuente": "nodo_programa"},
      {"clase": "output", "linea": 2, "datos": {"texto": "1\n"}, "fuente": "nodo_programa"},
      {"clase": "statement_exited", "linea": 2, "fuente": "nodo_programa"}
    ]
  },
  "programa": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C15",
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
    "es": "Algoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nstream.Cerrar();\nElegir\nRecibir first Desde stream:\nRecibir second Desde stream:\nFinElegir\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine stream as channel<integer> <- channel(1);\nstream.close();\nselect\nreceive first from stream:\nreceive second from stream:\nendSelect\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "channel_created",
        "datos": {
          "capacity": 1,
          "channel": 1
        },
        "linea": 2
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
        "clase": "channel_closed",
        "datos": {
          "channel": 1
        },
        "linea": 3
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_entered",
        "linea": 4
      },
      {
        "clase": "decision",
        "datos": {
          "indice": 0,
          "rama": "caso"
        },
        "linea": 4
      },
      {
        "clase": "statement_exited",
        "linea": 4
      }
    ]
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una ejecución observada con tareas, canales o efectos entregados emite además los eventos de tarea de D1, solo con el gemelo sondeado y sin valores de mensajes. task_spawned declara la tarea nueva, su padre y su ámbito; task_ready, la causa por la que una tarea queda lista (spawn, completion, channel, yield o resume); task_suspended, la causa (task, join, channel_send, channel_receive, select o effect) y su objetivo; task_resumed, la tarea que pasa a ejecutar; task_completed, su desenlace (success, error o cancelled); task_cancel_requested, la tarea, el motivo (sibling_failure o parent_cancelled) y la tarea de origen; scope_joined, la tarea dueña y el desenlace del ámbito (success o failure); channel_created, la identidad y la capacidad; channel_sent, channel_received (con present) y channel_closed, la identidad del canal; effect_delivered, el effect_seq entregado, su ordinal de entrega desde uno y la tarea receptora. La línea de un evento de tarea es la de la sentencia que contiene la instrucción que lo emite y, entre sentencias, la de la cabecera de la unidad en ejecución; task_suspended y task_resumed usan la instrucción que se reejecutará o ejecutará a continuación. Un programa sin tareas ni canales no emite ninguno.",
  "verificacion": [
    "C16",
    "C17",
    "C18"
  ]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La tarea dueña de un evento de las clases ordinarias es la última que recibió task_resumed y, antes de cualquier task_resumed, la tarea raíz; los eventos ordinarios no llevan la identidad de la tarea.",
  "verificacion": [
    "C16"
  ]
}
```

```caso
{
  "id": "C16",
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
    "es": "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite 1;\nendSubroutine\nalgorithm P\ntasks\nspawn Work();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 6
      },
      {
        "clase": "task_spawned",
        "datos": {
          "parent": 0,
          "scope": 0,
          "task": 1
        },
        "linea": 6
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "spawn",
          "task": 1
        },
        "linea": 6
      },
      {
        "clase": "statement_exited",
        "linea": 6
      },
      {
        "clase": "task_suspended",
        "datos": {
          "cause": "join",
          "target": 0,
          "task": 0
        },
        "linea": 5
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 1
        },
        "linea": 1
      },
      {
        "clase": "call",
        "datos": {
          "nombre": "Work"
        },
        "linea": 1
      },
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "output",
        "datos": {
          "texto": "1\n"
        },
        "linea": 2
      },
      {
        "clase": "statement_exited",
        "linea": 2
      },
      {
        "clase": "return",
        "datos": {
          "nombre": "Work"
        },
        "linea": 1
      },
      {
        "clase": "task_completed",
        "datos": {
          "outcome": "success",
          "task": 1
        },
        "linea": 1
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "completion",
          "task": 0
        },
        "linea": 1
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 0
        },
        "linea": 5
      },
      {
        "clase": "scope_joined",
        "datos": {
          "outcome": "success",
          "task": 0
        },
        "linea": 5
      }
    ]
  }
}
```

```caso
{
  "id": "C17",
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
    "es": "SubProceso Suspendible Take(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Take(stream);\nAguardar stream.Enviar(7);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Take(stream as channel<integer>)\nswitch await stream.receive() do\nsome(value): write value;\nnone: write 0;\nendSwitch\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Take(stream);\nawait stream.send(7);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 8
      },
      {
        "clase": "channel_created",
        "datos": {
          "capacity": 1,
          "channel": 1
        },
        "linea": 8
      },
      {
        "clase": "statement_exited",
        "linea": 8
      },
      {
        "clase": "statement_entered",
        "linea": 10
      },
      {
        "clase": "task_spawned",
        "datos": {
          "parent": 0,
          "scope": 0,
          "task": 1
        },
        "linea": 10
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "spawn",
          "task": 1
        },
        "linea": 10
      },
      {
        "clase": "statement_exited",
        "linea": 10
      },
      {
        "clase": "statement_entered",
        "linea": 11
      },
      {
        "clase": "channel_sent",
        "datos": {
          "channel": 1
        },
        "linea": 11
      },
      {
        "clase": "statement_exited",
        "linea": 11
      },
      {
        "clase": "task_suspended",
        "datos": {
          "cause": "join",
          "target": 0,
          "task": 0
        },
        "linea": 9
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 1
        },
        "linea": 1
      },
      {
        "clase": "call",
        "datos": {
          "nombre": "Take"
        },
        "linea": 1
      },
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "channel_received",
        "datos": {
          "channel": 1,
          "present": true
        },
        "linea": 2
      },
      {
        "clase": "decision",
        "datos": {
          "indice": 0,
          "rama": "caso"
        },
        "linea": 2
      },
      {
        "clase": "statement_entered",
        "linea": 3
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_entered",
        "linea": 3
      },
      {
        "clase": "output",
        "datos": {
          "texto": "7\n"
        },
        "linea": 3
      },
      {
        "clase": "statement_exited",
        "linea": 3
      },
      {
        "clase": "statement_exited",
        "linea": 2
      },
      {
        "clase": "return",
        "datos": {
          "nombre": "Take"
        },
        "linea": 1
      },
      {
        "clase": "task_completed",
        "datos": {
          "outcome": "success",
          "task": 1
        },
        "linea": 1
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "completion",
          "task": 0
        },
        "linea": 1
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 0
        },
        "linea": 9
      },
      {
        "clase": "scope_joined",
        "datos": {
          "outcome": "success",
          "task": 0
        },
        "linea": 9
      }
    ]
  }
}
```

```caso
{
  "id": "C18",
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
    "es": "SubProceso Suspendible Idle(stream Como Canal<Entero>)\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo P\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas problem\nLanzar Idle(stream);\nLanzar Fail();\nFinTareas\nDescartar problem;\nFinAlgoritmo\n",
    "en": "subroutine suspendable Idle(stream as channel<integer>)\nswitch await stream.receive() do\nsome(value): write value;\nnone: write 0;\nendSwitch\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"problem\");\nendSubroutine\nalgorithm P\ndefine stream as channel<integer> <- channel(1);\ntasks problem\nspawn Idle(stream);\nspawn Fail();\nendTasks\ndiscard problem;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "eventos": [
      {
        "clase": "statement_entered",
        "linea": 11
      },
      {
        "clase": "channel_created",
        "datos": {
          "capacity": 1,
          "channel": 1
        },
        "linea": 11
      },
      {
        "clase": "statement_exited",
        "linea": 11
      },
      {
        "clase": "statement_entered",
        "linea": 13
      },
      {
        "clase": "task_spawned",
        "datos": {
          "parent": 0,
          "scope": 0,
          "task": 1
        },
        "linea": 13
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "spawn",
          "task": 1
        },
        "linea": 13
      },
      {
        "clase": "statement_exited",
        "linea": 13
      },
      {
        "clase": "statement_entered",
        "linea": 14
      },
      {
        "clase": "task_spawned",
        "datos": {
          "parent": 0,
          "scope": 0,
          "task": 2
        },
        "linea": 14
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "spawn",
          "task": 2
        },
        "linea": 14
      },
      {
        "clase": "statement_exited",
        "linea": 14
      },
      {
        "clase": "task_suspended",
        "datos": {
          "cause": "join",
          "target": 0,
          "task": 0
        },
        "linea": 12
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 1
        },
        "linea": 1
      },
      {
        "clase": "call",
        "datos": {
          "nombre": "Idle"
        },
        "linea": 1
      },
      {
        "clase": "statement_entered",
        "linea": 2
      },
      {
        "clase": "task_suspended",
        "datos": {
          "cause": "channel_receive",
          "target": 1,
          "task": 1
        },
        "linea": 2
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 2
        },
        "linea": 7
      },
      {
        "clase": "call",
        "datos": {
          "nombre": "Fail"
        },
        "linea": 7
      },
      {
        "clase": "statement_entered",
        "linea": 8
      },
      {
        "clase": "statement_exited",
        "linea": 8
      },
      {
        "clase": "return",
        "datos": {
          "nombre": "Fail"
        },
        "linea": 7
      },
      {
        "clase": "task_completed",
        "datos": {
          "outcome": "error",
          "task": 2
        },
        "linea": 7
      },
      {
        "clase": "task_cancel_requested",
        "datos": {
          "origin": 2,
          "reason": "sibling_failure",
          "task": 1
        },
        "linea": 7
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 1
        },
        "linea": 2
      },
      {
        "clase": "task_completed",
        "datos": {
          "outcome": "cancelled",
          "task": 1
        },
        "linea": 2
      },
      {
        "clase": "task_ready",
        "datos": {
          "cause": "completion",
          "task": 0
        },
        "linea": 2
      },
      {
        "clase": "task_resumed",
        "datos": {
          "task": 0
        },
        "linea": 12
      },
      {
        "clase": "scope_joined",
        "datos": {
          "outcome": "failure",
          "task": 0
        },
        "linea": 12
      },
      {
        "clase": "statement_entered",
        "linea": 16
      },
      {
        "clase": "statement_exited",
        "linea": 16
      }
    ]
  }
}
```

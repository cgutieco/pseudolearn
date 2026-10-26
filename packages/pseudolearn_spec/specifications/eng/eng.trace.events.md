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
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una ejecución observada produce solo eventos de las clases de D1. No hay eventos de micro-paso ni de evaluación de subexpresiones.",
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
  "texto": "Una sentencia compuesta produce statement_entered antes de evaluar su condición o selector y statement_exited después de terminar. Cada evaluación de la condición de Si, Mientras, Repetir o de la prueba de Para produce decision con rama afirmativa si la condición es verdadera o la iteración continúa y negativa en caso contrario. Segun produce una decision con rama caso e indice, otro si ejecuta De Otro Modo o ninguna si no ejecuta ninguna rama.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10"
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

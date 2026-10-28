---
{
  "formato": "see/1",
  "id": "ENG.EXEC.EFFECT-ORDER",
  "titulo": "Orden de los efectos",
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
  "resumen": "Orden normativo de los efectos observables y primera trampa.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.STMT.ASSIGNMENT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Effect order",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Orden de los efectos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los efectos observables son la salida, la petición y el consumo de entrada, el fallo, la terminación y, cuando se observa, los eventos de traza. Ocurren en el orden de programa que fijan las reglas de evaluación del lenguaje. Ningún otro cálculo es observable salvo a través de ellos.",
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
    "salida": "1\n2\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso f(n Como Entero) Como Entero\nEscribir n;\nRetornar n;\nFinSubProceso\nAlgoritmo P\nDefinir Mutable x Como Entero <- 0;\nx <- f(1) + f(2);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si varias operaciones pueden fallar, se informa la primera trampa en orden de evaluación normativo, con el tramo de su operación, y ningún efecto posterior es visible. Una sentencia que falla no produce efectos parciales: Escribir evalúa todas sus expresiones antes de producir salida.",
  "verificacion": [
    "C2",
    "C3"
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
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "fallo": {
      "codigo": "divisionByZero"
    },
    "diagnosticos": [
      {
        "codigo": "divisionByZero",
        "severidad": "error",
        "tramo": {
          "start": {
            "line": 6,
            "column": 9
          },
          "end": {
            "line": 6,
            "column": 12
          }
        }
      }
    ]
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nDefinir Mutable z Como Entero <- 0;\nx <- 0;\nEscribir 1;\nz <- (1 div x) + (2 ^ (0 - 1));\nEscribir z;\nFinAlgoritmo\n",
  "perfil_base": "es"
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
    "salida": "",
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nx <- 0;\nEscribir \"a\", 1 div x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El orden de evaluación de subexpresiones sin efectos no es observable. Una implementación puede reordenarlas, combinarlas o comprobar sus trampas al final de una región sin efectos solo si la salida, los eventos y la primera trampa con su tramo coinciden con la evaluación normativa.",
  "verificacion": [
    "C4",
    "P1"
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
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable a Como Entero <- 0;\nDefinir Mutable b Como Entero <- 0;\na <- 9223372036854775807;\nb <- 0;\nb <- (a + 1) * (b div b);\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```propiedad
{
  "id": "P1",
  "regla": "R3",
  "generador": {
    "programas": "expresiones aritméticas generadas sin efectos con operandos en los bordes de 64 bits"
  },
  "propiedad": "Evaluar con comprobación por operación o con comprobación diferida al final de la región produce la misma primera trampa y tramo.",
  "oraculo": "Evaluación normativa de izquierda a derecha con aritmética de precisión arbitraria.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo efecto confirmado recibe un identificador secuencial effect_seq asignado en el momento exacto en que se completa la evaluación de sus argumentos y antes de emitir la petición al anfitrión. Si la evaluación de los argumentos produce una trampa, ningún effect_seq es asignado y la operación no es emitida al anfitrión.",
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
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable x Como Entero <- 0;\nEscribir 10 div x;\nFinAlgoritmo\n",
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
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "divisionByZero"
    },
    "anfitrion_observado": {
      "llamadas": 0,
      "estado_cinta": "incomplete",
      "efectos": []
    }
  },
  "programas": {
    "es": "SubProceso Probe(x Como Entero) Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(ATexto(10 div x));\nRetornar Exito(\"listo\");\nFinSubProceso\nAlgoritmo Main\nDefinir Mutable zero Como Entero <- 0;\nSegun Probe(zero) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe(x as integer) as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(toText(10 div x));\nreturn success(\"listo\");\nendSubroutine\nalgorithm Main\ndefine mutable zero as integer <- 0;\nswitch Probe(zero) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ]
  }
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
    "salida": "contenido\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 5,
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
        },
        {
          "effect_seq": 4,
          "capability_kind": "filesystem",
          "operation": "file_open",
          "outcome": "committed"
        },
        {
          "effect_seq": 5,
          "capability_kind": "filesystem",
          "operation": "file_read_text",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir pointer Como ArchivoCap <- Propagar directory.Abrir(\"nombre\", \"lectura\");\nDefinir target Como ArchivoCap <- Propagar directory.Abrir(Propagar pointer.LeerTexto(), \"lectura\");\nRetornar target.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine pointer as FileCap <- propagate directory.open(\"nombre\", \"read\");\ndefine target as FileCap <- propagate directory.open(propagate pointer.readText(), \"read\");\nreturn target.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "nombre": "destino",
      "destino": "contenido"
    },
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los efectos que piden varias tareas a la vez se numeran en orden de petición y se entregan cuando la agenda está ociosa. El anfitrión puede entregarlos en cualquier orden; cada entrega se atribuye a la tarea que pidió el efecto y las demás tareas no avanzan hasta que se entrega el resultado de una de ellas. Sin orden declarado se entregan en orden de effect_seq.",
  "verificacion": [
    "C8",
    "C9"
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
    "salida": "1\n2\n3\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "task_id": 1,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "task_id": 2,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 3
        },
        {
          "effect_seq": 3,
          "task_id": 3,
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
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C9",
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
    "salida": "2\n1\n3\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 2,
          "task_id": 2,
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
          "effect_seq": 3,
          "task_id": 3,
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
      2,
      1,
      3
    ]
  }
}
```

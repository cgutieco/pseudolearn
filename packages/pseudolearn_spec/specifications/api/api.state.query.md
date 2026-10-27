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
                "valor": "100"
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

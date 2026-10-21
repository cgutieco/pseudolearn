---
{
  "formato": "see/1",
  "id": "API.STATE.QUERY",
  "titulo": "Consulta de estado",
  "dominio": "motor",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
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
  "titulo_en": "State query",
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica por autorización y no se añaden construcciones.",
    "impacto_implementaciones": "Consulta del arreglo real sin inicializar; cursor inválido aislado de errores de destino y evento, con negativos independientes.",
    "justificacion": "Migración autorizada; la evidencia histórica, AOT y de plataforma conserva sus límites.",
    "revisado_por": "revision-independiente-automatizada"
  },
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
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
            "variables": {
              "x": {
                "sin_valor": true
              }
            }
          }
        ],
        "objetos": {}
      }
    }
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nx <- 3;\nEscribir x;\nFinAlgoritmo\n",
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
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {"estado_en": {"evento": 1, "estado": {"elements": [{"sin_valor": true}, {"sin_valor": true}], "truncated": true, "next_cursor": "opaque"}}},
  "paginacion": {"query": "array_cells", "target": 1, "event": 1, "page_size": 2, "cursor": null},
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {
    "fallo": {"codigo": "usage"},
    "eventos": [
      {"clase": "statement_entered", "linea": 2},
      {"clase": "statement_exited", "linea": 2}
    ]
  },
  "paginacion": {"query": "array_cells", "target": 1, "event": 1, "page_size": 2, "cursor": "cursor_from_event_2"},
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {"fallo": {"codigo": "usage"}, "eventos": [{"clase": "statement_entered", "linea": 2}, {"clase": "statement_exited", "linea": 2}]},
  "paginacion": {"query": "array_cells", "target": 0, "event": 1, "page_size": 2, "cursor": null},
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "trace",
  "espera": {"fallo": {"codigo": "usage"}, "eventos": [{"clase": "statement_entered", "linea": 2}, {"clase": "statement_exited", "linea": 2}]},
  "paginacion": {"query": "array_cells", "target": 1, "event": 3, "page_size": 2, "cursor": null},
  "programa": "Algoritmo P\nDimension a[5] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

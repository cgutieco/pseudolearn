---
{
  "formato": "see/1",
  "id": "API.WIRE-FORMAT",
  "titulo": "Formato de intercambio",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "cli",
    "engine",
    "app"
  ],
  "resumen": "Un esquema con JSON canónico y lotes binarios columnares.",
  "depende_de": [
    {
      "id": "API.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.TRACE.EVENTS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Wire format",
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Formato de intercambio

```definicion
{
  "id": "D1",
  "termino": "esquema de intercambio",
  "texto": "Claves ASCII en inglés y snake_case, independientes del idioma de interfaz. Diagnóstico: code, class, severity, span {start, end, source?} con line y column, related y arguments. Resultado de análisis: tree y diagnostics. Resultado de ejecución: output, termination {kind, code, limit}, diagnostics y events. Evento: class, line, data y source opcional; source contiene revisión, identificador opaco de nodo, tramo y, si está disponible, identity {project_id, revision_id, source_id}; source es null para un evento sintético. Los u64 de identity se codifican como cadenas decimales canónicas y source_id como u32. Las mismas formas son las respuestas de see-protocol/1."
}
```

```definicion
{
  "id": "D2",
  "termino": "lote binario de eventos",
  "texto": "Encabezado de 16 bytes: firma ASCII PLEV, versión u16 igual a 1 o 2, reservado u16 igual a 0 y número de eventos n como u64. Siguen cuatro columnas de n elementos en little endian: clase u8 (posición desde cero de la clase en el alfabeto de ENG.TRACE.EVENTS, que incluye los eventos de tarea), línea u32, profundidad de marco u32 y desplazamiento u32 en el pool. El pool final contiene, precedido por su longitud total u32, un objeto JSON canónico UTF-8 por evento con las claves data y source; source es null para un evento sintético y contiene revisión, node_id y tramo para un evento originado por el programa. La versión 2 puede añadir identity {project_id, revision_id, source_id} a source; la versión 1 conserva su significado y no admite ese campo. Los desplazamientos apuntan al inicio de cada objeto y las claves se ordenan por puntos de código."
}
```

```definicion
{
  "id": "D3",
  "termino": "valores enteros de 64 bits en JSON",
  "texto": "Los enteros con tipo i64 o u64 se codifican como cadenas decimales ASCII con signo menos solo para negativos, sin ceros iniciales salvo el cero y sin representación de menos cero. Los demás enteros se codifican como números JSON decimales exactos. Un consumidor no convierte una cadena i64 o u64 a un número IEEE 754 de doble precisión."
}
```

```definicion
{
  "id": "D4",
  "termino": "propiedad de los lotes y texto",
  "texto": "Las cadenas conservan sus escalares Unicode sin normalización y se codifican como UTF-8. Un lote binario es una respuesta propia e inmutable hasta que el consumidor la descarta. Un envoltorio Wasm copia los bytes necesarios antes de la siguiente llamada que pueda crecer la memoria; ninguna vista prestada de memoria Wasm sobrevive a esa llamada."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El JSON canónico es UTF-8, sin espacios entre símbolos y con las claves de cada objeto ordenadas por puntos de código. Los enteros i64 y u64 siguen D3 y el resto de números enteros se escribe en decimal exacto. Las cadenas preservan los escalares y bytes UTF-8 del texto fuente sin normalización.",
  "verificacion": [
    "C1",
    "C2",
    "C4"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {
      "wire_response": "{\"kind\":\"document\",\"id\":\"9007199254740993\"}",
      "source": "Algoritmo P\nEscribir \"é🧩\";\nFinAlgoritmo\n"
    }
  },
  "espera": {
    "aplicacion": {
      "decoded_id": "9007199254740993",
      "source_equal": true,
      "source_utf8_hex": "416c676f7269746d6f20500a4573637269626972202265cc81f09fa7a9223b0a46696e416c676f7269746d6f0a"
    }
  },
  "sujetos": [
    "app"
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
  "espera": {
    "codigo_salida": 1,
    "json": {
      "files": [
        {
          "path": "p.pseudo",
          "diagnostics": [
            {
              "code": "undeclaredVariable",
              "class": "semantic",
              "severity": "error",
              "span": {
                "start": {
                  "line": 2,
                  "column": 10
                },
                "end": {
                  "line": 2,
                  "column": 15
                }
              },
              "related": [],
              "arguments": {
                "lexeme": "total"
              }
            }
          ]
        }
      ]
    },
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--json",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  },
  "sujetos": [
    "cli"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
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
        "arguments": {
          "program": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict",
          "source": {
            "project_id": "7",
            "revision_id": "11",
            "source_id": 2
          }
        }
      },
      {
        "operation": "analysis",
        "resource_from": 0,
        "arguments": {}
      },
      {
        "operation": "create_analysis",
        "arguments": {
          "program": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict",
          "source": {
            "project_id": "7",
            "revision_id": "11",
            "source_id": 3
          }
        }
      },
      {
        "operation": "analysis",
        "resource_from": 2,
        "arguments": {}
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
          "value": {
            "diagnostics": [
              {
                "span": {
                  "start": {
                    "line": 2,
                    "column": 10
                  },
                  "end": {
                    "line": 2,
                    "column": 11
                  },
                  "source": {
                    "project_id": "7",
                    "revision_id": "11",
                    "source_id": 2
                  }
                }
              }
            ]
          }
        },
        {
          "value": {}
        },
        {
          "value": {
            "diagnostics": [
              {
                "span": {
                  "start": {
                    "line": 2,
                    "column": 10
                  },
                  "end": {
                    "line": 2,
                    "column": 11
                  },
                  "source": {
                    "project_id": "7",
                    "revision_id": "11",
                    "source_id": 3
                  }
                }
              }
            ]
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
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los lotes de eventos se codifican en el binario columnar de D2. Decodificar un lote binario produce los mismos eventos, incluidos datos y fuente, que su codificación JSON; codificar y decodificar en cualquiera de las dos formas devuelve el valor original.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "lotes": "trazas de los casos trace del corpus partidas en lotes"
  },
  "propiedad": "decodificar(codificar(x)) = x en las dos codificaciones y las dos decodificaciones coinciden.",
  "oraculo": "Igualdad estructural de los eventos.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las peticiones admiten una identidad de fuente opcional con project_id y revision_id como cadenas decimales u64 canónicas y source_id como u32 positivo. El valor cero se reserva al documento suelto. Cuando una respuesta localiza un tramo, source identifica exactamente el proyecto, revisión y archivo de ese tramo; los nombres visibles no sustituyen la identidad. Una identidad incompleta o con un componente fuera de rango devuelve un error de uso.",
  "verificacion": ["C5"]
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "create_analysis",
        "arguments": {
          "program": "",
          "profile": "es",
          "strictness": "strict",
          "source": {
            "project_id": "7",
            "revision_id": "0",
            "source_id": 2
          }
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
    "engine",
    "app"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los bytes de una respuesta binaria no dependen de la vida de la sesión después de que el transporte los entrega. El consumidor puede conservar o descartar la respuesta; el emisor puede reutilizar su almacenamiento solo después de completar esa entrega. En Wasm, el adaptador copia cualquier segmento necesario antes de una operación que pueda crecer la memoria lineal.",
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
  "operacion": "app",
  "aplicacion": {
    "scenario": "boundary",
    "input": {
      "transport": "wasm",
      "response_bytes": [
        80,
        76,
        69,
        86,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        153,
        0,
        0,
        0,
        123,
        34,
        100,
        97,
        116,
        97,
        34,
        58,
        123,
        125,
        44,
        34,
        115,
        111,
        117,
        114,
        99,
        101,
        34,
        58,
        123,
        34,
        110,
        111,
        100,
        101,
        95,
        105,
        100,
        34,
        58,
        34,
        110,
        34,
        44,
        34,
        114,
        101,
        118,
        105,
        115,
        105,
        111,
        110,
        95,
        105,
        100,
        34,
        58,
        34,
        114,
        34,
        44,
        34,
        115,
        112,
        97,
        110,
        34,
        58,
        123,
        34,
        101,
        110,
        100,
        34,
        58,
        123,
        34,
        99,
        111,
        108,
        117,
        109,
        110,
        34,
        58,
        50,
        44,
        34,
        108,
        105,
        110,
        101,
        34,
        58,
        49,
        125,
        44,
        34,
        101,
        110,
        100,
        95,
        98,
        121,
        116,
        101,
        34,
        58,
        34,
        49,
        34,
        44,
        34,
        115,
        116,
        97,
        114,
        116,
        34,
        58,
        123,
        34,
        99,
        111,
        108,
        117,
        109,
        110,
        34,
        58,
        49,
        44,
        34,
        108,
        105,
        110,
        101,
        34,
        58,
        49,
        125,
        44,
        34,
        115,
        116,
        97,
        114,
        116,
        95,
        98,
        121,
        116,
        101,
        34,
        58,
        34,
        48,
        34,
        125,
        125,
        125
      ],
      "memory_growth_before_next_decode": true
    }
  },
  "espera": {
    "aplicacion": {
      "response_owned": true,
      "survives_next_call": true,
      "borrowed_view_retained": false,
      "source_equal_after_growth": true
    }
  },
  "sujetos": [
    "app"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La negociación de eventos binarios selecciona la versión de escritura más alta que ambas partes anuncian y declara las versiones que puede leer. El emisor PLEV 1 no escribe identidades de fuente; PLEV 2 las conserva. Una versión desconocida o un lote truncado produce un error de uso.",
  "verificacion": ["C6", "C7", "C8", "C9"]
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
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
        "operation": "negotiate",
        "arguments": {
          "event_binary_versions": [
            1,
            2
          ]
        }
      },
      {
        "operation": "negotiate",
        "arguments": {
          "event_binary_versions": [
            1
          ]
        }
      },
      {
        "operation": "negotiate",
        "arguments": {
          "event_binary_versions": [
            3
          ]
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "event_binary_version": 2,
            "event_binary_write_version": 2,
            "event_binary_read_versions": [
              1,
              2
            ]
          }
        },
        {
          "value": {
            "event_binary_version": 1,
            "event_binary_write_version": 1,
            "event_binary_read_versions": [
              1,
              2
            ]
          }
        },
        {
          "failure": {
            "family": "version"
          }
        }
      ]
    }
  },
  "sujetos": [
    "engine",
    "app"
  ]
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
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
        "operation": "encode_events",
        "arguments": {
          "encoding": "binary",
          "version": 1,
          "events": [
            {
              "class": "statement_entered",
              "line": 1,
              "depth": 1,
              "source": {
                "revision_id": "11",
                "node_id": "p7.r11.f2.n1",
                "identity": {
                  "project_id": "7",
                  "revision_id": "11",
                  "source_id": 2
                },
                "span": {
                  "start": {
                    "line": 1,
                    "column": 1
                  },
                  "end": {
                    "line": 1,
                    "column": 2
                  }
                }
              }
            }
          ]
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
    "engine",
    "app"
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "decode_events",
        "arguments": {
          "encoding": "binary",
          "encoded": [
            80,
            76,
            69,
            86,
            2
          ]
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
    "engine",
    "app"
  ]
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
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
        "operation": "encode_events",
        "arguments": {
          "encoding": "binary",
          "version": 3,
          "events": []
        }
      },
      {
        "operation": "encode_events",
        "arguments": {
          "encoding": "binary",
          "version": 65536,
          "events": []
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
    "engine",
    "app"
  ]
}
```

```definicion
{
  "id": "D5",
  "termino": "valores HTTP de efecto",
  "texto": "En el canal de efectos, HttpRequest serializa método, URL, cabeceras ordenadas con repetidos, cuerpo opcional, límite de respuesta opcional y plazo opcional. HttpResponse serializa estado, cabeceras ordenadas con repetidos, bytes de cuerpo y URL final. Un request_network o network_send reproducido obtiene su HostReply de la cinta; no consulta al anfitrión."
}
```

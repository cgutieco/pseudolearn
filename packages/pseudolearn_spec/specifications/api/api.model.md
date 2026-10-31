---
{
  "formato": "see/1",
  "id": "API.MODEL",
  "titulo": "Recursos de la API del núcleo",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Documentos, sesiones de edición, análisis y ejecuciones como recursos con identificador.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Core API resources",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Recursos de la API del núcleo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La API expone recursos con identificador opaco, estable durante la sesión: documento (texto, vocabulario, rigor y versión), análisis (de una versión de un documento), ejecución (de un análisis sin errores) y sesión de edición (texto, perfil, rigor y revisión). Cada recurso se crea, se consulta y se libera; liberar un documento libera sus análisis y ejecuciones.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "secuencias": "secuencias generadas de crear, consultar y liberar recursos"
  },
  "propiedad": "Toda consulta de un recurso vivo responde y toda consulta de un recurso liberado devuelve un error de uso.",
  "oraculo": "Modelo de estados de los recursos.",
  "justificacion": "La ejecuta el sujeto engine en R4 y R5."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El núcleo devuelve códigos y argumentos tipados; la presentación de prosa en un idioma de interfaz es un parámetro opcional del borde que no altera ningún otro dato de la respuesta.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "programas": "casos analyze del corpus",
    "idiomas": [
      "es",
      "en",
      "sin idioma"
    ]
  },
  "propiedad": "Las respuestas en distintos idiomas de interfaz solo difieren en los campos de prosa.",
  "oraculo": "Respuesta sin idioma de interfaz.",
  "justificacion": "La ejecuta el sujeto engine en R4."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sesión de edición es un recurso identificado con texto, perfil, rigor y revisión u64. help_query consulta una posición de una sesión viva en su revisión vigente; la consulta no cambia texto, revisión ni estado de otras sesiones. Una revisión distinta de la vigente devuelve stale_revision con la revisión actual codificada como cadena decimal. Una sesión liberada, desconocida o de otra clase devuelve un error de uso.",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C9"
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "en",
          "detail": "full"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "full"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "revision": "1",
            "language": "en",
            "detail": "full",
            "help": {
              "category": "keyword"
            }
          }
        },
        {
          "value": {
            "revision": "1",
            "language": "es",
            "detail": "full",
            "help": {
              "category": "keyword"
            }
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

```caso
{
  "id": "C4",
  "regla": "R3",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "apply_edit",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "edits": [
            {
              "start_utf8": "0",
              "end_utf8": "0",
              "text": " "
            }
          ]
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "revision": "2"
          }
        },
        {
          "value": {
            "stale_revision": "2"
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

```caso
{
  "id": "C5",
  "regla": "R3",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "release",
        "resource_from": 0,
        "arguments": {}
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": null
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
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "help_query recibe resource, revision como cadena decimal u64, position con line y column desde uno y unit unicode_scalar o utf16, language es o en independiente del perfil de sintaxis, y detail summary o full. Devuelve revision, language, detail, position y help estructurada o null. summary incluye category e identifier; full puede añadir type_name, is_inferred, is_intrinsic y signature. La respuesta no contiene índices del CST. Las columnas UTF-16 entre los sustitutos de un punto fuera del plano básico y las posiciones fuera de los límites de la línea son errores de uso.",
  "verificacion": [
    "C6",
    "C7",
    "C8"
  ]
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nEscribir \"🧩\"; Escribir 1;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 15,
            "unit": "unicode_scalar"
          },
          "language": "en",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 16,
            "unit": "utf16"
          },
          "language": "en",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 12,
            "unit": "utf16"
          },
          "language": "en",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 99,
            "unit": "unicode_scalar"
          },
          "language": "en",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "revision": "1",
            "language": "en",
            "detail": "summary",
            "help": {
              "category": "keyword"
            }
          }
        },
        {
          "value": {
            "revision": "1",
            "language": "en",
            "detail": "summary",
            "help": {
              "category": "keyword"
            }
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "open_edit_session",
        "arguments": {
          "program": "",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "18446744073709551615",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "stale_revision": "1"
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

```caso
{
  "id": "C8",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unknown"
          },
          "language": "es",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 0,
            "column": 1,
            "unit": "utf16"
          },
          "language": "es",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "xx",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "brief"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "18446744073709551616",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "01",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
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

```caso
{
  "id": "C9",
  "regla": "R3",
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
        "operation": "create_document",
        "arguments": {
          "program": "Algoritmo P\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 1,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
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
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "help_query devuelve resolution cuando la posición selecciona un token con identidad léxica o semántica, aunque todavía no exista una ficha editorial. resolution contiene identity (kind, id y role) para vocabulario, operador o construcción, o symbol (category e identifier) para una referencia de usuario; certainty es certain o partial; lexical_range cubre el token original completo y enclosing_range cubre la construcción CST resuelta o es null. Ambos tramos usan líneas y columnas Unicode desde uno, extremos semiabiertos, y el texto original incluso con alias, compuestos, Unicode y CRLF. No se exponen índices internos. Sin token resoluble, resolution y help son null; con identidad pero sin ficha, resolution existe y help es null.",
  "verificacion": [
    "C10",
    "C11",
    "C12",
    "C13"
  ]
}
```

```caso
{
  "id": "C10",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nPara i <- 1 Hasta 2 Con Paso 1 Hacer\nFinPara\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 27,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "resolution": {
              "identity": {
                "kind": "construction",
                "id": "for",
                "role": "step_clause"
              },
              "certainty": "certain",
              "lexical_range": {
                "start": {
                  "line": 2,
                  "column": 21
                },
                "end": {
                  "line": 2,
                  "column": 29
                }
              },
              "enclosing_range": {
                "start": {
                  "line": 2,
                  "column": 1
                },
                "end": {
                  "line": 3,
                  "column": 8
                }
              }
            },
            "help": {
              "category": "keyword"
            }
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

```caso
{
  "id": "C11",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nEscribir 1 + 2;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 12,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "full"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "resolution": {
              "identity": {
                "kind": "operator",
                "id": "plus",
                "role": "binary"
              },
              "certainty": "certain",
              "lexical_range": {
                "start": {
                  "line": 2,
                  "column": 12
                },
                "end": {
                  "line": 2,
                  "column": 13
                }
              },
              "enclosing_range": {
                "start": {
                  "line": 2,
                  "column": 10
                },
                "end": {
                  "line": 2,
                  "column": 15
                }
              }
            },
            "help": null
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nDefinir Longitud Como Entero;\nLongitud <- 2;\nEscribir Longitud;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 4,
            "column": 10,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "resolution": {
              "symbol": {
                "category": "variable",
                "identifier": "Longitud"
              },
              "certainty": "certain",
              "lexical_range": {
                "start": {
                  "line": 4,
                  "column": 10
                },
                "end": {
                  "line": 4,
                  "column": 18
                }
              },
              "enclosing_range": null
            },
            "help": {
              "category": "variable",
              "identifier": "Longitud"
            }
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

```caso
{
  "id": "C13",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\r\nEscribir \"😀\"; // nota\r\nFinAlgoritmo\r\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 11,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 15,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 4,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "resolution": null,
            "help": null
          }
        },
        {
          "value": {
            "resolution": null,
            "help": null
          }
        },
        {
          "value": {
            "resolution": null,
            "help": null
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
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando la identidad resuelta tiene ficha en el catálogo, help_query devuelve card en el idioma solicitado, independiente del perfil de sintaxis: con detalle summary, id, title y summary; con detalle full, además purpose, parts, constraints, common_errors y examples, y help añade description. Cada ejemplo conserva su referencia a especificación, versión, caso, perfil, rigor y clase; la respuesta no contiene programas ni resultados esperados y la consulta no los ejecuta. Sin ficha o sin identidad card es null.",
  "justificacion": "La ficha es la fuente editorial única; entregarla por la API evita que cada cliente reconozca el lenguaje o conserve su propia descripción.",
  "verificacion": [
    "C14",
    "C15",
    "C16"
  ]
}
```

```caso
{
  "id": "C14",
  "regla": "R6",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nMientras 1 = 1 Hacer\nFinMientras\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 3,
            "unit": "unicode_scalar"
          },
          "language": "en",
          "detail": "full"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 3,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "summary"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "language": "en",
            "help": {
              "category": "keyword",
              "description": "Starts a loop that checks its condition before each iteration."
            },
            "card": {
              "id": "help.while",
              "title": "While loop",
              "summary": "Repeats the body while the condition is true.",
              "purpose": "The condition is checked before entering each iteration."
            }
          }
        },
        {
          "value": {
            "language": "es",
            "card": {
              "id": "help.while",
              "title": "Bucle Mientras",
              "summary": "Repite el cuerpo mientras la condición sea verdadera."
            }
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

```caso
{
  "id": "C15",
  "regla": "R6",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nMientras 1 = 1 Hacer\nFinMientras\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 2,
            "column": 3,
            "unit": "unicode_scalar"
          },
          "language": "en",
          "detail": "full"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "card": {
              "examples": [
                {
                  "specification": "LANG.CONTROL.WHILE",
                  "version": "1.0.0",
                  "case": "C1",
                  "profile": "en",
                  "strictness": "estricto",
                  "kind": "executable"
                },
                {
                  "specification": "LANG.CONTROL.WHILE",
                  "version": "1.0.0",
                  "case": "C3",
                  "profile": "en",
                  "strictness": "estricto",
                  "kind": "diagnostic"
                }
              ]
            }
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

```caso
{
  "id": "C16",
  "regla": "R6",
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
        "operation": "open_edit_session",
        "arguments": {
          "program": "Algoritmo P\nDefinir x Como Entero;\nx <- 1;\nFinAlgoritmo\n",
          "profile": "es",
          "strictness": "strict"
        }
      },
      {
        "operation": "help_query",
        "resource_from": 0,
        "arguments": {
          "revision": "1",
          "position": {
            "line": 3,
            "column": 1,
            "unit": "unicode_scalar"
          },
          "language": "es",
          "detail": "full"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "revision": "1"
          }
        },
        {
          "value": {
            "help": {
              "category": "variable"
            },
            "card": null
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
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "create_lsp crea en ApiSession un recurso LSP persistente sin E/S y devuelve resource. lsp_message recibe resource y message como objeto JSON-RPC LSP y devuelve messages, la lista ordenada de respuestas y notificaciones del mismo LspServer que usa escritorio. Notificaciones sin respuesta devuelven lista vacía. release libera el recurso y devuelve null; operaciones posteriores o con otra clase de recurso devuelven uso. Los snapshots y overlays llegan como datos por el protocolo existente; el borde Wasm no importa servicio ni VM directamente.",
  "verificacion": [
    "C17",
    "C18",
    "C19"
  ]
}
```

```caso
{
  "id": "C17",
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
        "operation": "create_lsp",
        "arguments": {}
      },
      {
        "operation": "lsp_message",
        "arguments": {
          "message": {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
              "capabilities": {}
            }
          }
        },
        "resource_from": 0
      },
      {
        "operation": "lsp_message",
        "arguments": {
          "message": {
            "jsonrpc": "2.0",
            "method": "initialized",
            "params": {}
          }
        },
        "resource_from": 0
      },
      {
        "operation": "release",
        "arguments": {},
        "resource_from": 0
      },
      {
        "operation": "lsp_message",
        "arguments": {
          "message": {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "shutdown"
          }
        },
        "resource_from": 0
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
            "messages": [
              {
                "jsonrpc": "2.0",
                "id": 1,
                "result": {
                  "capabilities": {
                    "hoverProvider": true
                  }
                }
              }
            ]
          }
        },
        {
          "value": {
            "messages": []
          }
        },
        {
          "value": null
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

```caso
{
  "id": "C18",
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
        "operation": "lsp_message",
        "arguments": {
          "resource": 0,
          "message": {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize"
          }
        }
      },
      {
        "operation": "create_lsp",
        "arguments": {}
      },
      {
        "operation": "lsp_message",
        "arguments": {
          "message": null
        },
        "resource_from": 1
      },
      {
        "operation": "release",
        "arguments": {},
        "resource_from": 1
      },
      {
        "operation": "release",
        "arguments": {},
        "resource_from": 1
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
          "value": {}
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

```caso
{
  "id": "C19",
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
        "operation": "create_lsp",
        "arguments": {}
      },
      {
        "operation": "lsp_message",
        "arguments": {
          "message": {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
              "capabilities": {}
            }
          }
        },
        "resource_from": 0
      },
      {
        "operation": "lsp_message",
        "arguments": {
          "message": {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "shutdown",
            "params": null
          }
        },
        "resource_from": 0
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
            "messages": [
              {
                "id": 1
              }
            ]
          }
        },
        {
          "value": {
            "messages": [
              {
                "id": 2,
                "result": null
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
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "translate recibe program, target_profile es o en y strictness opcional strict o flexible y devuelve text. Reutiliza el traductor del servicio sobre texto sin E/S; conserva los identificadores y literales, y rechaza el perfil inválido o una traducción imposible como error de uso. El transporte browser usa la misma operación sin interpretar sintaxis en TypeScript.",
  "verificacion": [
    "C20",
    "C21"
  ]
}
```

```caso
{
  "id": "C20",
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
        "operation": "translate",
        "arguments": {
          "program": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
          "target_profile": "en"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "text": "algorithm P\nwrite 1;\nendAlgorithm\n"
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

```caso
{
  "id": "C21",
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
        "operation": "translate",
        "arguments": {
          "program": "Algoritmo P\nFinAlgoritmo\n",
          "target_profile": "invalid"
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

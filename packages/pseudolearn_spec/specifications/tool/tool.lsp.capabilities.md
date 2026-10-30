---
{
  "formato": "see/1",
  "id": "TOOL.LSP.CAPABILITIES",
  "titulo": "Capacidades del servidor LSP",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Servidor Language Server Protocol sobre JSON-RPC con capacidades negociadas de workspace, navegación, diagnósticos, edición y asistencia al teclear.",
  "depende_de": [
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.COMPLETION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.NAVIGATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.HOVER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.FORMAT.STYLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "LSP server capabilities",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Capacidades del servidor LSP

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Al recibir initialize, el servidor negocia las capacidades del cliente y anuncia únicamente los proveedores implementados: sincronización incremental, completion, hover, signature help, definition, references, document highlight, document/workspace symbols, formatting, prepareRename/rename y semanticTokens full. La selección de workspace folders, relatedInformation, snippets, documentChanges y transactional failure handling depende de las capacidades declaradas por el cliente. El idioma de interfaz se negocia de forma independiente del perfil del documento. Ante shutdown devuelve null y ante exit después de shutdown finaliza con código 0.",
  "verificacion": [
    "C1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Tras didOpen, didChange, didSave, cambios de workspace o resincronización, el servidor actualiza la sesión y publica diagnósticos con posiciones UTF-16 0-indexadas, versión y relatedInformation cuando fue negociado. didClose elimina el overlay y vuelve al texto del snapshot del proyecto más reciente; si el archivo pertenece al proyecto conserva su análisis y diagnósticos, y si es un documento suelto libera la sesión y publica lista vacía.",
  "verificacion": [
    "C2"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las peticiones textDocument/completion, textDocument/hover, textDocument/signatureHelp, textDocument/definition, textDocument/references, textDocument/documentHighlight, textDocument/documentSymbol, workspace/symbol, textDocument/formatting y textDocument/semanticTokens/full devuelven resultados coherentes con el motor convirtiendo entre posiciones 1-indexadas del motor y posiciones UTF-16 0-indexadas de LSP. La navegación incluye fuentes cerradas del proyecto y respeta la identidad semántica, visibilidad, alias y reexportaciones.",
  "verificacion": [
    "C3"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El servidor anuncia completionProvider con triggerCharacters [\".\"] y onTypeFormattingProvider con firstTriggerCharacter de salto de línea. Los candidatos que llevan paradas se entregan con insertTextFormat 2 y como texto el fragmento derivado de la misma estructura que el servicio; el resto con insertTextFormat 1. La petición textDocument/onTypeFormatting devuelve las ediciones de la asistencia al teclear.",
  "verificacion": [
    "C4",
    "C5"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El servidor anuncia navegación de workspace, prepareRename/rename y semanticTokens full cuando implementa esos métodos. Solo anuncia documentChanges, relatedInformation, snippets y el comportamiento de workspaceFolders que el cliente declaró; no anuncia delta ni range. El servidor expone una leyenda estable con tipos keyword, operator, number, string, comment, variable, function, class, property, parameter y type, y los datos semánticos siguen el orden y la codificación entera de LSP.",
  "verificacion": ["C12", "C15"]
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los métodos workspace/symbol, textDocument/definition, textDocument/references y textDocument/documentHighlight consultan la identidad semántica del snapshot efectivo del proyecto. Incluyen archivos cerrados, distinguen homónimos y sombreado, respetan visibilidad privada, y siguen alias y reexportaciones. Al cerrar un archivo del proyecto el overlay desaparece y el servicio vuelve al contenido del snapshot más reciente.",
  "verificacion": ["C13"]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "prepareRename devuelve el rango exacto y el texto actual del símbolo, o null fuera de un símbolo renombrable. rename rechaza nombres inválidos, palabras reservadas, colisiones, capacidades transaccionales ausentes y fuentes obsoletas; si se acepta, devuelve un único WorkspaceEdit de documentChanges con versiones para todos los documentos abiertos y sin aplicar cambios en el servidor.",
  "verificacion": ["C14"]
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "semanticTokens/full codifica tokens sobre la revisión actual del documento en posiciones UTF-16. Una respuesta calculada para una revisión sustituida se descarta. Los tokens toleran texto sintácticamente incompleto y no establecen validez del programa.",
  "verificacion": ["C15"]
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "$/cancelRequest se procesa mientras una consulta está en curso sin esperar detrás de esa consulta. Cada petición cancelada recibe una única respuesta de cancelación, y no publica después resultados de diagnóstico o respuesta tardíos para la revisión cancelada.",
  "verificacion": ["C16"]
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "disparadores_completado": [
        "."
      ],
      "disparador_escritura": "\n"
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es",
          "capabilities": {}
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "shutdown"
      },
      {
        "jsonrpc": "2.0",
        "method": "exit"
      }
    ],
    "proyeccion": "capacidades_edicion"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "etiqueta": "Si",
      "insertTextFormat": 2,
      "insertText": "Si ${1:condicion} Entonces\n  $0\nSino\n  \nFinSi"
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es",
          "capabilities": {
            "textDocument": {
              "completion": {
                "completionItem": {
                  "snippetSupport": true
                }
              }
            }
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///edicion.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Si\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/completion",
        "params": {
          "textDocument": {
            "uri": "file:///edicion.pseudo"
          },
          "position": {
            "line": 1,
            "character": 4
          }
        }
      }
    ],
    "proyeccion": "fragmento",
    "etiqueta": "Si"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "capacidades_anunciadas": true,
      "cierre_limpio": true
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es",
          "capabilities": {}
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "initialized",
        "params": {}
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "shutdown"
      },
      {
        "jsonrpc": "2.0",
        "method": "exit"
      }
    ],
    "proyeccion": "capacidades"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "diagnosticos_iniciales": 1,
      "diagnosticos_corregidos": 0
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///prueba.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Definir x Como Entero;\n  x <- \"error\";\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didChange",
        "params": {
          "textDocument": {
            "uri": "file:///prueba.pseudo",
            "version": 2
          },
          "contentChanges": [
            {
              "range": {
                "start": {
                  "line": 2,
                  "character": 7
                },
                "end": {
                  "line": 2,
                  "character": 14
                }
              },
              "text": "42"
            }
          ]
        }
      }
    ],
    "proyeccion": "diagnosticos"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "consultas_respondidas": true
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Definir total Como Entero;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/definition",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo"
          },
          "position": {
            "line": 3,
            "character": 12
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/hover",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo"
          },
          "position": {
            "line": 2,
            "character": 4
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 4,
        "method": "textDocument/completion",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo"
          },
          "position": {
            "line": 3,
            "character": 12
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 5,
        "method": "textDocument/references",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo"
          },
          "position": {
            "line": 3,
            "character": 12
          },
          "context": {
            "includeDeclaration": true
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 6,
        "method": "textDocument/documentSymbol",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 7,
        "method": "textDocument/formatting",
        "params": {
          "textDocument": {
            "uri": "file:///consultas.pseudo"
          },
          "options": {
            "tabSize": 2,
            "insertSpaces": true
          }
        }
      }
    ],
    "proyeccion": "consultas"
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "textDocument/hover responde con el contenido de la consulta común de ayuda en el idioma de locale negociado, independiente del perfil del documento: la cabecera del símbolo o firma, el título y el resumen de la ficha que corresponde a la identidad y el papel resueltos, y su propósito, partes, restricciones, errores comunes y ejemplos cuando existen. Incluye el rango del token completo. El servidor anuncia executeCommandProvider con el comando pseudolearn.explain, que recibe uri, version del documento, posición LSP y formato markdown o plaintext, y devuelve el mismo contenido y rango que el hover. Una versión distinta de la última recibida responde con el error ContentModified (-32801), un comando desconocido con InvalidParams (-32602) y una posición sin ayuda con resultado nulo. El texto de la ficha y los nombres del programa se escapan como texto y nunca se interpretan como marcado.",
  "justificacion": "Hover y comando son dos adaptadores del mismo resultado; separar el idioma del perfil permite explicar un programa en un idioma distinto del que se escribió, y la versión impide mostrar una explicación de un texto que ya cambió.",
  "verificacion": [
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11"
  ]
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "formato": "markdown",
      "contenido_completo": true,
      "rango": {
        "start": {
          "line": 1,
          "character": 2
        },
        "end": {
          "line": 1,
          "character": 10
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///ayuda.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/hover",
        "params": {
          "textDocument": {
            "uri": "file:///ayuda.pseudo"
          },
          "position": {
            "line": 1,
            "character": 4
          }
        }
      }
    ],
    "proyeccion": "ayuda",
    "contiene": [
      "Bucle Mientras",
      "Repite el cuerpo mientras la condición sea verdadera\\.",
      "La condición se comprueba antes de entrar en cada iteración\\."
    ]
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "formato": "plaintext",
      "contenido_completo": true,
      "rango": {
        "start": {
          "line": 1,
          "character": 2
        },
        "end": {
          "line": 1,
          "character": 10
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "en"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///ayuda.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "workspace/executeCommand",
        "params": {
          "command": "pseudolearn.explain",
          "arguments": [
            {
              "uri": "file:///ayuda.pseudo",
              "version": 1,
              "position": {
                "line": 1,
                "character": 4
              },
              "format": "plaintext"
            }
          ]
        }
      }
    ],
    "proyeccion": "ayuda",
    "contiene": [
      "While loop",
      "Repeats the body while the condition is true.",
      "The condition is checked before entering each iteration."
    ]
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "codigo_error": -32801
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///ayuda.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "workspace/executeCommand",
        "params": {
          "command": "pseudolearn.explain",
          "arguments": [
            {
              "uri": "file:///ayuda.pseudo",
              "version": 7,
              "position": {
                "line": 1,
                "character": 4
              }
            }
          ]
        }
      }
    ],
    "proyeccion": "ayuda"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "codigo_error": -32602
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///ayuda.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "workspace/executeCommand",
        "params": {
          "command": "pseudolearn.unknown",
          "arguments": [
            {
              "uri": "file:///ayuda.pseudo",
              "version": 1,
              "position": {
                "line": 1,
                "character": 4
              }
            }
          ]
        }
      }
    ],
    "proyeccion": "ayuda"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "comandos": [
        "pseudolearn.explain"
      ]
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      }
    ],
    "proyeccion": "capacidades_ayuda"
  }
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
  "operacion": "service",
  "espera": {
    "servicio": {
      "resultado": null
    }
  },
  "servicio": {
    "suboperacion": "lsp",
    "mensajes": [
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "locale": "es"
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///ayuda.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\n  Mientras 1 = 1 Hacer\n  FinMientras\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "workspace/executeCommand",
        "params": {
          "command": "pseudolearn.explain",
          "arguments": [
            {
              "uri": "file:///ayuda.pseudo",
              "version": 1,
              "position": {
                "line": 1,
                "character": 1
              }
            }
          ]
        }
      }
    ],
    "proyeccion": "ayuda"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R6",
  "perfiles": ["es", "en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio": {"workspace_folders": true, "prepare_rename": true, "semantic_tokens_full": true}},
  "servicio": {"suboperacion": "lsp", "mensajes": [{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceFolders":{"supported":true},"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}},"textDocument":{"publishDiagnostics":{"relatedInformation":true},"completion":{"completionItem":{"snippetSupport":true}},"semanticTokens":{}}}}}],"proyeccion":"capacidades_proyecto"}
}
```

```caso
{
  "id": "C13",
  "regla": "R7",
  "perfiles": ["es", "en"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio": {"definicion_uri": "file:///geo/vectores.pseudo", "referencias": 2}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{}}},{"jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot","params":{"project":{"project_id":1,"revision_id":1,"packages":[{"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},{"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}],"files":[{"path":"app/main","source_id":1,"text":"Importar geo.vectores.Doble;\\nAlgoritmo P\\nEscribir Doble(1);\\nFinAlgoritmo\\n"},{"path":"geo/vectores","source_id":2,"text":"Publico SubProceso Doble()\\nFinSubProceso\\n"}]},"uris":{"app/main":"file:///app/main.pseudo","geo/vectores":"file:///geo/vectores.pseudo"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/definition","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9} }},{"jsonrpc":"2.0","id":3,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}}],"proyeccion":"navegacion_proyecto"}
}
```

```caso
{
  "id": "C14",
  "regla": "R8",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio": {"prepare_range":{"start":{"line":1,"character":16},"end":{"line":1,"character":21}},"rename_edits":2}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///rename.pseudo","languageId":"pseudolearn","version":1,"text":"Algoritmo Total\\nDefinir Mutable total Como Entero <- 0;\\nEscribir total;\\nFinAlgoritmo\\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/prepareRename","params":{"textDocument":{"uri":"file:///rename.pseudo"},"position":{"line":1,"character":16}}},{"jsonrpc":"2.0","id":3,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///rename.pseudo"},"position":{"line":1,"character":16},"newName":"suma"}}],"proyeccion":"rename"}
}
```

```caso
{
  "id": "C15",
  "regla": "R9",
  "perfiles": ["en"],
  "rigor": ["flexible"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio": {"semantic_token_count":5,"token_encoding":"relative-utf16"}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"en","capabilities":{"textDocument":{"semanticTokens":{}}}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///tokens.pseudo","languageId":"pseudolearn","version":1,"text":"algorithm Main\\nwrite 1;\\nendAlgorithm\\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/semanticTokens/full","params":{"textDocument":{"uri":"file:///tokens.pseudo"}}}],"proyeccion":"semantic_tokens"}
}
```

```caso
{
  "id": "C16",
  "regla": "R10",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio": {"cancelacion_silenciosa": true}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es"}},{"jsonrpc":"2.0","method":"$/cancelRequest","params":{"id":2}}],"proyeccion":"cancelacion"}
}
```

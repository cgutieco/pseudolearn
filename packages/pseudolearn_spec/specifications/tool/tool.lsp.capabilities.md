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
  "resumen": "Servidor Language Server Protocol sobre JSON-RPC con capacidades de sincronización, navegación, diagnósticos, fragmentos y asistencia al teclear.",
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
  "texto": "Al recibir initialize, el servidor responde con el objeto capabilities que declara textDocumentSync, completionProvider, hoverProvider, signatureHelpProvider, definitionProvider, referencesProvider, documentHighlightProvider, documentSymbolProvider y documentFormattingProvider, adoptando el idioma de locale. Ante shutdown devuelve null y ante exit finaliza limpiamente.",
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
  "texto": "Tras didOpen y didChange, el servidor actualiza la sesión incremental y emite notificación textDocument/publishDiagnostics con posiciones 0-indexadas y mensajes localizados. Al recibir didClose, libera la sesión y publica lista vacía de diagnósticos.",
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
  "texto": "Las peticiones textDocument/completion, textDocument/hover, textDocument/signatureHelp, textDocument/definition, textDocument/references, textDocument/documentHighlight, textDocument/documentSymbol y textDocument/formatting devuelven resultados coherentes con el motor convirtiendo entre posiciones 1-indexadas del motor y posiciones 0-indexadas de LSP.",
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
          "locale": "es"
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

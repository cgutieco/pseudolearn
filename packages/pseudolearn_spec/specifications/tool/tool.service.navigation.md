---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.NAVIGATION",
  "titulo": "Navegación de código y referencias",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Definición, referencias, resaltado y rename sobre identidades semánticas de documento y proyecto.",
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CLASS.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Code navigation service",
  "revisado_por": [
    "revision-independiente-automatizada-r9",
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Navegación de código y referencias

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dada una posición de cursor sobre un uso o declaración de variable, constante, parámetro, subproceso, función, clase, registro, enumerado, interfaz, campo o método, el servicio devuelve el rango exacto de su declaración en el alcance correspondiente. En un proyecto, la identidad atraviesa archivos y respeta módulos, visibilidad, alias y reexportaciones; la ruta de un Importar o Exportar que nombra el símbolo es un uso más de él. Una plantilla genérica (subproceso, registro, clase, interfaz o variante) y cada uno de sus parámetros de tipo son símbolos propios: los usos de cualquier instancia de la plantilla, incluidos los de otros módulos, se atribuyen a la plantilla, y los de los métodos, campos y variables de una instancia, al miembro o a la variable que declara la plantilla.",
  "verificacion": [
    "C1",
    "C3",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C18",
    "C20"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dada una posición sobre un símbolo, devuelve en orden de aparición todos los rangos de los documentos del proyecto que referencian ese mismo símbolo semántico, sin confundirlo con símbolos homónimos de otros alcances. Incluye archivos cerrados del snapshot y nunca expone referencias a miembros privados no visibles. Las referencias de un parámetro de tipo son solo las de su plantilla, sin confundirlo con parámetros homónimos de otras plantillas.",
  "verificacion": [
    "C2",
    "C14",
    "C17"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El resaltado de documento devuelve las ocurrencias del símbolo bajo el cursor clasificando cada una como lectura o escritura/declaración. La declaración de una plantilla o de un parámetro de tipo se clasifica como escritura/declaración y sus usos como lectura.",
  "verificacion": [
    "C4",
    "C19"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "prepareRename identifica solo el lexema del símbolo y devuelve su rango exacto y placeholder. Antes de rename, el cliente materializa cada fuente cerrada que vaya a editar con su contenido y versión vigentes, y vuelve a calcular prepareRename y referencias sobre esas revisiones sincronizadas. rename acepta únicamente identificadores válidos y no reservados en los perfiles de los archivos afectados, comprueba colisiones semánticas en todos los alcances afectados y compara las revisiones antes de crear ediciones. Una propuesta aceptada contiene exclusivamente textDocument/documentChanges versionados para todos los documentos afectados; una colisión, versión antigua, modificación concurrente o garantía transaccional ausente rechaza la propuesta completa sin mutar fuentes. Renombrar una plantilla edita su declaración y todos sus usos en los documentos del proyecto; renombrar un parámetro de tipo edita solo las ocurrencias dentro de su plantilla, y un nombre igual al de otro parámetro de la misma plantilla es una colisión.",
  "verificacion": ["C5", "C6", "C8", "C15", "C16", "C21", "C22", "C23"]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "end": {
          "column": 16,
          "line": 2
        },
        "start": {
          "column": 11,
          "line": 2
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Algoritmo Principal\n  Definir total Como Entero <- 0;\n  total <- 10;\n  Escribir total;\nFinAlgoritmo\n",
    "posicion": {
      "line": 4,
      "column": 13
    }
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
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "referencias": [
        {
          "end": {
            "column": 12,
            "line": 2
          },
          "start": {
            "column": 11,
            "line": 2
          }
        },
        {
          "start": {
            "line": 3,
            "column": 3
          },
          "end": {
            "line": 3,
            "column": 4
          }
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "references",
    "documento": "SubProceso Uno()\n  Definir i Como Entero <- 0;\n  i <- 1;\nFinSubProceso\n\nSubProceso Dos()\n  Definir i Como Entero <- 0;\n  i <- 2;\nFinSubProceso\n",
    "posicion": {
      "line": 3,
      "column": 3
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": { "line": 2, "column": 10 },
        "end": { "line": 2, "column": 15 }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Clase Punto\n  Metodo Mover()\n  FinMetodo\nFinClase\n\nAlgoritmo Principal\n  Definir p Como Punto <- Punto();\n  p.Mover();\nFinAlgoritmo\n",
    "posicion": { "line": 8, "column": 6 }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "destacados": [
        {
          "rango": {
            "start": { "line": 2, "column": 3 },
            "end": { "line": 2, "column": 4 }
          },
          "tipo": "write"
        },
        {
          "rango": {
            "start": { "line": 3, "column": 12 },
            "end": { "line": 3, "column": 13 }
          },
          "tipo": "read"
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "highlight",
    "documento": "Algoritmo Principal\n  x <- 1;\n  Escribir x;\nFinAlgoritmo\n",
    "posicion": { "line": 2, "column": 3 }
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
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "prepare_range": {
        "end": {
          "character": 13,
          "line": 1
        },
        "start": {
          "character": 8,
          "line": 1
        }
      },
      "rename_edits": 2
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
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
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
            "uri": "file:///rename-es.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Algoritmo Principal\nDefinir total Como Entero <- 0;\nEscribir total;\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/prepareRename",
        "params": {
          "textDocument": {
            "uri": "file:///rename-es.pseudo"
          },
          "position": {
            "line": 1,
            "character": 8
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///rename-es.pseudo"
          },
          "position": {
            "line": 1,
            "character": 8
          },
          "newName": "suma"
        }
      }
    ],
    "proyeccion": "rename"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {"servicio":{"rename_rejected":true}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///rename-es.pseudo","languageId":"pseudolearn","version":1,"text":"Algoritmo Principal\nDefinir total Como Entero <- 0;\nEscribir total;\nFinAlgoritmo\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///rename-es.pseudo"},"position":{"line":1,"character":16},"newName":"Mientras"}}],"proyeccion":"rename_rejected"}
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "prepare_range": {
        "end": {
          "character": 12,
          "line": 1
        },
        "start": {
          "character": 7,
          "line": 1
        }
      },
      "rename_edits": 2
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
          "locale": "en",
          "capabilities": {
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
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
            "uri": "file:///rename-en.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "algorithm Main\ndefine total as integer <- 0;\nwrite total;\nendAlgorithm\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/prepareRename",
        "params": {
          "textDocument": {
            "uri": "file:///rename-en.pseudo"
          },
          "position": {
            "line": 1,
            "character": 7
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///rename-en.pseudo"
          },
          "position": {
            "line": 1,
            "character": 7
          },
          "newName": "sum"
        }
      }
    ],
    "proyeccion": "rename"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R4",
  "perfiles": ["es"],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {"servicio":{"rename_edits":3,"document_versions":{"file:///app/main.pseudo":3,"file:///geo/vector.pseudo":8}}},
  "servicio": {"suboperacion":"lsp","mensajes":[{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"locale":"es","capabilities":{"workspace":{"workspaceEdit":{"documentChanges":true,"failureHandling":"transactional"}}}}},{"jsonrpc":"2.0","method":"pseudolearn/workspaceSnapshot","params":{"project":{"project_id":7,"revision_id":1,"packages":[{"name":"app","root":"app","kind":"application","entries":["app/main"],"dependencies":{"geo":"geo"}},{"name":"geo","root":"geo","kind":"library","entries":[],"dependencies":{}}],"files":[{"path":"app/main","source_id":1,"text":"Importar geo.vector.Double;\nAlgoritmo Main\nEscribir Double(2);\nFinAlgoritmo\n"},{"path":"geo/vector","source_id":2,"text":"Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n"}]},"uris":{"app/main":"file:///app/main.pseudo","geo/vector":"file:///geo/vector.pseudo"}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///app/main.pseudo","languageId":"pseudolearn","version":3,"text":"Importar geo.vector.Double;\nAlgoritmo Main\nEscribir Double(2);\nFinAlgoritmo\n"}}},{"jsonrpc":"2.0","id":2,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}},{"jsonrpc":"2.0","method":"textDocument/didOpen","params":{"textDocument":{"uri":"file:///geo/vector.pseudo","languageId":"pseudolearn","version":8,"text":"Publico SubProceso Double(value Como Entero) Como Entero\nRetornar value * 2;\nFinSubProceso\n"}}},{"jsonrpc":"2.0","id":3,"method":"textDocument/prepareRename","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9}}},{"jsonrpc":"2.0","id":4,"method":"textDocument/references","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"context":{"includeDeclaration":true}}},{"jsonrpc":"2.0","id":5,"method":"textDocument/rename","params":{"textDocument":{"uri":"file:///app/main.pseudo"},"position":{"line":2,"character":9},"newName":"Twice"}}],"proyeccion":"transactional_rename_with_materialized_sources"}
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 10
        },
        "end": {
          "line": 1,
          "column": 15
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Registro Punto\n  Definir x Como Entero;\nFinRegistro\n\nAlgoritmo Principal\n  Definir p Como Punto <- Punto(1);\n  Escribir p.x;\nFinAlgoritmo\n",
    "posicion": {
      "line": 6,
      "column": 28
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 11
        },
        "end": {
          "line": 1,
          "column": 16
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Enumerado Color\n  Rojo, Verde\nFinEnumerado\n\nAlgoritmo Principal\n  Definir c Como Color <- Color.Rojo;\n  Escribir c;\nFinAlgoritmo\n",
    "posicion": {
      "line": 6,
      "column": 28
    }
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 11
        },
        "end": {
          "line": 1,
          "column": 17
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Constante Limite Como Entero <- 7;\n\nAlgoritmo Principal\n  Escribir Limite;\nFinAlgoritmo\n",
    "posicion": {
      "line": 4,
      "column": 13
    }
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 10
        },
        "end": {
          "line": 1,
          "column": 17
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "Interfaz Medible\n  Metodo Medida() Como Entero;\nFinInterfaz\n\nClase Caja Realiza Medible\n  Metodo Medida() Como Entero\n    Retornar 1;\n  FinMetodo\nFinClase\n\nAlgoritmo Principal\nFinAlgoritmo\n",
    "posicion": {
      "line": 5,
      "column": 21
    }
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R1",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 8
        },
        "end": {
          "line": 1,
          "column": 13
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "record Punto\n  define x as integer;\nendRecord\n\nalgorithm Main\n  define p as Punto <- Punto(1);\n  write p.x;\nendAlgorithm\n",
    "posicion": {
      "line": 6,
      "column": 25
    }
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "referencias": [
        {
          "start": {
            "line": 1,
            "column": 10
          },
          "end": {
            "line": 1,
            "column": 15
          }
        },
        {
          "start": {
            "line": 6,
            "column": 18
          },
          "end": {
            "line": 6,
            "column": 23
          }
        },
        {
          "start": {
            "line": 6,
            "column": 27
          },
          "end": {
            "line": 6,
            "column": 32
          }
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "references",
    "documento": "Registro Punto\n  Definir x Como Entero;\nFinRegistro\n\nAlgoritmo Principal\n  Definir p Como Punto <- Punto(1);\n  Escribir p.x;\nFinAlgoritmo\n",
    "posicion": {
      "line": 6,
      "column": 28
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "rename_edits": 4,
      "document_versions": {
        "file:///app/main.pseudo": 3,
        "file:///geo/tipos.pseudo": 8
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
          "locale": "es",
          "capabilities": {
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
              }
            }
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "pseudolearn/workspaceSnapshot",
        "params": {
          "project": {
            "project_id": 7,
            "revision_id": 1,
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.tipos.Punto;\nAlgoritmo Main\nDefinir p Como Punto <- Punto(1, 2);\nEscribir p.x;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/tipos",
                "source_id": 2,
                "text": "Publico Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\n"
              }
            ]
          },
          "uris": {
            "app/main": "file:///app/main.pseudo",
            "geo/tipos": "file:///geo/tipos.pseudo"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///app/main.pseudo",
            "languageId": "pseudolearn",
            "version": 3,
            "text": "Importar geo.tipos.Punto;\nAlgoritmo Main\nDefinir p Como Punto <- Punto(1, 2);\nEscribir p.x;\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/references",
        "params": {
          "textDocument": {
            "uri": "file:///app/main.pseudo"
          },
          "position": {
            "line": 2,
            "character": 15
          },
          "context": {
            "includeDeclaration": true
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "method": "textDocument/didOpen",
        "params": {
          "textDocument": {
            "uri": "file:///geo/tipos.pseudo",
            "languageId": "pseudolearn",
            "version": 8,
            "text": "Publico Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/prepareRename",
        "params": {
          "textDocument": {
            "uri": "file:///app/main.pseudo"
          },
          "position": {
            "line": 2,
            "character": 15
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 4,
        "method": "textDocument/references",
        "params": {
          "textDocument": {
            "uri": "file:///app/main.pseudo"
          },
          "position": {
            "line": 2,
            "character": 15
          },
          "context": {
            "includeDeclaration": true
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 5,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///app/main.pseudo"
          },
          "position": {
            "line": 2,
            "character": 15
          },
          "newName": "Marco"
        }
      }
    ],
    "proyeccion": "transactional_rename_with_materialized_sources"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "rename_rejected": true
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
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
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
            "uri": "file:///rename-es.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "Registro Punto\nDefinir x Como Entero;\nFinRegistro\nEnumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo Principal\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///rename-es.pseudo"
          },
          "position": {
            "line": 0,
            "character": 10
          },
          "newName": "Color"
        }
      }
    ],
    "proyeccion": "rename_rejected"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "referencias": [
        {
          "start": {
            "line": 1,
            "column": 12
          },
          "end": {
            "line": 1,
            "column": 21
          }
        },
        {
          "start": {
            "line": 5,
            "column": 10
          },
          "end": {
            "line": 5,
            "column": 19
          }
        },
        {
          "start": {
            "line": 5,
            "column": 24
          },
          "end": {
            "line": 5,
            "column": 33
          }
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "references",
    "documento": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4), identidad(2.5);\nFinAlgoritmo\n",
    "posicion": {
      "line": 5,
      "column": 10
    }
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 12
        },
        "end": {
          "line": 1,
          "column": 21
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4), identidad(2.5);\nFinAlgoritmo\n",
    "posicion": {
      "line": 5,
      "column": 25
    }
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "destacados": [
        {
          "rango": {
            "start": {
              "line": 1,
              "column": 22
            },
            "end": {
              "line": 1,
              "column": 23
            }
          },
          "tipo": "write"
        },
        {
          "rango": {
            "start": {
              "line": 1,
              "column": 36
            },
            "end": {
              "line": 1,
              "column": 37
            }
          },
          "tipo": "read"
        },
        {
          "rango": {
            "start": {
              "line": 1,
              "column": 44
            },
            "end": {
              "line": 1,
              "column": 45
            }
          },
          "tipo": "read"
        }
      ]
    }
  },
  "servicio": {
    "suboperacion": "highlight",
    "documento": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4), identidad(2.5);\nFinAlgoritmo\n",
    "posicion": {
      "line": 1,
      "column": 22
    }
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R1",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "definicion": {
        "start": {
          "line": 1,
          "column": 12
        },
        "end": {
          "line": 1,
          "column": 20
        }
      }
    }
  },
  "servicio": {
    "suboperacion": "definition",
    "documento": "subroutine identity<T>(value as T) as T\nreturn value;\nendSubroutine\nalgorithm P\nwrite identity(4), identity(2.5);\nendAlgorithm\n",
    "posicion": {
      "line": 5,
      "column": 22
    }
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "prepare_range": {
        "start": {
          "line": 0,
          "character": 21
        },
        "end": {
          "line": 0,
          "character": 22
        }
      },
      "rename_edits": 3
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
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
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
            "uri": "file:///plantilla-es.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nSubProceso otro<T>(x Como T)\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4);\notro(1);\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/prepareRename",
        "params": {
          "textDocument": {
            "uri": "file:///plantilla-es.pseudo"
          },
          "position": {
            "line": 0,
            "character": 21
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///plantilla-es.pseudo"
          },
          "position": {
            "line": 0,
            "character": 21
          },
          "newName": "Elemento"
        }
      }
    ],
    "proyeccion": "rename"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "rename_rejected": true
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
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
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
            "uri": "file:///plantilla-es.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "SubProceso identidad<T, U>(valor Como T, extra Como U) Como T\nRetornar valor;\nFinSubProceso\nSubProceso otro<T>(x Como T)\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4, 5);\notro(1);\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/prepareRename",
        "params": {
          "textDocument": {
            "uri": "file:///plantilla-es.pseudo"
          },
          "position": {
            "line": 0,
            "character": 21
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///plantilla-es.pseudo"
          },
          "position": {
            "line": 0,
            "character": 21
          },
          "newName": "U"
        }
      }
    ],
    "proyeccion": "rename_rejected"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "prepare_range": {
        "start": {
          "line": 0,
          "character": 11
        },
        "end": {
          "line": 0,
          "character": 20
        }
      },
      "rename_edits": 2
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
            "workspace": {
              "workspaceEdit": {
                "documentChanges": true,
                "failureHandling": "transactional"
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
            "uri": "file:///plantilla-es.pseudo",
            "languageId": "pseudolearn",
            "version": 1,
            "text": "SubProceso identidad<T>(valor Como T) Como T\nRetornar valor;\nFinSubProceso\nSubProceso otro<T>(x Como T)\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nEscribir identidad(4);\notro(1);\nFinAlgoritmo\n"
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 2,
        "method": "textDocument/prepareRename",
        "params": {
          "textDocument": {
            "uri": "file:///plantilla-es.pseudo"
          },
          "position": {
            "line": 7,
            "character": 9
          }
        }
      },
      {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "textDocument/rename",
        "params": {
          "textDocument": {
            "uri": "file:///plantilla-es.pseudo"
          },
          "position": {
            "line": 7,
            "character": 9
          },
          "newName": "mismo"
        }
      }
    ],
    "proyeccion": "rename"
  }
}
```

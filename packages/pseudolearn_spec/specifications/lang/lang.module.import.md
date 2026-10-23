---
{
  "formato": "see/1",
  "id": "LANG.MODULE.IMPORT",
  "titulo": "Imports, alias, visibilidad y reexportación",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Import nominal, alias, público y privado, exportación y reexportación sin comodines ni efectos.",
  "titulo_en": "Imports, aliases, visibility and re-export",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.MODULE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.SCOPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": []
}
---

# Imports, alias, visibilidad y reexportación

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La declaración Importar nombra por ruta calificada un módulo o un símbolo. El primer segmento es el nombre del propio paquete o el alias de una dependencia declarada del paquete. Si la ruta completa nombra un módulo, importa el módulo y su nombre local es el alias de Como o, sin él, el último segmento; sus subprogramas públicos se invocan como nombre-local.Nombre(argumentos) y sus clases se importan por símbolo. Si todos los segmentos salvo el último nombran un módulo, importa el símbolo público de ese módulo con ese nombre, o con el alias de Como. Un alias solo cambia el nombre local, nunca la identidad del símbolo. Un primer segmento desconocido o un módulo inexistente produce unresolvedModule; un símbolo inexistente, unresolvedImport.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda unidad de nivel superior de un módulo (subprograma o clase) es privada salvo que lleve el prefijo Publico; el prefijo Privado explícito equivale a la ausencia de prefijo. Importar o reexportar un símbolo privado produce privateImport o privateReexport. La visibilidad de los miembros de una clase conserva su contrato propio.",
  "verificacion": [
    "C8",
    "C9",
    "C10"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los nombres locales de un módulo (unidades propias, símbolos importados y alias de módulo) son únicos. Dos orígenes con el mismo nombre local e identidades distintas producen importNameCollision; importar dos veces la misma identidad con el mismo nombre local es válido. Dos símbolos públicos con el mismo nombre en paquetes distintos son símbolos distintos y pueden convivir bajo alias distintos.",
  "verificacion": [
    "C11",
    "C12",
    "C13"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Exportar nombra por ruta calificada un símbolo público de otro módulo y lo añade a las exportaciones del módulo que lo declara, con la identidad original, sin crear un nombre local. Se pueden encadenar reexportaciones. Reexportar un símbolo privado produce privateReexport. Dos exportaciones con el mismo nombre e identidades distintas, propias o reexportadas, producen ambiguousReexport; reexportar dos veces la misma identidad es válido.",
  "verificacion": [
    "C14",
    "C15",
    "C16",
    "C17"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Importar y Exportar no ejecutan código ni observan efectos: el resultado de un proyecto es el mismo con o sin imports que no se usan. No existen comodines: tras un punto de la ruta se exige un nombre, y su ausencia produce expectedModuleName.",
  "verificacion": [
    "C18",
    "C19"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El grafo de importaciones tiene una arista desde el módulo que declara un Importar o un Exportar hacia el módulo que su ruta nombra: el módulo completo o el módulo que contiene el símbolo nombrado, exista o no ese símbolo. Varias declaraciones hacia el mismo módulo forman una sola arista, ubicada en la primera por orden de fuente; un módulo que se nombra a sí mismo es un ciclo. El grafo debe ser acíclico: cada componente cíclico produce un diagnóstico importCycle ubicado en la ruta de la primera arista que sale del módulo menor por orden de segmentos de ruta lógica, con el argumento lexeme igual a la cadena de nombres calificados unidos por ' -> ' y cerrada con ese módulo menor, y con un tramo relacionado por cada arista siguiente de la cadena. La cadena es el ciclo más corto desde el módulo menor hasta él mismo, desempatado por la menor secuencia de rutas lógicas, y no depende del orden de los archivos ni de las declaraciones. Los diagnósticos de ciclo se emiten ordenados por módulo menor. Con un ciclo solo se informan diagnósticos de enlace: no se analiza ningún cuerpo ni se produce programa. La recursión mutua de subprogramas dentro de un módulo no forma aristas y sigue siendo válida.",
  "verificacion": [
    "C20",
    "C21",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "C30"
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
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Doble Como D;\nAlgoritmo P\nEscribir D(4);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "8\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C2",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores Como V;\nAlgoritmo P\nEscribir V.Doble(5);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "10\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C3",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores;\nAlgoritmo P\nEscribir vectores.Doble(1);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "2\n",
            "diagnostics": [],
            "project_errors": []
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Doble Como Doble;\nAlgoritmo P\nEscribir Doble(1);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "2\n",
            "diagnostics": [],
            "project_errors": []
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "g": "geo"
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
                "text": "Importar g.vectores.Doble;\nAlgoritmo P\nEscribir Doble(3);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "6\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C6",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.nada.Doble;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "unresolvedModule"
              }
            ],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Nada;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "unresolvedImport"
              }
            ],
            "project_errors": []
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
  "regla": "R2",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Oculta;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "privateImport"
              }
            ],
            "project_errors": []
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
  "regla": "R2",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Oculta;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nPrivado SubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "privateImport"
              }
            ],
            "project_errors": []
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
  "id": "C10",
  "regla": "R2",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Caja;\nAlgoritmo P\nDefinir c Como Caja;\nc <- Nuevo Caja();\nEscribir c.valor();\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico Clase Caja\nMetodo Constructor()\nFinMetodo\nMetodo valor() Como Entero\nRetornar 5;\nFinMetodo\nFinClase\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "5\n",
            "diagnostics": [],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Doble;\nSubProceso Doble(n Como Entero) Como Entero\nRetornar n;\nFinSubProceso\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importNameCollision"
              }
            ],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Doble;\nImportar app.util.Doble;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              },
              {
                "path": "app/util",
                "source_id": 3,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n + 1;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importNameCollision"
              }
            ],
            "project_errors": []
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo",
                  "otro": "otro"
                }
              },
              {
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              },
              {
                "name": "otro",
                "root": "otro",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.vectores.Doble Como A;\nImportar otro.vectores.Doble Como B;\nAlgoritmo P\nEscribir A(1);\nEscribir B(1);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              },
              {
                "path": "otro/vectores",
                "source_id": 3,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 10;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "2\n10\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C14",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.puente.Doble;\nAlgoritmo P\nEscribir Doble(6);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/base",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              },
              {
                "path": "geo/puente",
                "source_id": 3,
                "text": "Exportar geo.base.Doble;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "12\n",
            "diagnostics": [],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              },
              {
                "path": "geo/puente",
                "source_id": 3,
                "text": "Exportar geo.vectores.Oculta;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "privateReexport"
              }
            ],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/base",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              },
              {
                "path": "geo/puente",
                "source_id": 3,
                "text": "Exportar geo.base.Doble;\nPublico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 3;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "ambiguousReexport"
              }
            ],
            "project_errors": []
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
  "id": "C17",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/base",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              },
              {
                "path": "geo/puente",
                "source_id": 3,
                "text": "Exportar geo.base.Doble;\nExportar geo.base.Doble;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [],
            "project_errors": []
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.Doble;\nImportar geo.vectores Como V;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "1\n",
            "diagnostics": [],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.vectores.*;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "expectedModuleName"
              }
            ],
            "project_errors": []
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
  "id": "C20",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar app.main;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "app.main -> app.main"
                },
                "related": []
              }
            ],
            "project_errors": []
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Importar geo.b;\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Importar geo.a;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.a -> geo.b -> geo.a"
                },
                "related": [
                  {}
                ]
              }
            ],
            "project_errors": []
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
  "id": "C22",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Importar geo.b;\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Importar geo.c;\n"
              },
              {
                "path": "geo/c",
                "source_id": 4,
                "text": "Importar geo.a;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.a -> geo.b -> geo.c -> geo.a"
                },
                "related": [
                  {},
                  {}
                ]
              }
            ],
            "project_errors": []
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
  "id": "C23",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Importar geo.c;\nImportar geo.b;\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Importar geo.d;\n"
              },
              {
                "path": "geo/c",
                "source_id": 4,
                "text": "Importar geo.d;\n"
              },
              {
                "path": "geo/d",
                "source_id": 5,
                "text": "Importar geo.a;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.a -> geo.b -> geo.d -> geo.a"
                },
                "related": [
                  {},
                  {}
                ]
              }
            ],
            "project_errors": []
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
  "id": "C24",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Importar geo.b;\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Importar geo.a;\n"
              },
              {
                "path": "geo/m",
                "source_id": 4,
                "text": "Importar geo.n;\n"
              },
              {
                "path": "geo/n",
                "source_id": 5,
                "text": "Importar geo.m;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.a -> geo.b -> geo.a"
                },
                "related": [
                  {}
                ]
              },
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.m -> geo.n -> geo.m"
                },
                "related": [
                  {}
                ]
              }
            ],
            "project_errors": []
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
  "id": "C25",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.izquierda Como I;\nImportar geo.derecha Como D;\nAlgoritmo P\nEscribir I.F() + D.F();\nFinAlgoritmo\n"
              },
              {
                "path": "geo/izquierda",
                "source_id": 2,
                "text": "Importar geo.base Como B;\nPublico SubProceso F() Como Entero\nRetornar B.F();\nFinSubProceso\n"
              },
              {
                "path": "geo/derecha",
                "source_id": 3,
                "text": "Importar geo.base Como B;\nPublico SubProceso F() Como Entero\nRetornar B.F();\nFinSubProceso\n"
              },
              {
                "path": "geo/base",
                "source_id": 4,
                "text": "Publico SubProceso F() Como Entero\nRetornar 1;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "2\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C26",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Importar geo.b.F;\nImportar geo.b.G;\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Importar geo.a;\nPublico SubProceso F() Como Entero\nRetornar 1;\nFinSubProceso\nPublico SubProceso G() Como Entero\nRetornar 1;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.a -> geo.b -> geo.a"
                },
                "related": [
                  {}
                ]
              }
            ],
            "project_errors": []
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
  "id": "C27",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Exportar geo.b.B1;\nPublico SubProceso A1() Como Entero\nRetornar 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "Exportar geo.a.A1;\nPublico SubProceso B1() Como Entero\nRetornar 2;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.a -> geo.b -> geo.a"
                },
                "related": [
                  {}
                ]
              }
            ],
            "project_errors": []
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
  "id": "C28",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.paridad Como P;\nAlgoritmo Q\nEscribir P.EsPar(10);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/paridad",
                "source_id": 2,
                "text": "Publico SubProceso EsPar(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 1;\nFinSi\nRetornar EsImpar(n - 1);\nFinSubProceso\nSubProceso EsImpar(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 0;\nFinSi\nRetornar EsPar(n - 1);\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "1\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C29",
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
        "operation": "execute_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Importar geo.m0 Como S;\nAlgoritmo P\nEscribir S.F();\nFinAlgoritmo\n"
              },
              {
                "path": "geo/m0",
                "source_id": 2,
                "text": "Importar geo.m1 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m1",
                "source_id": 3,
                "text": "Importar geo.m2 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m2",
                "source_id": 4,
                "text": "Importar geo.m3 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m3",
                "source_id": 5,
                "text": "Importar geo.m4 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m4",
                "source_id": 6,
                "text": "Importar geo.m5 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m5",
                "source_id": 7,
                "text": "Importar geo.m6 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m6",
                "source_id": 8,
                "text": "Importar geo.m7 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m7",
                "source_id": 9,
                "text": "Importar geo.m8 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m8",
                "source_id": 10,
                "text": "Importar geo.m9 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m9",
                "source_id": 11,
                "text": "Importar geo.m10 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m10",
                "source_id": 12,
                "text": "Importar geo.m11 Como S;\nPublico SubProceso F() Como Entero\nRetornar S.F() + 1;\nFinSubProceso\n"
              },
              {
                "path": "geo/m11",
                "source_id": 13,
                "text": "Publico SubProceso F() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "11\n",
            "diagnostics": [],
            "project_errors": []
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
  "id": "C30",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/m0",
                "source_id": 2,
                "text": "Importar geo.m1;\n"
              },
              {
                "path": "geo/m1",
                "source_id": 3,
                "text": "Importar geo.m2;\n"
              },
              {
                "path": "geo/m2",
                "source_id": 4,
                "text": "Importar geo.m3;\n"
              },
              {
                "path": "geo/m3",
                "source_id": 5,
                "text": "Importar geo.m4;\n"
              },
              {
                "path": "geo/m4",
                "source_id": 6,
                "text": "Importar geo.m5;\n"
              },
              {
                "path": "geo/m5",
                "source_id": 7,
                "text": "Importar geo.m6;\n"
              },
              {
                "path": "geo/m6",
                "source_id": 8,
                "text": "Importar geo.m7;\n"
              },
              {
                "path": "geo/m7",
                "source_id": 9,
                "text": "Importar geo.m8;\n"
              },
              {
                "path": "geo/m8",
                "source_id": 10,
                "text": "Importar geo.m9;\n"
              },
              {
                "path": "geo/m9",
                "source_id": 11,
                "text": "Importar geo.m10;\n"
              },
              {
                "path": "geo/m10",
                "source_id": 12,
                "text": "Importar geo.m11;\n"
              },
              {
                "path": "geo/m11",
                "source_id": 13,
                "text": "Importar geo.m0;\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto fija un único perfil; la forma en inglés de Importar y Exportar se verifica en los casos de texto suelto y en la ficha bilingüe de ayuda."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "arguments": {
                  "lexeme": "geo.m0 -> geo.m1 -> geo.m2 -> geo.m3 -> geo.m4 -> geo.m5 -> geo.m6 -> geo.m7 -> geo.m8 -> geo.m9 -> geo.m10 -> geo.m11 -> geo.m0"
                },
                "related": [
                  {},
                  {},
                  {},
                  {},
                  {},
                  {},
                  {},
                  {},
                  {},
                  {},
                  {}
                ]
              }
            ],
            "project_errors": []
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

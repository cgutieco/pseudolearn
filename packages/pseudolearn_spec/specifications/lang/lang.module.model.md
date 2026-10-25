---
{
  "formato": "see/1",
  "id": "LANG.MODULE.MODEL",
  "titulo": "Módulos, paquetes, workspace y entrada",
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
  "resumen": "Archivo como módulo, paquete, workspace local y entrada única.",
  "titulo_en": "Modules, packages, workspace and entry",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SOURCE.POSITION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Módulos, paquetes, workspace y entrada

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un archivo es un módulo. Un proyecto es un conjunto de paquetes; cada paquete tiene un nombre y una raíz lógica. Una ruta lógica usa segmentos separados por barra. Un módulo pertenece al paquete cuya raíz es un prefijo de segmentos de su ruta, y su nombre de módulo es el resto de la ruta con los segmentos unidos por puntos. Una ruta bajo dos raíces produce el error de proyecto moduleInMultipleRoots; una ruta bajo ninguna raíz, moduleOutsideRoots; un proyecto sin paquetes, emptyWorkspace; una dependencia que nombra un paquete inexistente, dependencyNotFound. Los errores de proyecto llevan un código estable y la ruta afectada, y no dependen del orden de los archivos.",
  "verificacion": [
    "C1",
    "C2",
    "C7",
    "C8",
    "C14"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un paquete es de aplicación o de biblioteca. Una biblioteca no declara entradas y ninguno de sus módulos exige un algoritmo; declarar entradas en una biblioteca produce noEntryInLibrary. Un paquete de aplicación declara entradas como rutas de módulo; una entrada nombra un módulo existente y se declara una sola vez (entryNotFound, entryDuplicated). Ejecutar exige que la petición seleccione exactamente una entrada (entryNotSelected). El módulo de entrada contiene exactamente un algoritmo (entryMissingAlgorithm) y ningún otro módulo del proyecto contiene un algoritmo (algorithmOutsideEntry).",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C9",
    "C10",
    "C11"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un texto suelto, sin proyecto, conserva el contrato de estructura de programa y no exige manifiesto ni migración al abrir. Las grafías de Importar y Exportar del perfil activo se reconocen como directivas de módulo solo en posición de unidad superior, donde producen moduleSyntaxOutsideProject; dentro de un programa suelto son identificadores válidos aunque también sean palabras reservadas del perfil. El prefijo de visibilidad de una unidad de nivel superior produce moduleSyntaxOutsideProject. El archivo vacío conserva expectedAlgorithmStart. Estas reglas no cambian los resultados previos de programas válidos.",
  "verificacion": [
    "C12",
    "C13",
    "C20",
    "C21"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El grafo de dependencias entre paquetes tiene una arista por dependencia declarada, desde el paquete que la declara hacia el paquete nombrado, y debe ser acíclico; una dependencia de un paquete sobre sí mismo es un ciclo. Cada componente cíclico produce un error de proyecto packageCycle cuya ruta es el nombre del paquete menor por orden de bytes y que lleva chain, la lista de nombres del ciclo más corto desde ese paquete hasta él mismo, desempatado por la menor secuencia de nombres, con el primer y el último nombre iguales. Los errores de ciclo no dependen del orden de paquetes ni de dependencias y se informan con los demás errores de proyecto.",
  "verificacion": [
    "C15",
    "C16",
    "C17",
    "C18",
    "C19"
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
                "text": "Importar app.util.Triple;\nImportar geo.vectores.Doble;\nAlgoritmo P\nEscribir Doble(21);\nEscribir Triple(3);\nFinAlgoritmo\n"
              },
              {
                "path": "app/util",
                "source_id": 2,
                "text": "Publico SubProceso Triple(n Como Entero) Como Entero\nRetornar n * 3;\nFinSubProceso\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 3,
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
            "output": "42\n9\n",
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
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "packages": [],
            "files": []
          }
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
            "project_errors": [
              {
                "code": "emptyWorkspace"
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

```caso
{
  "id": "C3",
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
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "geo/vectores",
                "source_id": 1,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          }
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
            "project_errors": [],
            "modules": [
              {
                "path": "geo/vectores",
                "package": "geo",
                "module": "vectores"
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

```caso
{
  "id": "C4",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "entryNotSelected"
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

```caso
{
  "id": "C5",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/nope"
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
            "project_errors": [
              {
                "code": "entryNotFound",
                "path": "app/nope"
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

```caso
{
  "id": "C6",
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
                  "app/main",
                  "app/main"
                ],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
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
            "project_errors": [
              {
                "code": "entryDuplicated",
                "path": "app/main"
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
                "kind": "library",
                "entries": [],
                "dependencies": {}
              },
              {
                "name": "sub",
                "root": "app/sub",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/sub/x",
                "source_id": 1,
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "moduleInMultipleRoots",
                "path": "app/sub/x"
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

```caso
{
  "id": "C8",
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
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "lib/x",
                "source_id": 1,
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "moduleOutsideRoots",
                "path": "lib/x"
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
                "name": "geo",
                "root": "geo",
                "kind": "library",
                "entries": [
                  "geo/vectores"
                ],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "geo/vectores",
                "source_id": 1,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\n"
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "noEntryInLibrary",
                "path": "geo/vectores"
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
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
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
            "diagnostics": [
              {
                "code": "entryMissingAlgorithm"
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
  "id": "C11",
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
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2 + Oculta();\nFinSubProceso\nSubProceso Oculta() Como Entero\nRetornar 0;\nFinSubProceso\nAlgoritmo Q\nFinAlgoritmo\n"
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
                "code": "algorithmOutsideEntry"
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
  "id": "C14",
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
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "g": "missing"
                }
              }
            ],
            "files": [
              {
                "path": "app/a",
                "source_id": 1,
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "dependencyNotFound",
                "path": "app"
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

```caso
{
  "id": "C12",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Importar a.b;\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "import a.b;\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "moduleSyntaxOutsideProject",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Publico SubProceso f()\nFinSubProceso\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "public subroutine f()\nendSubroutine\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "moduleSyntaxOutsideProject",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C20",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Importar Como Entero <- 1;\nDefinir Mutable Exportar Como Entero <- 0;\nDefinir Mutable import Como Entero <- 0;\nDefinir Mutable export Como Entero <- 0;\nExportar <- 2;\nimport <- 3;\nexport <- 4;\nEscribir Importar, Exportar, import, export;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine Importar as integer <- 1;\ndefine mutable Exportar as integer <- 0;\ndefine mutable import as integer <- 0;\ndefine mutable export as integer <- 0;\nExportar <- 2;\nimport <- 3;\nexport <- 4;\nwrite Importar, Exportar, import, export;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1234\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "",
    "en": ""
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedAlgorithmStart",
        "severidad": "error"
      }
    ]
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
                "dependencies": {
                  "app": "app"
                }
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
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "packageCycle",
                "path": "app",
                "chain": [
                  "app",
                  "geo",
                  "app"
                ]
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
                "dependencies": {
                  "yo": "geo"
                }
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
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "packageCycle",
                "path": "geo",
                "chain": [
                  "geo",
                  "geo"
                ]
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
                "name": "a",
                "root": "a",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "c",
                  "y": "b"
                }
              },
              {
                "name": "b",
                "root": "b",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "d"
                }
              },
              {
                "name": "c",
                "root": "c",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "d"
                }
              },
              {
                "name": "d",
                "root": "d",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "a"
                }
              }
            ],
            "files": [
              {
                "path": "a/m",
                "source_id": 1,
                "text": ""
              },
              {
                "path": "b/m",
                "source_id": 2,
                "text": ""
              },
              {
                "path": "c/m",
                "source_id": 3,
                "text": ""
              },
              {
                "path": "d/m",
                "source_id": 4,
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "packageCycle",
                "path": "a",
                "chain": [
                  "a",
                  "b",
                  "d",
                  "a"
                ]
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

```caso
{
  "id": "C18",
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
                "name": "a",
                "root": "a",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "b"
                }
              },
              {
                "name": "b",
                "root": "b",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "a"
                }
              },
              {
                "name": "m",
                "root": "m",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "n"
                }
              },
              {
                "name": "n",
                "root": "n",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "x": "m"
                }
              }
            ],
            "files": [
              {
                "path": "a/f",
                "source_id": 1,
                "text": ""
              },
              {
                "path": "b/f",
                "source_id": 2,
                "text": ""
              },
              {
                "path": "m/f",
                "source_id": 3,
                "text": ""
              },
              {
                "path": "n/f",
                "source_id": 4,
                "text": ""
              }
            ]
          }
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
            "project_errors": [
              {
                "code": "packageCycle",
                "path": "a",
                "chain": [
                  "a",
                  "b",
                  "a"
                ]
              },
              {
                "code": "packageCycle",
                "path": "m",
                "chain": [
                  "m",
                  "n",
                  "m"
                ]
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

```caso
{
  "id": "C19",
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
                  "l": "izq",
                  "r": "der"
                }
              },
              {
                "name": "izq",
                "root": "izq",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "b": "base"
                }
              },
              {
                "name": "der",
                "root": "der",
                "kind": "library",
                "entries": [],
                "dependencies": {
                  "b": "base"
                }
              },
              {
                "name": "base",
                "root": "base",
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
                "path": "izq/f",
                "source_id": 2,
                "text": ""
              },
              {
                "path": "der/f",
                "source_id": 3,
                "text": ""
              },
              {
                "path": "base/f",
                "source_id": 4,
                "text": ""
              }
            ]
          }
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
            "project_errors": [],
            "diagnostics": []
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

---
{
  "formato": "see/1",
  "id": "API.PROJECT",
  "titulo": "Operaciones públicas de proyecto",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Análisis y ejecución de un proyecto en memoria por la API pública.",
  "titulo_en": "Public project operations",
  "depende_de": [
    {
      "id": "LANG.MODULE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.MODULE.IMPORT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.WIRE-FORMAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-codex-2026-10-24"
  ]
}
---

# Operaciones públicas de proyecto

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones analyze_project y execute_project reciben profile, strictness, un proyecto y, opcionalmente, entry. El proyecto lleva project_id y revision_id como cadenas decimales u64, la lista de paquetes (name, root, kind application|library, entries, dependencies como mapa de alias a nombre de paquete) y la lista de archivos (path, source_id positivo y único, text y, opcionalmente, profile es|en). Las rutas usan el contrato de API.PROJECT.MANIFEST. Las referencias equivalentes por caja o NFC resuelven el mismo módulo; dos rutas de archivo con clave coincidente son un fallo de uso. Las entradas declaradas equivalentes por clave producen un solo error entryDuplicated por declaración repetida. La respuesta lleva diagnostics, ordenados por la regla DIAG.ORDERING con clave de paquete y módulo, y project_errors, ordenados por código y ruta, donde cada error de paquete en ciclo (packageCycle) lleva además chain, la lista de nombres de la cadena; cada diagnóstico de un archivo del proyecto lleva en su tramo la identidad project_id, revision_id y source_id de ese archivo. Una identidad de fuente desconocida es un fallo interno controlado y nunca se proyecta con coordenadas de otro archivo. analyze_project añade modules, ordenado por clave canónica, con path, package y module. execute_project ejecuta solo si diagnostics y project_errors están vacíos y añade output y termination como el resultado de un programa suelto; si no, devuelve únicamente los errores.",
  "verificacion": [
    "C1",
    "C2",
    "C8",
    "C11",
    "C12",
    "C13"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una petición de proyecto mal formada (campo ausente, tipo incorrecto, project_id no decimal, source_id repetido o cero, kind desconocido, profile de archivo desconocido, ruta lógica inválida, nombres de paquete que colisionan por NFC y minúsculas Unicode, o rutas de archivo, raíces de paquete o ubicaciones de manifiesto que colisionan por la clave portable) devuelve un fallo de uso y no produce diagnósticos ni errores de proyecto.",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C9",
    "C10",
    "C14",
    "C15",
    "C16"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada operación de proyecto analiza exclusivamente el snapshot completo recibido en esa llamada. project_id y revision_id identifican el proyecto y su revisión; no retienen overlays ni incorporan archivos, manifiestos o dependencias que no estén en la petición.",
  "verificacion": [
    "C17"
  ]
}
```

```caso
{
  "id": "C12",
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
                "name": "alpha",
                "root": "alpha",
                "kind": "application",
                "entries": [],
                "dependencies": {}
              },
              {
                "name": "zeta",
                "root": "zeta",
                "kind": "application",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "zeta/main",
                "source_id": 1,
                "text": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n"
              },
              {
                "path": "alpha/main",
                "source_id": 2,
                "text": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n"
              }
            ]
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "unrecognizedCharacter",
                "span": {
                  "source": {
                    "source_id": 2
                  }
                }
              },
              {
                "code": "unrecognizedCharacter",
                "span": {
                  "source": {
                    "source_id": 1
                  }
                }
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
                "text": "Algoritmo P\nFinAlgoritmo\n"
              },
              {
                "path": "geo/a",
                "source_id": 2,
                "text": "Importar geo.b;\n"
              },
              {
                "path": "geo/b",
                "source_id": 3,
                "text": "\n\nImportar geo.a;\n"
              }
            ]
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "importCycle",
                "span": {
                  "source": {
                    "source_id": 2
                  }
                },
                "related": [
                  {
                    "source": {
                      "source_id": 3
                    },
                    "start": {
                      "line": 3
                    }
                  }
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
  "id": "C11",
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
                  "app/main",
                  "APP/MAIN"
                ],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nFinAlgoritmo\n"
              }
            ]
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "project_errors": [
              {
                "code": "entryDuplicated",
                "path": "APP/MAIN"
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
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/../main",
                "source_id": 1,
                "text": ""
              }
            ]
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
    "engine"
  ]
}
```

```caso
{
  "id": "C7",
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
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/Modulo",
                "source_id": 1,
                "text": ""
              },
              {
                "path": "app/modulo",
                "source_id": 2,
                "text": ""
              }
            ]
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
                "name": "app",
                "root": "APP",
                "kind": "application",
                "entries": [
                  "APP/CAFÉ"
                ],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/café",
                "source_id": 1,
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/CAFÉ"
        }
      }
    ]
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
                "path": "app/café",
                "package": "app",
                "module": "café"
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
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/CON",
                "source_id": 1,
                "text": ""
              }
            ]
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
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/Foo/a",
                "source_id": 1,
                "text": ""
              },
              {
                "path": "app/foo/b",
                "source_id": 2,
                "text": ""
              }
            ]
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
    "engine"
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
                "code": "unresolvedModule",
                "span": {
                  "source": {
                    "project_id": "1",
                    "revision_id": "1",
                    "source_id": 1
                  }
                }
              }
            ],
            "project_errors": [],
            "modules": [
              {
                "path": "app/main",
                "package": "app",
                "module": "main"
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
                "text": "Importar geo.nada.Doble;\nAlgoritmo P\nEscribir 1;\nFinAlgoritmo\n"
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
                "source_id": 1,
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
                "kind": "binario",
                "entries": [
                  "app/main"
                ],
                "dependencies": {
                  "geo": "geo"
                }
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
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
                  "lib": "lib"
                }
              },
              {
                "name": "lib",
                "root": "lib",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
                "profile": "fr"
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
  "id": "C14",
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
                "root": "Libs/Geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              },
              {
                "name": "geography",
                "root": "libs/geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": []
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
    "engine"
  ]
}
```


```caso
{
  "id": "C15",
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
                "name": "Geo",
                "root": "libs/geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              },
              {
                "name": "geo",
                "root": "vendor/geo",
                "kind": "library",
                "entries": [],
                "dependencies": {}
              }
            ],
            "files": []
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
    "engine"
  ]
}
```

```caso
{
  "id": "C16",
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
            "manifests": [
              {
                "location": "Libs/Geo",
                "text": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n"
              },
              {
                "location": "libs/geo",
                "text": "schema = 1\n[package]\nname = \"geography\"\nkind = \"library\"\n"
              }
            ],
            "files": []
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
    "engine"
  ]
}
```

```caso
{
  "id": "C17",
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
            "project_id": "9",
            "revision_id": "1",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": ["app/main"],
                "dependencies": {}
              }
            ],
            "files": [
              {"path": "app/main", "source_id": 1, "text": "Algoritmo P\nFinAlgoritmo\n"}
            ]
          }
        }
      },
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "9",
            "revision_id": "2",
            "packages": [
              {
                "name": "app",
                "root": "app",
                "kind": "application",
                "entries": ["app/main"],
                "dependencies": {}
              }
            ],
            "files": [
              {"path": "app/main", "source_id": 1, "text": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"}
            ]
          }
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {"value": {"diagnostics": [], "project_errors": []}},
        {"value": {"diagnostics": [], "project_errors": []}}
      ]
    }
  },
  "sujetos": [
    "engine"
  ]
}
```

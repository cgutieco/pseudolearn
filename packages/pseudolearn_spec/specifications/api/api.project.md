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
  "revisado_por": []
}
---

# Operaciones públicas de proyecto

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones analyze_project y execute_project reciben profile, strictness, un proyecto y, opcionalmente, entry. El proyecto lleva project_id y revision_id como cadenas decimales u64, la lista de paquetes (name, root, kind application|library, entries, dependencies como mapa de alias a nombre de paquete) y la lista de archivos (path, source_id positivo y único, text). La respuesta lleva diagnostics, ordenados por la regla local de diagnósticos, y project_errors, ordenados por código y ruta, donde cada error de paquete en ciclo (packageCycle) lleva además chain, la lista de nombres de la cadena; cada diagnóstico de un archivo del proyecto lleva en su tramo la identidad project_id, revision_id y source_id de ese archivo. analyze_project añade modules, ordenado por ruta, con path, package y module. execute_project ejecuta solo si diagnostics y project_errors están vacíos y añade output y termination como el resultado de un programa suelto; si no, devuelve únicamente los errores.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una petición de proyecto mal formada (campo ausente, tipo incorrecto, project_id no decimal, source_id repetido o cero, kind desconocido) devuelve un fallo de uso y no produce diagnósticos ni errores de proyecto.",
  "verificacion": [
    "C3",
    "C4"
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


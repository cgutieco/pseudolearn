---
{
  "formato": "see/1",
  "id": "LANG.PROFILE.MODEL",
  "titulo": "Modelo de perfiles oficiales",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Modelo de perfiles oficiales.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.LEXICAL.KEYWORD",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Modelo de perfiles oficiales

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los vocabularios oficiales son español clásico e inglés. Cada uno cubre el mismo inventario de tokens y funciones. Vocabulario y rigor son ejes independientes: reimprimir cambia lexemas, y desactivar exigencias amplía validez sin cambiar el resultado de programas ya válidos. Precedencia, base cero, tipos y orden de evaluación son invariantes del lenguaje.",
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
  "texto": "En un proyecto cada archivo tiene su propio perfil. Lo determina, de mayor a menor precedencia: el campo profile del archivo en la petición; la excepción de [profiles] del manifiesto para su ruta o su directorio más cercano; el profile declarado de su paquete en el manifiesto; el vocabulario que declara inequívocamente su apertura (Algoritmo, Clase, SubProceso y sus equivalentes); el argumento profile de la petición y, por último, es. Si un perfil configurado por alguno de los tres primeros niveles contradice la apertura inequívoca del archivo, se produce profileMismatch, con el perfil configurado y su procedencia y el perfil de la apertura en el argumento lexeme; el archivo se analiza con el perfil de su apertura. Un archivo sin apertura inequívoca, como una biblioteca, usa el perfil configurado. Cada operación de salida de valores formatea los lógicos con el perfil del archivo que contiene esa operación, también al ejecutarse desde otro archivo de perfil distinto. La traducción de perfil es una operación sobre un solo archivo y no renombra símbolos importados. El idioma de la interfaz no interviene en esta resolución.",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8"
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
  "programas": {
    "es": "Algoritmo P\nEscribir 1 + 2;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 + 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1 + Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 + true;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
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
                "text": "Importar lib.util Como U;\nAlgoritmo P\nU.Informe();\nEscribir 1 = 1;\nFinAlgoritmo\n",
                "profile": "es"
              },
              {
                "path": "lib/util",
                "source_id": 2,
                "text": "public subroutine Informe()\nwrite 1 = 1;\nendSubroutine\n",
                "profile": "en"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto declara el perfil de cada archivo con datos; el mismo comportamiento en inglés se ejerce en las direcciones es→en y en→es de este mismo contrato."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "true\nVerdadero\n",
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
          "profile": "en",
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
                "text": "import lib.util as U;\nalgorithm P\nU.Informe();\nwrite 1 = 1;\nendAlgorithm\n",
                "profile": "en"
              },
              {
                "path": "lib/util",
                "source_id": 2,
                "text": "Publico SubProceso Informe()\nEscribir 1 = 1;\nFinSubProceso\n",
                "profile": "es"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto declara el perfil de cada archivo con datos; el mismo comportamiento en inglés se ejerce en las direcciones es→en y en→es de este mismo contrato."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "Verdadero\ntrue\n",
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
            "manifests": [
              {
                "location": "app",
                "text": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nprofile = \"en\"\nentries = [\"app/main\"]\n[profiles]\n\"app/util\" = \"es\"\n"
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "import app.util as U;\nalgorithm P\nU.Informe();\nwrite 1 = 1;\nendAlgorithm\n"
              },
              {
                "path": "app/util",
                "source_id": 2,
                "text": "Publico SubProceso Informe()\nEscribir 1 = 1;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto declara el perfil de cada archivo con datos; el mismo comportamiento en inglés se ejerce en las direcciones es→en y en→es de este mismo contrato."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "Verdadero\ntrue\n",
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
                "profile": "en"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto declara el perfil de cada archivo con datos; el mismo comportamiento en inglés se ejerce en las direcciones es→en y en→es de este mismo contrato."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [
              {
                "code": "profileMismatch",
                "arguments": {
                  "lexeme": "en (argument) <> es (opening)"
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
        "operation": "execute_project",
        "arguments": {
          "profile": "en",
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
                "text": "Algoritmo P\nEscribir 1 = 1;\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "La petición de proyecto declara el perfil de cada archivo con datos; el mismo comportamiento en inglés se ejerce en las direcciones es→en y en→es de este mismo contrato."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "Verdadero\n",
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
    "en": "La petición de proyecto declara el perfil de cada archivo con datos; el mismo comportamiento en inglés se ejerce en las direcciones es→en y en→es de este mismo contrato."
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

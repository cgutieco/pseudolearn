---
{
  "formato": "see/1",
  "id": "API.PROJECT.MANIFEST",
  "titulo": "Manifiesto declarativo de paquete y autoridad externa",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Manifiesto de paquete como datos, configuración resuelta con procedencia y autoridad concedida por el anfitrión.",
  "titulo_en": "Declarative package manifest and external authority",
  "depende_de": [
    {
      "id": "API.PROJECT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.MODULE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-codex-2026-10-24"
  ]
}
---

# Manifiesto declarativo de paquete y autoridad externa

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un manifiesto es un texto en un subconjunto estricto de TOML: comentarios con #, tablas [a] y [a.b], claves desnudas (letras ASCII, dígitos, guion y guion bajo) o entre comillas, cadenas entre comillas dobles con los escapes \\\" \\\\ \\n \\t y \\uXXXX, enteros decimales sin signo, arreglos y tablas en línea. No admite booleanos, flotantes, fechas, arreglos de tablas ni claves con punto. Una clave repetida en una tabla o una tabla definida dos veces produce duplicateKey; una forma fuera del subconjunto produce manifestSyntax; un texto sin clave ni tabla alguna (vacío o solo espacios y comentarios) produce manifestEmpty; un texto mayor que el presupuesto de bytes del anfitrión produce manifestTooLarge. Cada error lleva code, field (los nombres de la ruta unidos por punto, con [n] para el elemento n de un arreglo), line y column, desde 1 y contadas en caracteres, del punto donde empieza el elemento afectado, y se ordenan por línea, columna, código y field. Los errores de esta regla se informan solos: sin un manifiesto bien formado no se valida el esquema.",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C27"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El esquema versión 1 admite: schema, entero obligatorio igual a 1 (otro valor produce unsupportedSchema); la tabla package con name (cadena no vacía, obligatoria), kind (application o library, obligatorio), profile (es o en; por defecto es) y entries (arreglo de rutas lógicas; por defecto vacío); la tabla profiles, de ruta lógica del paquete a es o en; la tabla dependencies, de alias a una tabla en línea con package (cadena no vacía); y la tabla requests con limits (depth, statements, cells y micro_steps, enteros positivos) y permissions (arreglo de cadenas). Toda ruta lógica es relativa, no vacía y usa /; rechaza componentes vacíos, . y .., barras inversas, raíces o unidades absolutas, controles, caracteres reservados portables, nombres de dispositivo y componentes terminados en punto o espacio. Sus segmentos se normalizan a NFC conservando caja. La clave de comparación aplica minúsculas Unicode a NFC; dos rutas distintas que colisionan, incluidos directorios implícitos y las entradas repetidas por clave, producen invalidPath. Una referencia con otra caja o forma Unicode equivalente resuelve la ruta canónica. Cualquier otra clave, incluidas edition, language y ui, produce unknownField: el manifiesto no elige edición ni idioma de interfaz. Un valor de tipo o contenido inválido produce invalidValue; una ruta de entrada o de perfil que no es una ruta lógica, colisiona o no está bajo la raíz del paquete, invalidPath; un campo obligatorio ausente, missingField, ubicado en la cabecera de su tabla o en la línea 1 columna 1 si es de la raíz. La raíz del paquete es la ubicación del manifiesto y no se escribe en él.",
  "verificacion": [
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C23",
    "C24"
  ]
}
```

```caso
{
  "id": "C23",
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\", \"APP/MAIN\"]\n",
          "location": "app"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "invalidPath",
                "field": "package.entries[1]"
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
  "id": "C24",
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"app\"\nkind = \"library\"\n[profiles]\n\"app/file\" = \"es\"\n\"APP/FILE\" = \"en\"\n",
          "location": "app"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "invalidPath",
                "field": "profiles.app/file"
              },
              {
                "code": "invalidPath",
                "field": "profiles.APP/FILE"
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
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La configuración resuelta contiene schema; para cada campo del paquete (name, root, kind, profile, entries) su value y su provenance; las excepciones de perfil y las dependencias, ordenadas por ruta y por alias, con su procedencia; los límites solicitados con su autoridad; y permissions. La procedencia es manifest con line y column del valor, default si el campo se omitió, location para la raíz o host para un valor recortado por una concesión. La resolución es una función pura del texto, la ubicación y las concesiones: no lee archivos ni ejecuta nada. Las excepciones de perfil se resuelven como datos; su aplicación al análisis por archivo no forma parte de esta regla.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El anfitrión concede techos de límites mediante grants.limits. Para cada límite solicitado en requests.limits el valor effective es el menor entre la solicitud (requested) y la concesión (granted), con procedencia manifest si la solicitud no supera la concesión y host si la concesión la recorta; el valor efectivo nunca supera la solicitud ni la concesión. Un límite solicitado sin concesión produce limitNotGranted en la línea y columna de su valor y no se aplica; un límite no solicitado no se aplica aunque exista una concesión. El vocabulario de permisos está cerrado y vacío: cualquier permiso solicitado produce unknownPermission, y ningún contenido del proyecto concede nada.",
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
  "texto": "La operación resolve_manifest recibe manifest, location y, opcionalmente, grants, y devuelve configuration y manifest_errors; configuration es nulo si hay errores. Una location que no es una ruta lógica es un fallo de uso. Las operaciones analyze_project y execute_project aceptan en el proyecto manifests (lista de location y text) en lugar de packages, y opcionalmente grants; recibir ambos o ninguno es un fallo de uso. Las ubicaciones de manifiesto que colisionan por la clave portable son un fallo de uso. Los paquetes se derivan de los manifiestos con la raíz igual a su ubicación normalizada a NFC; los errores de manifiesto se devuelven en manifest_errors con la ubicación documental canónica en NFC y bloquean el análisis y la ejecución. La lista se ordena por clave portable de ubicación y, dentro de cada documento, por línea, columna, código y field. execute_project aplica a la ejecución los límites efectivos del paquete que contiene la entrada. Abrir, analizar o ejecutar un proyecto no ejecuta scripts ni concede permisos por su contenido, y el resultado no depende del idioma de interfaz.",
  "verificacion": [
    "C18",
    "C19",
    "C20",
    "C21",
    "C22",
    "C25",
    "C26"
  ]
}
```

```caso
{
  "id": "C1",
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "# Paquete de la aplicación\nschema = 1\n\n[package]\nname = \"app\"\nkind = \"application\"\nprofile = \"en\"\nentries = [\"app/main\"]\n\n[profiles]\n\"app/legacy\" = \"es\"\n\n[dependencies]\ngeo = { package = \"geo\" }\n\n[requests.limits]\ndepth = 200\nstatements = 1000\n\n[requests]\npermissions = []\n",
          "location": "app",
          "grants": {
            "limits": {
              "depth": 500,
              "statements": 500
            }
          }
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "manifest_errors": [],
            "configuration": {
              "schema": 1,
              "package": {
                "name": {
                  "value": "app",
                  "provenance": {
                    "source": "manifest",
                    "line": 5,
                    "column": 8
                  }
                },
                "root": {
                  "value": "app",
                  "provenance": {
                    "source": "location"
                  }
                },
                "kind": {
                  "value": "application",
                  "provenance": {
                    "source": "manifest",
                    "line": 6,
                    "column": 8
                  }
                },
                "profile": {
                  "value": "en",
                  "provenance": {
                    "source": "manifest",
                    "line": 7,
                    "column": 11
                  }
                },
                "entries": {
                  "value": [
                    "app/main"
                  ],
                  "provenance": {
                    "source": "manifest",
                    "line": 8,
                    "column": 11
                  }
                }
              },
              "profiles": [
                {
                  "path": "app/legacy",
                  "profile": "es",
                  "provenance": {
                    "source": "manifest",
                    "line": 11,
                    "column": 16
                  }
                }
              ],
              "dependencies": [
                {
                  "alias": "geo",
                  "package": "geo",
                  "provenance": {
                    "source": "manifest",
                    "line": 14,
                    "column": 7
                  }
                }
              ],
              "limits": {
                "depth": {
                  "requested": 200,
                  "granted": 500,
                  "effective": 200,
                  "provenance": {
                    "source": "manifest",
                    "line": 17,
                    "column": 9
                  }
                },
                "statements": {
                  "requested": 1000,
                  "granted": 500,
                  "effective": 500,
                  "provenance": {
                    "source": "host"
                  }
                }
              },
              "permissions": []
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
  "id": "C2",
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
          "location": "geo"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "manifest_errors": [],
            "configuration": {
              "schema": 1,
              "package": {
                "name": {
                  "value": "geo",
                  "provenance": {
                    "source": "manifest",
                    "line": 3,
                    "column": 8
                  }
                },
                "root": {
                  "value": "geo",
                  "provenance": {
                    "source": "location"
                  }
                },
                "kind": {
                  "value": "library",
                  "provenance": {
                    "source": "manifest",
                    "line": 4,
                    "column": 8
                  }
                },
                "profile": {
                  "value": "es",
                  "provenance": {
                    "source": "default"
                  }
                },
                "entries": {
                  "value": [],
                  "provenance": {
                    "source": "default"
                  }
                }
              },
              "profiles": [],
              "dependencies": [],
              "limits": {},
              "permissions": []
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "manifestEmpty",
                "field": "",
                "line": 1,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "# nada\n\n   \n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "manifestEmpty",
                "field": "",
                "line": 1,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema 1\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "manifestSyntax",
                "field": "",
                "line": 1,
                "column": 8
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\nschema = 1\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "duplicateKey",
                "field": "schema",
                "line": 2,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\n[package]\nkind = \"library\"\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "duplicateKey",
                "field": "package",
                "line": 4,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\nedition = \"2027\"\n[package]\nname = \"a\"\nkind = \"library\"\nlanguage = \"es\"\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "unknownField",
                "field": "edition",
                "line": 2,
                "column": 1
              },
              {
                "code": "unknownField",
                "field": "package.language",
                "line": 6,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 2\n[package]\nname = \"a\"\nkind = \"library\"\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "unsupportedSchema",
                "field": "schema",
                "line": 1,
                "column": 10
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "[package]\nname = \"a\"\nkind = \"library\"\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "missingField",
                "field": "schema",
                "line": 1,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nkind = \"library\"\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "missingField",
                "field": "package.name",
                "line": 2,
                "column": 1
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\nkind = \"service\"\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "invalidValue",
                "field": "package.kind",
                "line": 4,
                "column": 8
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
  "id": "C13",
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"../x\", \"otra/main\", \"app/main\"]\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "invalidPath",
                "field": "package.entries[0]",
                "line": 5,
                "column": 12
              },
              {
                "code": "invalidPath",
                "field": "package.entries[1]",
                "line": 5,
                "column": 20
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests]\npermissions = [\"net\"]\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "unknownPermission",
                "field": "requests.permissions[0]",
                "line": 6,
                "column": 16
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests.limits]\ndepth = 50\n",
          "location": "app"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "limitNotGranted",
                "field": "requests.limits.depth",
                "line": 6,
                "column": 9
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests.limits]\ndepth = 50\n",
          "location": "a",
          "grants": {
            "limits": {
              "depth": 80
            }
          }
        }
      },
      {
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests.limits]\ndepth = 50\n",
          "location": "a",
          "grants": {
            "limits": {
              "depth": 20
            }
          }
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "manifest_errors": [],
            "configuration": {
              "limits": {
                "depth": {
                  "requested": 50,
                  "granted": 80,
                  "effective": 50,
                  "provenance": {
                    "source": "manifest",
                    "line": 6,
                    "column": 9
                  }
                }
              }
            }
          }
        },
        {
          "value": {
            "manifest_errors": [],
            "configuration": {
              "limits": {
                "depth": {
                  "requested": 50,
                  "granted": 20,
                  "effective": 20,
                  "provenance": {
                    "source": "host"
                  }
                }
              }
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"a\"\nkind = \"library\"\n[requests.limits]\ncells = 10\n",
          "location": "a",
          "grants": {
            "limits": {
              "depth": 80
            }
          }
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {
                "code": "limitNotGranted",
                "field": "requests.limits.cells",
                "line": 6,
                "column": 9
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
            "manifests": [
              {
                "location": "app",
                "text": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n"
              },
              {
                "location": "geo",
                "text": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n"
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.vectores Como V;\nAlgoritmo P\nEscribir V.Doble(21);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "output": "42\n",
            "diagnostics": [],
            "project_errors": [],
            "manifest_errors": []
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
            "manifests": [
              {
                "location": "app",
                "text": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n"
              },
              {
                "location": "geo",
                "text": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n"
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.vectores Como V;\nAlgoritmo P\nEscribir V.Doble(21);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              }
            ],
            "packages": []
          }
        }
      },
      {
        "operation": "analyze_project",
        "arguments": {
          "profile": "es",
          "strictness": "strict",
          "project": {
            "project_id": "1",
            "revision_id": "1",
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.vectores Como V;\nAlgoritmo P\nEscribir V.Doble(21);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              }
            ]
          }
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
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
    "engine"
  ]
}
```

```caso
{
  "id": "C20",
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
            "manifests": [
              {
                "location": "app",
                "text": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[requests.limits]\nstatements = 5\n"
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nMientras Verdadero Hacer\nEscribir 1;\nFinMientras\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/main",
          "grants": {
            "limits": {
              "statements": 5
            }
          }
        }
      },
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
                "text": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[requests.limits]\nstatements = 5\n"
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Algoritmo P\nMientras Verdadero Hacer\nEscribir 1;\nFinMientras\nFinAlgoritmo\n"
              }
            ]
          },
          "entry": "app/main"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "termination": {
              "kind": "limit_reached",
              "limit": "statements"
            },
            "manifest_errors": []
          }
        },
        {
          "value": {
            "manifest_errors": [
              {
                "code": "limitNotGranted",
                "field": "requests.limits.statements",
                "line": 7,
                "column": 14
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
  "id": "C21",
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
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
          "location": "../x"
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
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
  "id": "C22",
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
            "manifests": [
              {
                "location": "app",
                "text": "schema = 1\n[package]\nname = \"app\"\n"
              },
              {
                "location": "geo",
                "text": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n"
              }
            ],
            "files": [
              {
                "path": "app/main",
                "source_id": 1,
                "text": "Importar geo.vectores Como V;\nAlgoritmo P\nEscribir V.Doble(21);\nFinAlgoritmo\n"
              },
              {
                "path": "geo/vectores",
                "source_id": 2,
                "text": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
              }
            ]
          }
        }
      }
    ]
  },
  "exclusiones": {
    "en": "El manifiesto no depende del perfil del lenguaje: sus datos y errores no contienen palabras de ningún perfil."
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "diagnostics": [],
            "project_errors": [],
            "manifest_errors": [
              {
                "location": "app",
                "code": "missingField",
                "field": "package.kind",
                "line": 2,
                "column": 1
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
  "id": "C25",
  "regla": "R5",
  "perfiles": ["es"],
  "rigor": ["estricto"],
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
              {"location": "Zeta", "text": "schema = 1\n[package]\n"},
              {"location": "café", "text": "schema = 1\n[package]\n"}
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
          "value": {
            "diagnostics": [],
            "project_errors": [],
            "manifest_errors": [
              {"location": "café", "code": "missingField", "field": "package.kind", "line": 2, "column": 1},
              {"location": "café", "code": "missingField", "field": "package.name", "line": 2, "column": 1},
              {"location": "Zeta", "code": "missingField", "field": "package.kind", "line": 2, "column": 1},
              {"location": "Zeta", "code": "missingField", "field": "package.name", "line": 2, "column": 1}
            ]
          }
        }
      ]
    }
  },
  "sujetos": ["engine"]
}
```

```caso
{
  "id": "C26",
  "regla": "R5",
  "perfiles": ["es"],
  "rigor": ["estricto"],
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
              {"location": "Café", "text": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n"},
              {"location": "café", "text": "schema = 1\n[package]\nname = \"geography\"\nkind = \"library\"\n"}
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
        {"failure": {"family": "usage"}}
      ]
    }
  },
  "sujetos": ["engine"]
}
```


```caso
{
  "id": "C27",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "api",
  "api": {
    "calls": [
      {
        "operation": "resolve_manifest",
        "arguments": {
          "manifest": "schema = 1\n[package]\n",
          "location": "app"
        }
      }
    ]
  },
  "espera": {
    "api": {
      "results": [
        {
          "value": {
            "configuration": null,
            "manifest_errors": [
              {"code": "missingField", "field": "package.kind", "line": 2, "column": 1, "location": "app"},
              {"code": "missingField", "field": "package.name", "line": 2, "column": 1, "location": "app"}
            ]
          }
        }
      ]
    }
  },
  "sujetos": ["engine"]
}
```

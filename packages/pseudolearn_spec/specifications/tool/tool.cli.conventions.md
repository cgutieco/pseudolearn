---
{
  "formato": "see/1",
  "id": "TOOL.CLI.CONVENTIONS",
  "titulo": "Convenciones de la CLI",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Órdenes y opciones bilingües, vocabulario autodeclarado, idioma de interfaz y códigos de salida.",
  "depende_de": [
    {
      "id": "API.PROJECT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.PROJECT.MANIFEST",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.PROJECT.LOCK",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.WIRE-FORMAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "CLI conventions",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Convenciones de la CLI

```definicion
{
  "id": "D1",
  "termino": "cliConventions",
  "texto": "Códigos de salida de la CLI e identidades de vocabulario que abren una unidad de nivel superior.",
  "valor": {
    "codigos_salida": {
      "0": "éxito",
      "1": "el programa tiene errores o falló",
      "2": "uso incorrecto",
      "3": "error operativo"
    },
    "aperturas": [
      "algorithm",
      "classKeyword",
      "subroutine"
    ]
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El binario es pseudo. Sus órdenes canónicas son en español: comprobar, ejecutar, compilar, ri y preferencias; check, run, build, ir y preferences son alias que se aceptan siempre, con cualquier idioma de interfaz, y producen exactamente el mismo resultado que la forma canónica.",
  "verificacion": [
    "C1",
    "C2",
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: orden desconocida «volar»\n"
  },
  "cli": {
    "argumentos": [
      "volar"
    ],
    "entorno": {}
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta el archivo de entrada\n"
  },
  "cli": {
    "argumentos": [
      "run"
    ],
    "entorno": {}
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta el archivo de entrada\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar"
    ],
    "entorno": {}
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta la orden; use pseudo --ayuda\n"
  },
  "cli": {
    "argumentos": [],
    "entorno": {}
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las opciones son --ayuda (--help), --idioma (--language) con es o en, --rigor (--strictness) con estricto o flexible y alias strict o flexible, --vocabulario (--vocabulary) con es o en, --traza (--trace), --semilla (--seed), --profundidad (--depth), --sentencias (--statements), --celdas (--cells), --salida (--output, -o) y --json. Los alias se aceptan siempre. El rigor por omisión es estricto. Una opción desconocida o un valor no válido es un uso incorrecto.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Uso: pseudo <orden> [opciones] <archivo>...\nÓrdenes: comprobar (check), ejecutar (run), ri (ir), preferencias (preferences)\nOpciones: --ayuda (--help), --idioma (--language), --rigor (--strictness), --vocabulario (--vocabulary), --traza (--trace), --semilla (--seed), --profundidad (--depth), --sentencias (--statements), --celdas (--cells), --json\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "--ayuda"
    ],
    "entorno": {}
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Uso: pseudo <orden> [opciones] <archivo>...\nÓrdenes: comprobar (check), ejecutar (run), ri (ir), preferencias (preferences)\nOpciones: --ayuda (--help), --idioma (--language), --rigor (--strictness), --vocabulario (--vocabulary), --traza (--trace), --semilla (--seed), --profundidad (--depth), --sentencias (--statements), --celdas (--cells), --json\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "--help"
    ],
    "entorno": {}
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: opción desconocida «--volumen»\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--volumen",
      "p.pseudo"
    ],
    "entorno": {}
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: valor no válido «medio» para --rigor\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--rigor",
      "medio",
      "p.pseudo"
    ],
    "entorno": {}
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El vocabulario de un archivo se autodeclara: la primera palabra significativa después del BOM y la trivia es la apertura de una unidad de nivel superior de uno de los perfiles, y ese perfil se usa. --vocabulario lo fuerza. Si la apertura no se reconoce y no se fuerza, se usa el español, que informa su diagnóstico de inicio. Ninguna apertura comparte lexema ni alias con el otro perfil.",
  "verificacion": [
    "C9",
    "C10",
    "C11"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "p.pseudo:2:7: error: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "algorithm P\nwrite total;\nendAlgorithm\n"
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "// comentario\nSubProceso f()\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "vacio.pseudo:1:1: error: Se esperaba el inicio del algoritmo [expectedAlgorithmStart]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "vacio.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "vacio.pseudo": ""
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El idioma de interfaz lo decide la primera fuente que da es o en: --idioma; PSEUDO_IDIOMA o su alias PSEUDO_LANGUAGE; el archivo de preferencias; el idioma del sistema, tomado de la primera variable no vacía entre LC_ALL, LC_MESSAGES y LANG; y por último el español. Ni el archivo fuente, ni su vocabulario, ni la forma en que se escribió la orden intervienen. El idioma de interfaz nunca cambia la salida del programa ni el JSON.",
  "verificacion": [
    "C12",
    "C13",
    "C14",
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
  "id": "C12",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: unknown command 'volar'\n"
  },
  "cli": {
    "argumentos": [
      "volar",
      "--idioma",
      "en"
    ],
    "entorno": {}
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: unknown command 'volar'\n"
  },
  "cli": {
    "argumentos": [
      "volar"
    ],
    "entorno": {
      "PSEUDO_IDIOMA": "en"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: unknown command 'volar'\n"
  },
  "cli": {
    "argumentos": [
      "volar"
    ],
    "entorno": {
      "PSEUDO_LANGUAGE": "en"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: orden desconocida «volar»\n"
  },
  "cli": {
    "argumentos": [
      "volar",
      "--language",
      "es"
    ],
    "entorno": {
      "PSEUDO_IDIOMA": "en"
    }
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: unknown command 'volar'\n"
  },
  "cli": {
    "argumentos": [
      "volar"
    ],
    "entorno": {
      "LANG": "en_US.UTF-8"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: orden desconocida «volar»\n"
  },
  "cli": {
    "argumentos": [
      "volar"
    ],
    "entorno": {
      "LC_ALL": "fr_FR.UTF-8",
      "LANG": "en_US.UTF-8"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: unknown command 'volar'\n"
  },
  "cli": {
    "argumentos": [
      "volar"
    ],
    "entorno": {
      "XDG_CONFIG_HOME": "cfg"
    },
    "archivos": {
      "cfg/pseudolearn/preferencias.toml": "idioma = \"en\"\n"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Usage: pseudo <command> [options] <file>...\nCommands: check (comprobar), run (ejecutar), ir (ri), preferences (preferencias)\nOptions: --help (--ayuda), --language (--idioma), --strictness (--rigor), --vocabulary (--vocabulario), --trace (--traza), --seed (--semilla), --depth (--profundidad), --statements (--sentencias), --cells (--celdas), --json\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "--help",
      "--language",
      "en"
    ],
    "entorno": {}
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida sigue D1: 0 éxito; 1 el programa tiene errores o su ejecución no terminó con completed; 2 uso incorrecto; 3 error operativo, como un archivo ilegible.",
  "verificacion": [
    "C20"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: no se puede leer falta.pseudo\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "falta.pseudo"
    ],
    "entorno": {}
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "--json escribe en la salida estándar únicamente el resultado en el JSON canónico de API.WIRE-FORMAT, con las mismas claves para cualquier idioma de interfaz.",
  "verificacion": [
    "C21",
    "C22"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "json": {
      "files": [
        {
          "path": "p.pseudo",
          "diagnostics": []
        }
      ]
    },
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--json",
      "--idioma",
      "es",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "json": {
      "files": [
        {
          "path": "p.pseudo",
          "diagnostics": []
        }
      ]
    },
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--json",
      "--idioma",
      "en",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las preferencias se guardan en un archivo declarativo de datos, preferencias.toml, en el directorio pseudolearn de $XDG_CONFIG_HOME si está definida o del directorio de configuración del usuario de la plataforma. Su único contenido admitido es idioma = \"es\" o idioma = \"en\". Se escribe con pseudo preferencias idioma <es|en> y nunca se ejecuta código para leerlo.",
  "verificacion": [
    "C23",
    "C24"
  ]
}
```

```caso
{
  "id": "C23",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "pseudo: idioma de interfaz guardado: en\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "preferencias",
      "idioma",
      "en"
    ],
    "entorno": {
      "XDG_CONFIG_HOME": "cfg"
    }
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R7",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: valor no válido «fr» para idioma\n"
  },
  "cli": {
    "argumentos": [
      "preferences",
      "language",
      "fr"
    ],
    "entorno": {
      "XDG_CONFIG_HOME": "cfg"
    }
  }
}
```

## Entorno de los casos

Cada caso cli declara su entorno completo: el sujeto ejecuta pseudo con exactamente esas variables, en un directorio temporal que contiene los archivos declarados. Por eso un caso sin variables de idioma observa el español por omisión.

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Con --proyecto <directorio> (alias --project) las órdenes comprobar, ejecutar, compilar y bloquear operan sobre un proyecto en lugar de un archivo. Cada subdirectorio que contiene un archivo pseudolearn.toml es la raíz de un paquete y su manifiesto se resuelve según API.PROJECT.MANIFEST con la ruta del subdirectorio como ubicación. Cada archivo .pseudo es un módulo cuya ruta lógica es su ruta relativa al directorio sin la extensión, y recibe un source_id consecutivo desde 1 en el orden de su clave portable de ruta. El directorio se lee una sola vez por un descriptor confinado y el resultado no depende del directorio actual. Un manifiesto en la raíz del directorio, un nombre que no es UTF-8, rutas que colisionan por caja o NFC, un enlace simbólico que escapa del directorio o un ciclo son errores operativos (código 3) sin resultados parciales. --entrada (alias --entry) nombra por ruta lógica la entrada que ejecutan ejecutar y compilar.",
  "verificacion": [
    "C25",
    "C26"
  ]
}
```

```caso
{
  "id": "C25",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--proyecto",
      "proyecto"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
    }
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R8",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: no se puede leer proyecto/pseudolearn.toml\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--proyecto",
      "proyecto"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n",
      "proyecto/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n"
    }
  }
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo bloquear --proyecto <directorio> (alias lock) escribe pseudolearn.lock en la raíz del directorio con el texto canónico de API.PROJECT.LOCK, registrando cada paquete como local con su origen y sus dependencias, e informa la ruta escrita. La escritura es explícita y atómica: se compone en un archivo temporal del mismo directorio y se renombra, de modo que un fallo (código 3) no deja temporales ni altera un lock previo. Las órdenes comprobar, ejecutar y compilar nunca crean ni modifican el lock; si pseudolearn.lock existe, lo verifican contra los paquetes leídos antes de analizar, y una discrepancia es un error operativo (código 3) sin análisis ni salida. Los errores de manifiesto al bloquear se informan como en comprobar con código 1.",
  "verificacion": [
    "C27",
    "C28",
    "C29",
    "C30"
  ]
}
```

```caso
{
  "id": "C27",
  "regla": "R9",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "pseudo: lock escrito: proyecto/pseudolearn.lock\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "bloquear",
      "--proyecto",
      "proyecto"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
    }
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R9",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--proyecto",
      "proyecto"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n",
      "proyecto/pseudolearn.lock": "schema = 1\n\n[packages.\"app\"]\norigin = \"app\"\nkind = \"local\"\ndependencies = [\"geo\"]\n\n[packages.\"geo\"]\norigin = \"geo\"\nkind = \"local\"\ndependencies = []\n"
    }
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R9",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: el lock no coincide con el proyecto [originMismatch]\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--proyecto",
      "proyecto"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n",
      "proyecto/pseudolearn.lock": "schema = 1\n\n[packages.\"app\"]\norigin = \"app\"\nkind = \"local\"\ndependencies = [\"geo\"]\n\n[packages.\"geo\"]\norigin = \"gex\"\nkind = \"local\"\ndependencies = []\n"
    }
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R9",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "proyecto/geo/pseudolearn.toml:1:1: error de manifiesto: package [missingField]\nproyecto/geo/pseudolearn.toml:1:10: error de manifiesto: schema [unsupportedSchema]\n"
  },
  "cli": {
    "argumentos": [
      "bloquear",
      "--proyecto",
      "proyecto"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 2\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
    }
  }
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las órdenes de proyecto aceptan los alias en inglés lock, --project y --entry con cualquier idioma de interfaz y producen el mismo resultado que la forma canónica; --proyecto o --entrada sin valor, o con un valor que empieza por --, son un uso incorrecto.",
  "verificacion": [
    "C31",
    "C32"
  ]
}
```

```caso
{
  "id": "C31",
  "regla": "R10",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "pseudo: lock written: proyecto/pseudolearn.lock\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "lock",
      "--project",
      "proyecto",
      "--language",
      "en"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar n * 2;\nFinSubProceso\n"
    }
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R10",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: valor no válido «» para --proyecto\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--proyecto"
    ],
    "entorno": {},
    "archivos": {}
  }
}
```

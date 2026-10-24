---
{
  "formato": "see/1",
  "id": "TOOL.CLI.RUN",
  "titulo": "Orden ejecutar",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo ejecutar con entrada estándar, semilla, límites y traza.",
  "depende_de": [
    {
      "id": "API.PROJECT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.CLI.MESSAGES",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.EXECUTE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Run command",
  "revisado_por": [
    "revision-independiente-automatizada-r9",
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Orden ejecutar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo ejecutar analiza el archivo y, si no hay errores, lo ejecuta: la salida del programa va sin traducir a la salida estándar y la entrada estándar alimenta Leer, una línea por valor sin su fin de línea. Los diagnósticos de análisis y de ejecución van a la salida de error con las plantillas de diagnóstico.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C12"
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
    "codigo_salida": 0,
    "salida": "1\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
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
    "codigo_salida": 0,
    "salida": "1\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "run",
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
    "codigo_salida": 0,
    "salida": "42\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n"
    },
    "entrada": "21\n"
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
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "p.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida es 0 si la ejecución termina con completed y 1 en cualquier otro caso. Un fallo escribe su diagnóstico; un límite alcanzado escribe statementBudgetExhausted; la entrada estándar agotada mientras Leer espera escribe inputExhausted.",
  "verificacion": [
    "C5",
    "C6",
    "C7"
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
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "p.pseudo:4:12: error: División por cero [divisionByZero]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nx <- 0;\nEscribir 1 div x;\nFinAlgoritmo\n"
    }
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
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "p.pseudo: la entrada estándar terminó mientras el programa esperaba un valor\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n"
    }
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
    "codigo_salida": 1,
    "salida": "1\n2\n",
    "salida_error": "p.pseudo:4:1: información: Se agotó el presupuesto de sentencias: 2 [statementBudgetExhausted]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--sentencias",
      "2",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "--semilla fija la semilla de RT.HOST.INTERFACE; sin ella se usa 42. --profundidad, --sentencias y --celdas fijan los límites de ENG.LIMITS; por omisión la CLI admite 100 000 marcos y no tiene presupuesto de sentencias.",
  "verificacion": [
    "C8",
    "C9"
  ]
}
```

```caso
{
  "id": "C8",
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
    "salida": "5415695640260286\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--semilla",
      "0",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n"
    }
  }
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
    "codigo_salida": 0,
    "salida": "fin\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(5000);\nEscribir \"fin\";\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "--traza narra cada evento de ENG.TRACE.EVENTS en la salida de error, una línea por evento, con las plantillas trace* en el idioma de interfaz. source es el texto de la línea de la sentencia sin espacios iniciales ni finales y text muestra cada salto de línea como \\n. La salida del programa y sus lexemas no se traducen.",
  "verificacion": [
    "C10",
    "C11"
  ]
}
```

```caso
{
  "id": "C10",
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
    "salida": "1\n",
    "salida_error": "p.pseudo:2  entra en sentencia  Escribir 1;\np.pseudo:2  escribe  1\\n\np.pseudo:2  sale de sentencia  Escribir 1;\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--traza",
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
  "id": "C11",
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
    "salida": "1\n",
    "salida_error": "p.pseudo:2  enters statement  Escribir 1;\np.pseudo:2  writes  1\\n\np.pseudo:2  exits statement  Escribir 1;\n"
  },
  "cli": {
    "argumentos": [
      "run",
      "--trace",
      "--language",
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

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": ["es"],
  "rigor": ["estricto"],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "1234\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": ["ejecutar", "p.pseudo"],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir Importar, Exportar, import, export Como Entero;\nImportar <- 1;\nExportar <- 2;\nimport <- 3;\nexport <- 4;\nEscribir Importar, Exportar, import, export;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo ejecutar --proyecto <directorio> --entrada <ruta lógica> ejecuta la entrada con execute_project: la salida del programa va a la salida estándar y los diagnósticos a la salida de error con la ruta del archivo donde ocurren, incluidos los fallos de ejecución dentro de un módulo importado. Sin --entrada es un uso incorrecto (código 2); una entrada inexistente es el error de proyecto entryNotFound (código 1); el código es 0 solo si la ejecución termina con completed. Las opciones de ejecución no se aplican a un proyecto: sus límites proceden del manifiesto.",
  "verificacion": [
    "C13",
    "C14",
    "C15",
    "C16",
    "C17"
  ]
}
```

```caso
{
  "id": "C13",
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
    "codigo_salida": 0,
    "salida": "42\n7\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--proyecto",
      "proyecto",
      "--entrada",
      "app/main"
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
  "id": "C14",
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
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "proyecto/geo/vectores.pseudo:2:12: error: División por cero [divisionByZero]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--proyecto",
      "proyecto",
      "--entrada",
      "app/main"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Real\nRetornar n / 0;\nFinSubProceso\n"
    }
  }
}
```

```caso
{
  "id": "C15",
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
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta la entrada del proyecto (--entrada)\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
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
  "id": "C16",
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
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "proyecto/app/nada: error de proyecto [entryNotFound]\n"
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--proyecto",
      "proyecto",
      "--entrada",
      "app/nada"
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
  "id": "C17",
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
    "codigo_salida": 0,
    "salida": "42\n7\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "run",
      "--project",
      "proyecto",
      "--entry",
      "app/main",
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

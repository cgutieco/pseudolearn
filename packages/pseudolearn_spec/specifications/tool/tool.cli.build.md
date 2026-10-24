---
{
  "formato": "see/1",
  "id": "TOOL.CLI.BUILD",
  "titulo": "Orden compilar",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo compilar produce un ejecutable nativo desde un programa válido.",
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
      "id": "RT.LINKING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Build command",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Orden compilar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo compilar <archivo> (alias build) analiza el programa y, si no hay errores, genera un ejecutable nativo en la ruta de salida e informa su ruta. La opción -o (alias --salida y --output) fija la ruta; si se omite, se usa el nombre del archivo sin la extensión .pseudo en el directorio actual, con .exe en Windows.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
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
    "salida": "pseudo: ejecutable generado: salida\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "compilar",
      "-o",
      "salida",
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
    "salida": "pseudo: ejecutable generado: salida\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "build",
      "--output",
      "salida",
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
    "salida": "pseudo: ejecutable generado: p\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "compilar",
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
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el programa tiene errores léxicos, sintácticos o semánticos, no se genera ni se sobrescribe ningún archivo de salida, los diagnósticos van a la salida de error y el código de salida es 1.",
  "verificacion": [
    "C4"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "",
    "salida_error": "p.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n"
  },
  "cli": {
    "argumentos": [
      "compilar",
      "-o",
      "salida",
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
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un archivo de entrada ausente es un uso incorrecto (código 2) y uno ilegible un error operativo (código 3), con los mensajes de TOOL.CLI.MESSAGES.",
  "verificacion": [
    "C5",
    "C6"
  ]
}
```

```caso
{
  "id": "C5",
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
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta el archivo de entrada\n"
  },
  "cli": {
    "argumentos": [
      "compilar"
    ],
    "entorno": {}
  }
}
```

```caso
{
  "id": "C6",
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
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: no se puede leer falta.pseudo\n"
  },
  "cli": {
    "argumentos": [
      "compilar",
      "falta.pseudo"
    ],
    "entorno": {}
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el enlazador del sistema no está disponible o falla, la orden informa el fallo operativo con el código de salida 3 y no crea ni sobrescribe el archivo de salida.",
  "verificacion": [
    "C7"
  ]
}
```

```caso
{
  "id": "C7",
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
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: el enlazador del sistema no está disponible o falló\n"
  },
  "cli": {
    "argumentos": [
      "compilar",
      "-o",
      "salida",
      "p.pseudo"
    ],
    "entorno": {
      "PATH": ""
    },
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo compilar --proyecto <directorio> --entrada <ruta lógica> genera un único ejecutable nativo del grafo cerrado del proyecto, con la salida de -o o, por omisión, el último segmento de la entrada en el directorio actual. El ejecutable produce la misma salida que ejecutar. Con errores de proyecto, de manifiesto o de análisis no se genera ni se sobrescribe ningún archivo y el código es 1; un enlazador no disponible es un error operativo (código 3) sin archivo de salida.",
  "verificacion": [
    "C8",
    "C9",
    "C10"
  ]
}
```

```caso
{
  "id": "C8",
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
    "salida": "pseudo: ejecutable generado: salida\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "compilar",
      "--proyecto",
      "proyecto",
      "--entrada",
      "app/main",
      "-o",
      "salida"
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
  "id": "C9",
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
    "salida_error": "proyecto/geo/vectores.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n"
  },
  "cli": {
    "argumentos": [
      "compilar",
      "--proyecto",
      "proyecto",
      "--entrada",
      "app/main",
      "-o",
      "salida"
    ],
    "entorno": {},
    "archivos": {
      "proyecto/app/pseudolearn.toml": "schema = 1\n[package]\nname = \"app\"\nkind = \"application\"\nentries = [\"app/main\"]\n[dependencies]\ngeo = { package = \"geo\" }\n[profiles]\n\"app/informe\" = \"en\"\n",
      "proyecto/geo/pseudolearn.toml": "schema = 1\n[package]\nname = \"geo\"\nkind = \"library\"\n",
      "proyecto/app/main.pseudo": "Importar app.informe.Informe;\nImportar geo.vectores.Doble;\nAlgoritmo Principal\nEscribir Doble(21);\nInforme();\nFinAlgoritmo\n",
      "proyecto/app/informe.pseudo": "public subroutine Informe()\nwrite 7;\nendSubroutine\n",
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar total;\nFinSubProceso\n"
    }
  }
}
```

```caso
{
  "id": "C10",
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
    "salida_error": "pseudo: el enlazador del sistema no está disponible o falló\n"
  },
  "cli": {
    "argumentos": [
      "compilar",
      "--proyecto",
      "proyecto",
      "--entrada",
      "app/main",
      "-o",
      "salida"
    ],
    "entorno": {
      "PATH": ""
    },
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

---
{
  "formato": "see/1",
  "id": "TOOL.CLI.CHECK",
  "titulo": "Orden comprobar",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "pseudo comprobar sobre archivos y directorios.",
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
      "id": "API.ANALYZE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Check command",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Orden comprobar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo comprobar analiza cada archivo indicado y cada archivo .pseudo de los directorios indicados, recursivamente y en orden de segmentos relativos a la raíz con clave portable NFC en minúsculas Unicode; conserva la grafía de la ruta para presentarla. Escribe en la salida estándar una línea por diagnóstico, en el orden de DIAG.ORDERING, con la plantilla de su severidad y el mensaje de DIAG.MESSAGES en el idioma de interfaz. Reordenar los argumentos o cambiar el idioma de interfaz no altera el orden. Sin diagnósticos no escribe nada.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C10"
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
    "salida": "",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "check",
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
    "codigo_salida": 1,
    "salida": "p.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
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
    "salida": "p.pseudo:2:10: error: Undeclared variable: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--idioma",
      "en",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "src/b.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "src"
    ],
    "entorno": {},
    "archivos": {
      "src/a.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
      "src/b.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n",
      "src/notas.txt": "Escribir total;\n"
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
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "src/alpha.pseudo:2:10: error: Carácter no reconocido: $ [unrecognizedCharacter]\nsrc/zeta.pseudo:2:10: error: Carácter no reconocido: @ [unrecognizedCharacter]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "src"
    ],
    "entorno": {},
    "archivos": {
      "src/zeta.pseudo": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
      "src/alpha.pseudo": "Algoritmo P\nEscribir $;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida es 1 si algún archivo tiene un diagnóstico de severidad error y 0 si solo hay advertencias o información. Un archivo o directorio ilegible, una colisión de ruta portable, un enlace simbólico absoluto o que escape de la raíz concedida, o un ciclo de enlaces es un error operativo con código 3 y no publica resultados parciales. Los enlaces relativos que permanecen dentro de la misma raíz concedida se siguen; una ruta fuera de ella requiere su propia concesión explícita como argumento. Ninguna ruta es un uso incorrecto con código 2.",
  "verificacion": [
    "C6",
    "C7",
    "C8",
    "C9",
    "C11"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: no se puede leer missing.pseudo\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo",
      "missing.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir total;\nFinAlgoritmo\n"
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
    "codigo_salida": 0,
    "salida": "p.pseudo:2:9: advertencia: Variable declarada y nunca usada: x [variableDeclaredNeverUsed]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nDefinir x Como Entero;\nFinAlgoritmo\n"
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
    "codigo_salida": 2,
    "salida": "",
    "salida_error": "pseudo: falta el archivo de entrada\n"
  },
  "cli": {
    "argumentos": [
      "comprobar"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "p.pseudo:2:10: advertencia: Variable no declarada: total [undeclaredVariable]\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--rigor",
      "flexible",
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
  "texto": "pseudo comprobar --proyecto <directorio> analiza el proyecto completo con analyze_project: los diagnósticos, los errores de proyecto y los errores de manifiesto salen por la salida estándar, uno por línea, con la ruta del archivo real (<directorio>/<ruta relativa>.pseudo) obtenida por su source_id. El código es 1 si hay algún error de cualquier clase y 0 si no. Con --json se imprime la respuesta de analyze_project.",
  "verificacion": [
    "C12",
    "C13",
    "C14"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "proyecto/geo/vectores.pseudo:2:10: error: Variable no declarada: total [undeclaredVariable]\n",
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
      "proyecto/geo/vectores.pseudo": "Publico SubProceso Doble(n Como Entero) Como Entero\nRetornar total;\nFinSubProceso\n"
    }
  }
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 1,
    "salida": "proyecto/geo/pseudolearn.toml:1:1: error de manifiesto: package [missingField]\nproyecto/geo/pseudolearn.toml:1:10: error de manifiesto: schema [unsupportedSchema]\n",
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
      "proyecto/geo/pseudolearn.toml": "schema = 2\n",
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
    "salida": "{\"diagnostics\":[],\"manifest_errors\":[],\"modules\":[{\"module\":\"informe\",\"package\":\"app\",\"path\":\"app/informe\"},{\"module\":\"main\",\"package\":\"app\",\"path\":\"app/main\"},{\"module\":\"vectores\",\"package\":\"geo\",\"path\":\"geo/vectores\"}],\"project_errors\":[]}\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--proyecto",
      "proyecto",
      "--json"
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

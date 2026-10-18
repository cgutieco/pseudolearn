---
{
  "formato": "see/1",
  "id": "TOOL.CLI.MESSAGES",
  "titulo": "Mensajes de la CLI",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Catálogo bilingüe de toda la prosa de la CLI.",
  "depende_de": [
    {
      "id": "TOOL.CLI.CONVENTIONS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.MESSAGES",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "CLI messages",
}
---

# Mensajes de la CLI

```definicion
{
  "id": "D1",
  "termino": "cliMessages",
  "texto": "Plantillas bilingües de la CLI con argumentos tipados. lexema no se traduce nunca; numero se escribe en decimal; texto es prosa ya presentada en el idioma de interfaz.",
  "valor": {
    "usageLine": {
      "mensajes": {
        "es": "Uso: pseudo <orden> [opciones] <archivo>...",
        "en": "Usage: pseudo <command> [options] <file>..."
      },
      "argumentos": [],
      "tipos_argumentos": {}
    },
    "helpCommands": {
      "mensajes": {
        "es": "Órdenes: comprobar (check), ejecutar (run), ri (ir), preferencias (preferences)",
        "en": "Commands: check (comprobar), run (ejecutar), ir (ri), preferences (preferencias)"
      },
      "argumentos": [],
      "tipos_argumentos": {}
    },
    "helpOptions": {
      "mensajes": {
        "es": "Opciones: --ayuda (--help), --idioma (--language), --rigor (--strictness), --vocabulario (--vocabulary), --traza (--trace), --semilla (--seed), --profundidad (--depth), --sentencias (--statements), --celdas (--cells), --json",
        "en": "Options: --help (--ayuda), --language (--idioma), --strictness (--rigor), --vocabulary (--vocabulario), --trace (--traza), --seed (--semilla), --depth (--profundidad), --statements (--sentencias), --cells (--celdas), --json"
      },
      "argumentos": [],
      "tipos_argumentos": {}
    },
    "missingCommand": {
      "mensajes": {
        "es": "pseudo: falta la orden; use pseudo --ayuda",
        "en": "pseudo: missing command; use pseudo --help"
      },
      "argumentos": [],
      "tipos_argumentos": {}
    },
    "unknownCommand": {
      "mensajes": {
        "es": "pseudo: orden desconocida «{command}»",
        "en": "pseudo: unknown command '{command}'"
      },
      "argumentos": [
        "command"
      ],
      "tipos_argumentos": {
        "command": "lexema"
      }
    },
    "unknownOption": {
      "mensajes": {
        "es": "pseudo: opción desconocida «{option}»",
        "en": "pseudo: unknown option '{option}'"
      },
      "argumentos": [
        "option"
      ],
      "tipos_argumentos": {
        "option": "lexema"
      }
    },
    "invalidOptionValue": {
      "mensajes": {
        "es": "pseudo: valor no válido «{value}» para {option}",
        "en": "pseudo: invalid value '{value}' for {option}"
      },
      "argumentos": [
        "value",
        "option"
      ],
      "tipos_argumentos": {
        "value": "lexema",
        "option": "lexema"
      }
    },
    "missingInput": {
      "mensajes": {
        "es": "pseudo: falta el archivo de entrada",
        "en": "pseudo: missing input file"
      },
      "argumentos": [],
      "tipos_argumentos": {}
    },
    "buildSucceeded": {
      "mensajes": {
        "es": "pseudo: ejecutable generado: {path}",
        "en": "pseudo: executable generated: {path}"
      },
      "argumentos": [
        "path"
      ],
      "tipos_argumentos": {
        "path": "lexema"
      }
    },
    "linkerFailed": {
      "mensajes": {
        "es": "pseudo: el enlazador del sistema no está disponible o falló",
        "en": "pseudo: the system linker is unavailable or failed"
      },
      "argumentos": [],
      "tipos_argumentos": {}
    },
    "unreadableInput": {
      "mensajes": {
        "es": "pseudo: no se puede leer {path}",
        "en": "pseudo: cannot read {path}"
      },
      "argumentos": [
        "path"
      ],
      "tipos_argumentos": {
        "path": "lexema"
      }
    },
    "diagnosticError": {
      "mensajes": {
        "es": "{path}:{line}:{column}: error: {message} [{code}]",
        "en": "{path}:{line}:{column}: error: {message} [{code}]"
      },
      "argumentos": [
        "path",
        "line",
        "column",
        "message",
        "code"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "column": "numero",
        "message": "texto",
        "code": "lexema"
      }
    },
    "diagnosticWarning": {
      "mensajes": {
        "es": "{path}:{line}:{column}: advertencia: {message} [{code}]",
        "en": "{path}:{line}:{column}: warning: {message} [{code}]"
      },
      "argumentos": [
        "path",
        "line",
        "column",
        "message",
        "code"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "column": "numero",
        "message": "texto",
        "code": "lexema"
      }
    },
    "diagnosticInfo": {
      "mensajes": {
        "es": "{path}:{line}:{column}: información: {message} [{code}]",
        "en": "{path}:{line}:{column}: info: {message} [{code}]"
      },
      "argumentos": [
        "path",
        "line",
        "column",
        "message",
        "code"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "column": "numero",
        "message": "texto",
        "code": "lexema"
      }
    },
    "inputExhausted": {
      "mensajes": {
        "es": "{path}: la entrada estándar terminó mientras el programa esperaba un valor",
        "en": "{path}: standard input ended while the program was waiting for a value"
      },
      "argumentos": [
        "path"
      ],
      "tipos_argumentos": {
        "path": "lexema"
      }
    },
    "preferenceSaved": {
      "mensajes": {
        "es": "pseudo: idioma de interfaz guardado: {language}",
        "en": "pseudo: interface language saved: {language}"
      },
      "argumentos": [
        "language"
      ],
      "tipos_argumentos": {
        "language": "lexema"
      }
    },
    "traceStatementEntered": {
      "mensajes": {
        "es": "{path}:{line}  entra en sentencia  {source}",
        "en": "{path}:{line}  enters statement  {source}"
      },
      "argumentos": [
        "path",
        "line",
        "source"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "source": "lexema"
      }
    },
    "traceStatementExited": {
      "mensajes": {
        "es": "{path}:{line}  sale de sentencia  {source}",
        "en": "{path}:{line}  exits statement  {source}"
      },
      "argumentos": [
        "path",
        "line",
        "source"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "source": "lexema"
      }
    },
    "traceDecisionAffirmative": {
      "mensajes": {
        "es": "{path}:{line}  decisión  rama afirmativa",
        "en": "{path}:{line}  decision  affirmative branch"
      },
      "argumentos": [
        "path",
        "line"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero"
      }
    },
    "traceDecisionNegative": {
      "mensajes": {
        "es": "{path}:{line}  decisión  rama negativa",
        "en": "{path}:{line}  decision  negative branch"
      },
      "argumentos": [
        "path",
        "line"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero"
      }
    },
    "traceDecisionCase": {
      "mensajes": {
        "es": "{path}:{line}  decisión  caso {index}",
        "en": "{path}:{line}  decision  case {index}"
      },
      "argumentos": [
        "path",
        "line",
        "index"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "index": "numero"
      }
    },
    "traceDecisionDefault": {
      "mensajes": {
        "es": "{path}:{line}  decisión  rama por omisión",
        "en": "{path}:{line}  decision  default branch"
      },
      "argumentos": [
        "path",
        "line"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero"
      }
    },
    "traceDecisionNone": {
      "mensajes": {
        "es": "{path}:{line}  decisión  ningún caso",
        "en": "{path}:{line}  decision  no case"
      },
      "argumentos": [
        "path",
        "line"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero"
      }
    },
    "traceCall": {
      "mensajes": {
        "es": "{path}:{line}  llama a {name}",
        "en": "{path}:{line}  calls {name}"
      },
      "argumentos": [
        "path",
        "line",
        "name"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "name": "lexema"
      }
    },
    "traceReturn": {
      "mensajes": {
        "es": "{path}:{line}  vuelve de {name}",
        "en": "{path}:{line}  returns from {name}"
      },
      "argumentos": [
        "path",
        "line",
        "name"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "name": "lexema"
      }
    },
    "traceOutput": {
      "mensajes": {
        "es": "{path}:{line}  escribe  {text}",
        "en": "{path}:{line}  writes  {text}"
      },
      "argumentos": [
        "path",
        "line",
        "text"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "text": "lexema"
      }
    },
    "traceInputRequested": {
      "mensajes": {
        "es": "{path}:{line}  pide un valor",
        "en": "{path}:{line}  requests a value"
      },
      "argumentos": [
        "path",
        "line"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero"
      }
    },
    "traceInputReceived": {
      "mensajes": {
        "es": "{path}:{line}  recibe  {text}",
        "en": "{path}:{line}  receives  {text}"
      },
      "argumentos": [
        "path",
        "line",
        "text"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "text": "lexema"
      }
    },
    "traceFailure": {
      "mensajes": {
        "es": "{path}:{line}  falla  {code}",
        "en": "{path}:{line}  fails  {code}"
      },
      "argumentos": [
        "path",
        "line",
        "code"
      ],
      "tipos_argumentos": {
        "path": "lexema",
        "line": "numero",
        "code": "lexema"
      }
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda la prosa de la CLI (ayuda, errores de uso, errores operativos, líneas de diagnóstico, progreso y narración de --traza) sale del catálogo D1, en el idioma de interfaz. Ningún literal destinado a una persona vive en el código. Cada plantilla existe en español e inglés con los mismos argumentos.",
  "verificacion": [
    "C1",
    "C2"
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
    "salida": "Usage: pseudo <command> [options] <file>...\nCommands: check (comprobar), run (ejecutar), ir (ri), preferences (preferencias)\nOptions: --help (--ayuda), --language (--idioma), --strictness (--rigor), --vocabulary (--vocabulario), --trace (--traza), --seed (--semilla), --depth (--profundidad), --statements (--sentencias), --cells (--celdas), --json\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "--ayuda",
      "--idioma",
      "en"
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
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: cannot read falta.pseudo\n"
  },
  "cli": {
    "argumentos": [
      "comprobar",
      "--idioma",
      "en",
      "falta.pseudo"
    ],
    "entorno": {}
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los fragmentos de programa citados en la prosa conservan los lexemas del archivo y la salida del programa nunca se traduce: un argumento lexema se escribe tal como aparece en la fuente o en la salida.",
  "verificacion": [
    "C3"
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
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Verdadero\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "--idioma",
      "en",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir Verdadero;\nFinAlgoritmo\n"
    }
  }
}
```

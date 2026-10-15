---
{
  "formato": "see/1",
  "id": "LIB.MODEL",
  "titulo": "Modelo de funciones incorporadas",
  "dominio": "biblioteca",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Modelo de funciones incorporadas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "DIAG.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Sin cambios en el lenguaje ni en el código admitido.",
    "impacto_implementaciones": "Activa el sujeto engine en R4 manteniendo reference.",
    "justificacion": "Habilitar la verificación de conformidad estática del nuevo motor en Rust.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
}
---

# Modelo de funciones incorporadas

```definicion
{
  "id": "D1",
  "termino": "functions",
  "texto": "Identidad, nombres, alias y firma de cada función incorporada.",
  "valor": {
    "squareRoot": {
      "lexemas": {
        "es": "rc",
        "en": "sqrt"
      },
      "alias": {
        "es": [
          "raiz"
        ],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "absoluteValue": {
      "lexemas": {
        "es": "abs",
        "en": "abs"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "naturalLogarithm": {
      "lexemas": {
        "es": "ln",
        "en": "ln"
      },
      "alias": {
        "es": [],
        "en": [
          "log"
        ]
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "exponential": {
      "lexemas": {
        "es": "exp",
        "en": "exp"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "sine": {
      "lexemas": {
        "es": "sen",
        "en": "sin"
      },
      "alias": {
        "es": [
          "sin"
        ],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "cosine": {
      "lexemas": {
        "es": "cos",
        "en": "cos"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "arcTangent": {
      "lexemas": {
        "es": "atan",
        "en": "atan"
      },
      "alias": {
        "es": [
          "arctan"
        ],
        "en": []
      },
      "parametros": [
        "numeric"
      ],
      "retorno": "real"
    },
    "truncate": {
      "lexemas": {
        "es": "trunc",
        "en": "trunc"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "real"
      ],
      "retorno": "integer"
    },
    "round": {
      "lexemas": {
        "es": "redon",
        "en": "round"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "real"
      ],
      "retorno": "integer"
    },
    "random": {
      "lexemas": {
        "es": "azar",
        "en": "random"
      },
      "alias": {
        "es": [
          "aleatorio"
        ],
        "en": [
          "rand"
        ]
      },
      "parametros": [],
      "retorno": "real"
    },
    "toText": {
      "lexemas": {
        "es": "ATexto",
        "en": "toText"
      },
      "alias": {
        "es": [
          "ConvertirATexto"
        ],
        "en": []
      },
      "parametros": [
        "anyPrimitive"
      ],
      "retorno": "string"
    },
    "textToInteger": {
      "lexemas": {
        "es": "AEntero",
        "en": "toInteger"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "integer"
    },
    "textToReal": {
      "lexemas": {
        "es": "AReal",
        "en": "toReal"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "real"
    },
    "length": {
      "lexemas": {
        "es": "Longitud",
        "en": "length"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string"
      ],
      "retorno": "integer"
    },
    "characterAt": {
      "lexemas": {
        "es": "CaracterEn",
        "en": "charAt"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "string",
        "integer"
      ],
      "retorno": "character"
    },
    "characterCode": {
      "lexemas": {
        "es": "CodigoDe",
        "en": "charCode"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "character"
      ],
      "retorno": "integer"
    },
    "characterFromCode": {
      "lexemas": {
        "es": "CaracterDesde",
        "en": "charFromCode"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "integer"
      ],
      "retorno": "character"
    },
    "shallowCopy": {
      "lexemas": {
        "es": "Copiar",
        "en": "copy"
      },
      "alias": {
        "es": [],
        "en": []
      },
      "parametros": [
        "anyClass"
      ],
      "retorno": "sameAsFirstArgument"
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "D1 declara las dieciocho funciones incorporadas, lexemas canónicos y alias bilingües y firmas. Sus nombres no son palabras reservadas; subprograma homónimo oculta la función. Cantidad y tipos de argumentos se comprueban antes de ejecución. Son datos del perfil con semántica única y determinista.",
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
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(\"ab\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
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
    "es": "Algoritmo P\nEscribir Longitud(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
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
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
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

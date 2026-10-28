---
{
  "formato": "see/1",
  "id": "LANG.PROFILE.VOCABULARY",
  "titulo": "Vocabulario bilingüe",
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
  "resumen": "Vocabulario bilingüe.",
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

# Vocabulario bilingüe

```definicion
{
  "id": "D1",
  "termino": "vocabulary",
  "texto": "Inventario de tokens, lexemas canónicos y alias de los dos idiomas.",
  "valor": {
    "algorithm": {
      "lexemas": {
        "es": "Proceso",
        "en": "algorithm"
      },
      "alias": {
        "es": [
          "Algoritmo"
        ],
        "en": []
      }
    },
    "endAlgorithm": {
      "lexemas": {
        "es": "FinProceso",
        "en": "endAlgorithm"
      },
      "alias": {
        "es": [
          "FinAlgoritmo",
          "Fin Proceso",
          "Fin Algoritmo"
        ],
        "en": [
          "end algorithm"
        ]
      }
    },
    "declare": {
      "lexemas": {
        "es": "Definir",
        "en": "define"
      },
      "alias": {
        "es": [],
        "en": [
          "declare"
        ]
      }
    },
    "typeConnector": {
      "lexemas": {
        "es": "Como",
        "en": "as"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "dimension": {
      "lexemas": {
        "es": "Dimension",
        "en": "dimension"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "integerType": {
      "lexemas": {
        "es": "Entero",
        "en": "integer"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "realType": {
      "lexemas": {
        "es": "Real",
        "en": "real"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "booleanType": {
      "lexemas": {
        "es": "Logico",
        "en": "boolean"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "characterType": {
      "lexemas": {
        "es": "Caracter",
        "en": "character"
      },
      "alias": {
        "es": [],
        "en": [
          "char"
        ]
      }
    },
    "stringType": {
      "lexemas": {
        "es": "Cadena",
        "en": "string"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "booleanTrue": {
      "lexemas": {
        "es": "Verdadero",
        "en": "true"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "booleanFalse": {
      "lexemas": {
        "es": "Falso",
        "en": "false"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "read": {
      "lexemas": {
        "es": "Leer",
        "en": "read"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "write": {
      "lexemas": {
        "es": "Escribir",
        "en": "write"
      },
      "alias": {
        "es": [
          "Mostrar"
        ],
        "en": [
          "print"
        ]
      }
    },
    "withoutNewline": {
      "lexemas": {
        "es": "Sin Saltar",
        "en": "without newline"
      },
      "alias": {
        "es": [
          "SinSaltar"
        ],
        "en": [
          "withoutNewline"
        ]
      }
    },
    "assignment": {
      "lexemas": {
        "es": "<-",
        "en": "<-"
      },
      "alias": {
        "es": [
          ":="
        ],
        "en": [
          ":="
        ]
      }
    },
    "ifKeyword": {
      "lexemas": {
        "es": "Si",
        "en": "if"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "then": {
      "lexemas": {
        "es": "Entonces",
        "en": "then"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "elseKeyword": {
      "lexemas": {
        "es": "SiNo",
        "en": "else"
      },
      "alias": {
        "es": [
          "Sino",
          "Si No"
        ],
        "en": []
      }
    },
    "endIf": {
      "lexemas": {
        "es": "FinSi",
        "en": "endIf"
      },
      "alias": {
        "es": [
          "Fin Si"
        ],
        "en": [
          "end if"
        ]
      }
    },
    "switchKeyword": {
      "lexemas": {
        "es": "Segun",
        "en": "switch"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "defaultCase": {
      "lexemas": {
        "es": "De Otro Modo",
        "en": "otherwise"
      },
      "alias": {
        "es": [
          "DeOtroModo"
        ],
        "en": [
          "default"
        ]
      }
    },
    "endSwitch": {
      "lexemas": {
        "es": "FinSegun",
        "en": "endSwitch"
      },
      "alias": {
        "es": [
          "Fin Segun"
        ],
        "en": [
          "end switch"
        ]
      }
    },
    "whileKeyword": {
      "lexemas": {
        "es": "Mientras",
        "en": "while"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "doKeyword": {
      "lexemas": {
        "es": "Hacer",
        "en": "do"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endWhile": {
      "lexemas": {
        "es": "FinMientras",
        "en": "endWhile"
      },
      "alias": {
        "es": [
          "Fin Mientras"
        ],
        "en": [
          "end while"
        ]
      }
    },
    "repeat": {
      "lexemas": {
        "es": "Repetir",
        "en": "repeat"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "until": {
      "lexemas": {
        "es": "Hasta Que",
        "en": "until"
      },
      "alias": {
        "es": [
          "HastaQue"
        ],
        "en": []
      }
    },
    "forKeyword": {
      "lexemas": {
        "es": "Para",
        "en": "for"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "to": {
      "lexemas": {
        "es": "Hasta",
        "en": "to"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "step": {
      "lexemas": {
        "es": "Con Paso",
        "en": "step"
      },
      "alias": {
        "es": [
          "ConPaso"
        ],
        "en": [
          "with step"
        ]
      }
    },
    "endFor": {
      "lexemas": {
        "es": "FinPara",
        "en": "endFor"
      },
      "alias": {
        "es": [
          "Fin Para"
        ],
        "en": [
          "end for"
        ]
      }
    },
    "subroutine": {
      "lexemas": {
        "es": "SubProceso",
        "en": "subroutine"
      },
      "alias": {
        "es": [
          "SubAlgoritmo",
          "Funcion",
          "Procedimiento"
        ],
        "en": [
          "function",
          "procedure"
        ]
      }
    },
    "awaitKeyword": {
      "lexemas": {
        "es": "Aguardar",
        "en": "await"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endSubroutine": {
      "lexemas": {
        "es": "FinSubProceso",
        "en": "endSubroutine"
      },
      "alias": {
        "es": [
          "FinSubAlgoritmo",
          "FinFuncion",
          "FinProcedimiento",
          "Fin SubProceso",
          "Fin SubAlgoritmo",
          "Fin Funcion",
          "Fin Procedimiento"
        ],
        "en": [
          "end subroutine",
          "end function",
          "end procedure"
        ]
      }
    },
    "byReference": {
      "lexemas": {
        "es": "Por Referencia",
        "en": "by reference"
      },
      "alias": {
        "es": [
          "PorReferencia"
        ],
        "en": [
          "byReference"
        ]
      }
    },
    "byValue": {
      "lexemas": {
        "es": "Por Valor",
        "en": "by value"
      },
      "alias": {
        "es": [
          "PorValor"
        ],
        "en": [
          "byValue"
        ]
      }
    },
    "returnKeyword": {
      "lexemas": {
        "es": "Retornar",
        "en": "return"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "classKeyword": {
      "lexemas": {
        "es": "Clase",
        "en": "class"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endClass": {
      "lexemas": {
        "es": "FinClase",
        "en": "endClass"
      },
      "alias": {
        "es": [
          "Fin Clase"
        ],
        "en": [
          "end class"
        ]
      }
    },
    "inheritsFrom": {
      "lexemas": {
        "es": "Hereda De",
        "en": "inherits from"
      },
      "alias": {
        "es": [
          "HeredaDe"
        ],
        "en": [
          "inheritsFrom",
          "extends"
        ]
      }
    },
    "method": {
      "lexemas": {
        "es": "Metodo",
        "en": "method"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endMethod": {
      "lexemas": {
        "es": "FinMetodo",
        "en": "endMethod"
      },
      "alias": {
        "es": [
          "Fin Metodo"
        ],
        "en": [
          "end method"
        ]
      }
    },
    "constructor": {
      "lexemas": {
        "es": "Constructor",
        "en": "constructor"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "publicVisibility": {
      "lexemas": {
        "es": "Publico",
        "en": "public"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "privateVisibility": {
      "lexemas": {
        "es": "Privado",
        "en": "private"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "importKeyword": {
      "lexemas": {
        "es": "Importar",
        "en": "import"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "exportKeyword": {
      "lexemas": {
        "es": "Exportar",
        "en": "export"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "constantKeyword": {
      "lexemas": {
        "es": "Constante",
        "en": "constant"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "enumKeyword": {
      "lexemas": {
        "es": "Enumerado",
        "en": "enum"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endEnum": {
      "lexemas": {
        "es": "FinEnumerado",
        "en": "endEnum"
      },
      "alias": {
        "es": [
          "Fin Enumerado"
        ],
        "en": [
          "end enum"
        ]
      }
    },
    "recordKeyword": {
      "lexemas": {
        "es": "Registro",
        "en": "record"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endRecord": {
      "lexemas": {
        "es": "FinRegistro",
        "en": "endRecord"
      },
      "alias": {
        "es": [
          "Fin Registro"
        ],
        "en": [
          "end record"
        ]
      }
    },
    "newInstance": {
      "lexemas": {
        "es": "Nuevo",
        "en": "new"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "thisObject": {
      "lexemas": {
        "es": "Este",
        "en": "this"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "superClass": {
      "lexemas": {
        "es": "Super",
        "en": "super"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "plus": {
      "lexemas": {
        "es": "+",
        "en": "+"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "minus": {
      "lexemas": {
        "es": "-",
        "en": "-"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "multiply": {
      "lexemas": {
        "es": "*",
        "en": "*"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "divide": {
      "lexemas": {
        "es": "/",
        "en": "/"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "integerDivide": {
      "lexemas": {
        "es": "div",
        "en": "div"
      },
      "alias": {
        "es": [
          "DIV"
        ],
        "en": []
      }
    },
    "modulo": {
      "lexemas": {
        "es": "mod",
        "en": "mod"
      },
      "alias": {
        "es": [
          "MOD",
          "%"
        ],
        "en": [
          "%"
        ]
      }
    },
    "power": {
      "lexemas": {
        "es": "^",
        "en": "^"
      },
      "alias": {
        "es": [
          "**"
        ],
        "en": [
          "**"
        ]
      }
    },
    "lessThan": {
      "lexemas": {
        "es": "<",
        "en": "<"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "lessThanOrEqual": {
      "lexemas": {
        "es": "<=",
        "en": "<="
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "greaterThan": {
      "lexemas": {
        "es": ">",
        "en": ">"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "greaterThanOrEqual": {
      "lexemas": {
        "es": ">=",
        "en": ">="
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "equal": {
      "lexemas": {
        "es": "=",
        "en": "="
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "notEqual": {
      "lexemas": {
        "es": "<>",
        "en": "<>"
      },
      "alias": {
        "es": [
          "!="
        ],
        "en": [
          "!="
        ]
      }
    },
    "and": {
      "lexemas": {
        "es": "Y",
        "en": "and"
      },
      "alias": {
        "es": [
          "&"
        ],
        "en": [
          "&"
        ]
      }
    },
    "or": {
      "lexemas": {
        "es": "O",
        "en": "or"
      },
      "alias": {
        "es": [
          "|"
        ],
        "en": [
          "|"
        ]
      }
    },
    "not": {
      "lexemas": {
        "es": "NO",
        "en": "not"
      },
      "alias": {
        "es": [
          "~",
          "!"
        ],
        "en": [
          "!"
        ]
      }
    },
    "dot": {
      "lexemas": {
        "es": ".",
        "en": "."
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "leftParenthesis": {
      "lexemas": {
        "es": "(",
        "en": "("
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "rightParenthesis": {
      "lexemas": {
        "es": ")",
        "en": ")"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "leftBracket": {
      "lexemas": {
        "es": "[",
        "en": "["
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "rightBracket": {
      "lexemas": {
        "es": "]",
        "en": "]"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "comma": {
      "lexemas": {
        "es": ",",
        "en": ","
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "semicolon": {
      "lexemas": {
        "es": ";",
        "en": ";"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "branchSeparator": {
      "lexemas": {
        "es": ":",
        "en": ":"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "quote": {
      "lexemas": {
        "es": "\"",
        "en": "\""
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "mutableKeyword": {
      "lexemas": {
        "es": "Mutable",
        "en": "mutable"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "optionalType": {
      "lexemas": {
        "es": "Opcional",
        "en": "optional"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "resultType": {
      "lexemas": {
        "es": "Resultado",
        "en": "result"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "someVariant": {
      "lexemas": {
        "es": "Algo",
        "en": "some"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "noneVariant": {
      "lexemas": {
        "es": "Nada",
        "en": "none"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "successVariant": {
      "lexemas": {
        "es": "Exito",
        "en": "success"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "errorVariant": {
      "lexemas": {
        "es": "Error",
        "en": "failure"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "propagateKeyword": {
      "lexemas": {
        "es": "Propagar",
        "en": "propagate"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "discardKeyword": {
      "lexemas": {
        "es": "Descartar",
        "en": "discard"
      },
      "alias": {
        "es": [],
        "en": []
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
  "texto": "La tabla D1 es la fuente normativa del vocabulario de tokens. Cada identidad tiene lexema canónico y alias por idioma. Todas las entradas se normalizan según el perfil y no colisionan entre identidades. La reimpresión usa formas canónicas; los alias amplían reconocimiento, no semántica.",
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
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite true;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
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
    "es": "Algoritmo P\nDefinir Mientras Como Entero <- 0;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine while as integer <- 0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "reservedLexemeUsedAsName",
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

```definicion
{
  "id": "D2",
  "termino": "contextualVocabulary",
  "texto": "Formas reconocidas solo por contexto sintáctico o tipo de receptor; no reservan identificadores ordinarios.",
  "valor": {
    "interfaceKeyword": {
      "lexemas": {
        "es": "Interfaz",
        "en": "interface"
      }
    },
    "endInterface": {
      "lexemas": {
        "es": "FinInterfaz",
        "en": "endInterface"
      }
    },
    "implementsKeyword": {
      "lexemas": {
        "es": "Realiza",
        "en": "implements"
      }
    },
    "eachKeyword": {
      "lexemas": {
        "es": "Cada",
        "en": "each"
      }
    },
    "inKeyword": {
      "lexemas": {
        "es": "En",
        "en": "in"
      }
    },
    "breakKeyword": {
      "lexemas": {
        "es": "Salir",
        "en": "break"
      }
    },
    "deferKeyword": {
      "lexemas": {
        "es": "Diferir",
        "en": "defer"
      }
    },
    "endDefer": {
      "lexemas": {
        "es": "FinDiferir",
        "en": "endDefer"
      }
    },
    "suspendibleModifier": {
      "lexemas": {
        "es": "Suspendible",
        "en": "suspendable"
      }
    },
    "vectorType": {
      "lexemas": {
        "es": "Vector",
        "en": "vector"
      }
    },
    "dictionaryType": {
      "lexemas": {
        "es": "Diccionario",
        "en": "dictionary"
      }
    },
    "collectionLength": {
      "lexemas": {
        "es": "Longitud",
        "en": "length"
      }
    },
    "vectorAppend": {
      "lexemas": {
        "es": "Agregar",
        "en": "append"
      }
    },
    "vectorInsert": {
      "lexemas": {
        "es": "Insertar",
        "en": "insert"
      }
    },
    "collectionRemove": {
      "lexemas": {
        "es": "Eliminar",
        "en": "remove"
      }
    },
    "dictionaryFind": {
      "lexemas": {
        "es": "Buscar",
        "en": "find"
      }
    },
    "consoleCapabilityType": {
      "lexemas": {
        "es": "Consola",
        "en": "Console"
      }
    },
    "argumentsCapabilityType": {
      "lexemas": {
        "es": "Argumentos",
        "en": "Arguments"
      }
    },
    "directoryCapabilityType": {
      "lexemas": {
        "es": "DirectorioCap",
        "en": "DirCap"
      }
    },
    "fileCapabilityType": {
      "lexemas": {
        "es": "ArchivoCap",
        "en": "FileCap"
      }
    },
    "clockCapabilityType": {
      "lexemas": {
        "es": "Reloj",
        "en": "Clock"
      }
    },
    "timerCapabilityType": {
      "lexemas": {
        "es": "Temporizador",
        "en": "Timer"
      }
    },
    "bytesType": {
      "lexemas": {
        "es": "Bytes",
        "en": "Bytes"
      }
    },
    "ioErrorType": {
      "lexemas": {
        "es": "ErrorES",
        "en": "IoError"
      }
    },
    "requestConsole": {
      "lexemas": {
        "es": "SolicitarConsola",
        "en": "requestConsole"
      }
    },
    "requestArguments": {
      "lexemas": {
        "es": "SolicitarArgumentos",
        "en": "requestArguments"
      }
    },
    "requestDirectory": {
      "lexemas": {
        "es": "SolicitarDirectorio",
        "en": "requestDirectory"
      }
    },
    "requestClock": {
      "lexemas": {
        "es": "SolicitarReloj",
        "en": "requestClock"
      }
    },
    "requestTimer": {
      "lexemas": {
        "es": "SolicitarTemporizador",
        "en": "requestTimer"
      }
    }
  }
}
```

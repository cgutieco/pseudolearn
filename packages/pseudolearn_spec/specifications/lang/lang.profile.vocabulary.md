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
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Vocabulario bilingüe.",
  "edicion": {
    "introducida_en": "2027"
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
        "es": "Algoritmo",
        "en": "algorithm"
      },
      "alias": {
        "es": [
          "Proceso"
        ],
        "en": []
      }
    },
    "endAlgorithm": {
      "lexemas": {
        "es": "FinAlgoritmo",
        "en": "endAlgorithm"
      },
      "alias": {
        "es": [
          "FinProceso",
          "Fin Algoritmo",
          "Fin Proceso"
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
        "es": "Sino",
        "en": "else"
      },
      "alias": {
        "es": [],
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
          "Procedimiento"
        ],
        "en": [
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
    "tasksKeyword": {
      "lexemas": {
        "es": "Tareas",
        "en": "tasks"
      }
    },
    "endTasks": {
      "lexemas": {
        "es": "FinTareas",
        "en": "endTasks"
      }
    },
    "spawnKeyword": {
      "lexemas": {
        "es": "Lanzar",
        "en": "spawn"
      }
    },
    "selectKeyword": {
      "lexemas": {
        "es": "Elegir",
        "en": "select"
      }
    },
    "endSelect": {
      "lexemas": {
        "es": "FinElegir",
        "en": "endSelect"
      }
    },
    "taskType": {
      "lexemas": {
        "es": "Tarea",
        "en": "task"
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
          "FinProcedimiento",
          "Fin SubProceso",
          "Fin SubAlgoritmo",
          "Fin Procedimiento"
        ],
        "en": [
          "end subroutine",
          "end procedure"
        ]
      }
    },
    "function": {
      "lexemas": {
        "es": "Funcion",
        "en": "function"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "endFunction": {
      "lexemas": {
        "es": "FinFuncion",
        "en": "endFunction"
      },
      "alias": {
        "es": [
          "Fin Funcion"
        ],
        "en": [
          "end function"
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
    },
    "jsonValueType": {
      "lexemas": {
        "es": "ValorJson",
        "en": "JsonValue"
      }
    },
    "jsonKindType": {
      "lexemas": {
        "es": "TipoJson",
        "en": "JsonKind"
      }
    },
    "jsonErrorType": {
      "lexemas": {
        "es": "ErrorJson",
        "en": "JsonError"
      }
    },
    "jsonErrorCodeType": {
      "lexemas": {
        "es": "CodigoErrorJson",
        "en": "JsonErrorCode"
      }
    },
    "jsonErrorLineField": {
      "lexemas": {
        "es": "JsonLinea",
        "en": "jsonLine"
      }
    },
    "jsonErrorColumnField": {
      "lexemas": {
        "es": "JsonColumna",
        "en": "jsonColumn"
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
    "C2",
    "C6",
    "C7"
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
  }
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
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir abierto Como Logico <- Falso;\nSi NO abierto Entonces\nEscribir 1;\nSino\nEscribir 2;\nFinSi\nSi No abierto Entonces\nEscribir 3;\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine open as boolean <- false;\nif not open then\nwrite 1;\nelse\nwrite 2;\nendIf\nif Not open then\nwrite 3;\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n3\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nSi Verdadero Entonces\nEscribir 1;\nSi No\nEscribir 2;\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm P\nif true then\nwrite 1;\nif not\nwrite 2;\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedExpression",
        "severidad": "error"
      },
      {
        "codigo": "unclosedIfStatement",
        "severidad": "error"
      }
    ]
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las formas de D2 que no figuran en D1 no reservan identificadores: un nombre de variable, subprograma o campo escrito con una de ellas es un identificador ordinario fuera de la posición contextual de la forma. Dentro de esa posición la forma conserva su identidad; en particular, el campo de código de un error de biblioteca se nombra tras un punto con el lexema jsonErrorCodeField del perfil. Las formas de D1 siguen reservadas en toda posición.",
  "verificacion": [
    "C3",
    "C4",
    "C5"
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
    "variantKeyword": {
      "lexemas": {
        "es": "Variante",
        "en": "variant"
      }
    },
    "endVariant": {
      "lexemas": {
        "es": "FinVariante",
        "en": "endVariant"
      }
    },
    "alternativeKeyword": {
      "lexemas": {
        "es": "Alternativa",
        "en": "case"
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
    "environmentCapabilityType": {
      "lexemas": {
        "es": "Entorno",
        "en": "Environment"
      }
    },
    "dateTimeType": {
      "lexemas": {
        "es": "FechaHora",
        "en": "DateTime"
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
    "requestEnvironment": {
      "lexemas": {
        "es": "SolicitarEntorno",
        "en": "requestEnvironment"
      }
    },
    "requestTimer": {
      "lexemas": {
        "es": "SolicitarTemporizador",
        "en": "requestTimer"
      }
    },
    "taskFailureType": {
      "lexemas": {
        "es": "FalloTareas",
        "en": "taskFailure"
      }
    },
    "taskFirstError": {
      "lexemas": {
        "es": "Primero",
        "en": "first"
      }
    },
    "taskAssociatedErrors": {
      "lexemas": {
        "es": "Asociados",
        "en": "associated"
      }
    },
    "taskCancelledCount": {
      "lexemas": {
        "es": "Canceladas",
        "en": "cancelled"
      }
    },
    "immutableType": {
      "lexemas": {
        "es": "Inmutable",
        "en": "immutable"
      }
    },
    "snapshotBuiltin": {
      "lexemas": {
        "es": "Instantanea",
        "en": "snapshot"
      }
    },
    "networkCapabilityType": {
      "lexemas": {
        "es": "RedCap",
        "en": "NetworkCap"
      }
    },
    "httpRequestType": {
      "lexemas": {
        "es": "PeticionHttp",
        "en": "HttpRequest"
      }
    },
    "httpResponseType": {
      "lexemas": {
        "es": "RespuestaHttp",
        "en": "HttpResponse"
      }
    },
    "httpMethodType": {
      "lexemas": {
        "es": "MetodoHttp",
        "en": "HttpMethod"
      }
    },
    "channelType": {
      "lexemas": {
        "es": "Canal",
        "en": "channel"
      }
    },
    "channelSend": {
      "lexemas": {
        "es": "Enviar",
        "en": "send"
      }
    },
    "channelReceive": {
      "lexemas": {
        "es": "Recibir",
        "en": "receive"
      }
    },
    "channelClose": {
      "lexemas": {
        "es": "Cerrar",
        "en": "close"
      }
    },
    "receiveSource": {
      "lexemas": {
        "es": "Desde",
        "en": "from"
      }
    },
    "jsonValueType": {
      "lexemas": {
        "es": "ValorJson",
        "en": "JsonValue"
      }
    },
    "jsonKindType": {
      "lexemas": {
        "es": "TipoJson",
        "en": "JsonKind"
      }
    },
    "jsonErrorType": {
      "lexemas": {
        "es": "ErrorJson",
        "en": "JsonError"
      }
    },
    "jsonErrorCodeType": {
      "lexemas": {
        "es": "CodigoErrorJson",
        "en": "JsonErrorCode"
      }
    },
    "jsonKindNull": {
      "lexemas": {
        "es": "Nulo",
        "en": "Null"
      }
    },
    "jsonKindBoolean": {
      "lexemas": {
        "es": "JsonLogico",
        "en": "JsonBoolean"
      }
    },
    "jsonKindNumber": {
      "lexemas": {
        "es": "JsonNumero",
        "en": "JsonNumber"
      }
    },
    "jsonKindString": {
      "lexemas": {
        "es": "CadenaJson",
        "en": "JsonStringKind"
      }
    },
    "jsonKindArray": {
      "lexemas": {
        "es": "Arreglo",
        "en": "Array"
      }
    },
    "jsonKindObject": {
      "lexemas": {
        "es": "Objeto",
        "en": "Object"
      }
    },
    "jsonErrorCodeField": {
      "lexemas": {
        "es": "Codigo",
        "en": "code"
      }
    },
    "jsonErrorLineField": {
      "lexemas": {
        "es": "JsonLinea",
        "en": "jsonLine"
      }
    },
    "jsonErrorColumnField": {
      "lexemas": {
        "es": "JsonColumna",
        "en": "jsonColumn"
      }
    },
    "jsonErrorCodeInvalidSyntax": {
      "lexemas": {
        "es": "SintaxisInvalida",
        "en": "InvalidSyntax"
      }
    },
    "jsonErrorCodeUnexpectedEnd": {
      "lexemas": {
        "es": "FinInesperado",
        "en": "UnexpectedEnd"
      }
    },
    "jsonErrorCodeDuplicateKey": {
      "lexemas": {
        "es": "ClaveDuplicada",
        "en": "DuplicateKey"
      }
    },
    "jsonErrorCodeDepthExceeded": {
      "lexemas": {
        "es": "ProfundidadExcedida",
        "en": "DepthExceeded"
      }
    },
    "jsonErrorCodeInvalidEscape": {
      "lexemas": {
        "es": "EscapeInvalido",
        "en": "InvalidEscape"
      }
    },
    "jsonErrorCodeTrailingContent": {
      "lexemas": {
        "es": "ContenidoSobrante",
        "en": "TrailingContent"
      }
    },
    "vectorSort": {
      "lexemas": {
        "es": "Ordenar",
        "en": "sort"
      }
    },
    "vectorReverse": {
      "lexemas": {
        "es": "Invertir",
        "en": "reverse"
      }
    },
    "vectorIndexOf": {
      "lexemas": {
        "es": "PosicionDe",
        "en": "indexOf"
      }
    },
    "vectorContains": {
      "lexemas": {
        "es": "Contiene",
        "en": "contains"
      }
    },
    "dictionaryKeys": {
      "lexemas": {
        "es": "Claves",
        "en": "keys"
      }
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Codigo(valor Como Entero)\nEscribir valor;\nFinSubProceso\nAlgoritmo P\nDefinir codigo Como Entero;\ncodigo <- 7;\nCodigo(codigo);\nFinAlgoritmo\n",
    "en": "subroutine code(value as integer)\nwrite value;\nendSubroutine\nalgorithm P\ndefine codeValue as integer;\ncodeValue <- 7;\ncode(codeValue);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(\"{\");\nDefinir codigo Como Cadena;\nSegun parsed Hacer\nExito(document): codigo <- \"ninguno\";\nEscribir document.Tipo;\nError(problem): codigo <- \"error\";\nEscribir problem.Codigo;\nFinSegun\nEscribir codigo;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as result<JsonValue, JsonError> <- parseJson(\"{\");\ndefine code as string;\nswitch parsed do\nsuccess(document): code <- \"none\";\nwrite document.kind;\nfailure(problem): code <- \"error\";\nwrite problem.code;\nendSwitch\nwrite code;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:jsonErrorCodeUnexpectedEnd}}\nerror\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Hacer Como Entero <- 0;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine do as integer <- 0;\nendAlgorithm\n"
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
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "function (Funcion) y endFunction (FinFuncion) son identidades propias de D1 y no alias de subroutine ni de endSubroutine, porque solo la apertura function declara un subprograma puro. La gramática empareja cada apertura con su cierre propio: un subprograma abierto con Funcion se cierra con FinFuncion y uno abierto con SubProceso, con FinSubProceso; el cierre ajeno deja el subprograma sin cerrar (unclosedSubroutine). Como cualquier identidad, la reimpresión y la traducción la conservan: Funcion se escribe Function en inglés y FinFuncion, EndFunction, que se reconoce igual que su alias end function.",
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
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Funcion r <- Doble(a Como Entero)\nDefinir r Como Entero;\nr <- a * 2;\nFinFuncion\nAlgoritmo P\nEscribir Doble(4);\nFinAlgoritmo\n",
    "en": "Function r <- Twice(a As Integer)\nDefine r As Integer;\nr <- a * 2;\nEndFunction\nAlgorithm P\nWrite Twice(4);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Funcion r <- Doble(a Como Entero)\nDefinir r Como Entero;\nr <- a * 2;\nFinSubProceso\nAlgoritmo P\nEscribir Doble(4);\nFinAlgoritmo\n",
    "en": "function r <- Twice(a as integer)\ndefine r as integer;\nr <- a * 2;\nendSubroutine\nalgorithm P\nwrite Twice(4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unclosedSubroutine",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Funcion r <- Doble(a Como Entero)\nDefinir r Como Entero;\nr <- a * 2;\nFin Funcion\nAlgoritmo P\nEscribir Doble(5);\nFinAlgoritmo\n",
    "en": "function r <- Twice(a as integer)\ndefine r as integer;\nr <- a * 2;\nend function\nalgorithm P\nwrite Twice(5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "10\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

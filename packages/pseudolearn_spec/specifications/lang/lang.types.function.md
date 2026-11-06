---
{
  "formato": "see/1",
  "id": "LANG.TYPES.FUNCTION",
  "titulo": "Funciones como valores y clausuras",
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
    "engine",
    "aot"
  ],
  "resumen": "Firmas estructurales y captura por valor de vínculos inmutables.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.SCOPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Funciones como valores y clausuras

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "SubProceso(tipos de parámetro) Como retorno denota un tipo función estructural con tipos, orden, modos de paso y retorno exactos; sin Como retorno es vacío. SubProceso(parámetros nombrados) Como retorno seguido de cuerpo y FinSubProceso es un literal de función. Un nombre de subprograma es un valor de su firma. Se permite llamar cualquier expresión de tipo función, pasarla, almacenarla y retornarla. Una llamada al nombre conocido sigue siendo directa. La clausura copia las variables que utiliza, incluidas las usadas transitivamente por clausuras interiores; copiar un registro copia sus campos y copiar un objeto conserva su identidad. El entorno sobrevive al marco mientras sea alcanzable y participa en las raíces precisas del recolector. Una variable o parámetro por valor solo se puede capturar si es efectivamente constante: nunca se reasigna, es decir, no recibe un valor cuando ya podía tenerlo, no se asigna dentro de un bucle que la declaró fuera y no se pasa a un parámetro por referencia. Capturar uno que se reasigna, en cualquier punto de su ámbito, antes o después del literal, se rechaza con mutableClosureCapture, su tipo y como origen relacionado la primera reasignación; capturar un parámetro por referencia se rechaza igual con origen en su declaración. El entorno admite como máximo 65 535 palabras; exceder el límite produce closureEnvironmentTooLarge antes de emitir código. Las funciones, incluidos los registros que las contienen, no admiten igualdad ni orden. Escribir muestra <subprograma> en es y <subroutine> en en, sin direcciones ni identidades internas.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C16",
    "C17",
    "C18",
    "C19",
    "C20",
    "C21",
    "C22",
    "C23",
    "C24",
    "C25"
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
    "es": "SubProceso increment(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nDefinir callback Como SubProceso(Entero) Como Entero <- increment;\nEscribir callback(4);\nFinAlgoritmo\n",
    "en": "subroutine increment(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\ndefine callback as subroutine(integer) as integer <- increment;\nwrite callback(4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
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
    "es": "SubProceso make(value Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo P\nDefinir callback Como SubProceso() Como Entero <- make(7);\nEscribir callback();\nFinAlgoritmo\n",
    "en": "subroutine make(value as integer) as subroutine() as integer\ndefine captured as integer <- value;\nreturn subroutine() as integer\nreturn captured;\nendSubroutine;\nendSubroutine\nalgorithm P\ndefine callback as subroutine() as integer <- make(7);\nwrite callback();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nDefinir captured Como Entero <- 1;\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\ncaptured <- 2;\nEscribir callback();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine captured as integer <- 1;\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn captured;\nendSubroutine;\ncaptured <- 2;\nwrite callback();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "mutableClosureCapture",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso value() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo P\nEscribir value;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "<subprograma>\n",
    "terminacion": "completed"
  },
  "exclusiones": {
    "en": "El formato inglés se verifica por separado en C5."
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "en"
  ],
  "programas": {
    "en": "subroutine value() as integer\nreturn 1;\nendSubroutine\nalgorithm P\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "<subroutine>\n",
    "terminacion": "completed"
  },
  "exclusiones": {
    "es": "El formato español se verifica por separado en C4."
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
    "es": "Proceso P\nDefinir unused Como Entero <- 1;\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar 7;\nFinSubProceso;\nEscribir callback();\nFinProceso\n",
    "en": "algorithm P\ndefine unused as integer <- 1;\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn 7;\nendSubroutine;\nwrite callback();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
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
    "es": "SubProceso make(value Como Entero) Como SubProceso() Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como SubProceso() Como Entero\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso;\nFinSubProceso\nProceso P\nDefinir outer Como SubProceso() Como SubProceso() Como Entero <- make(9);\nDefinir inner Como SubProceso() Como Entero <- outer();\nEscribir inner();\nFinProceso\n",
    "en": "subroutine make(value as integer) as subroutine() as subroutine() as integer\ndefine captured as integer <- value;\nreturn subroutine() as subroutine() as integer\nreturn subroutine() as integer\nreturn captured;\nendSubroutine;\nendSubroutine;\nendSubroutine\nalgorithm P\ndefine outer as subroutine() as subroutine() as integer <- make(9);\ndefine inner as subroutine() as integer <- outer();\nwrite inner();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso apply(callback Como SubProceso(Entero) Como Entero, value Como Entero) Como Entero\nRetornar callback(value);\nFinSubProceso\nProceso P\nDefinir captured Como Entero <- 2;\nEscribir apply(SubProceso(value Como Entero) Como Entero\nRetornar value + captured;\nFinSubProceso, 5);\nFinProceso\n",
    "en": "subroutine apply(callback as subroutine(integer) as integer, value as integer) as integer\nreturn callback(value);\nendSubroutine\nalgorithm P\ndefine captured as integer <- 2;\nwrite apply(subroutine(value as integer) as integer\nreturn value + captured;\nendSubroutine, 5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Holder\nDefinir callback Como SubProceso() Como Entero;\nFinRegistro\nProceso P\nDefinir holder Como Holder <- Holder(SubProceso() Como Entero\nRetornar 11;\nFinSubProceso);\nEscribir holder.callback();\nFinProceso\n",
    "en": "record Holder\ndefine callback as subroutine() as integer;\nendRecord\nalgorithm P\ndefine holder as Holder <- Holder(subroutine() as integer\nreturn 11;\nendSubroutine);\nwrite holder.callback();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "11\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Pair\nDefinir first Como Entero;\nDefinir second Como Entero;\nFinRegistro\nProceso P\nDefinir captured Como Pair <- Pair(3, 4);\nDefinir copy Como Pair <- captured;\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar captured.first + captured.second;\nFinSubProceso;\ncopy.first <- 20;\nEscribir callback(), copy.first;\nFinProceso\n",
    "en": "record Pair\ndefine first as integer;\ndefine second as integer;\nendRecord\nalgorithm P\ndefine captured as Pair <- Pair(3, 4);\ndefine copy as Pair <- captured;\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn captured.first + captured.second;\nendSubroutine;\ncopy.first <- 20;\nwrite callback(), copy.first;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "720\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Clase Counter\nDefinir count Como Entero;\nFinClase\nProceso P\nDefinir captured Como Counter <- Nuevo Counter();\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar captured.count;\nFinSubProceso;\ncaptured.count <- 4;\nEscribir callback();\nFinProceso\n",
    "en": "class Counter\ndefine count as integer;\nendClass\nalgorithm P\ndefine captured as Counter <- new Counter();\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn captured.count;\nendSubroutine;\ncaptured.count <- 4;\nwrite callback();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso make(value Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nProceso P\nDefinir callback Como SubProceso() Como Entero <- make(7);\nDefinir allocation Como Counter <- Nuevo Counter();\nEscribir callback();\nFinProceso\nClase Counter\nDefinir count Como Entero;\nFinClase\n",
    "en": "subroutine make(value as integer) as subroutine() as integer\ndefine captured as integer <- value;\nreturn subroutine() as integer\nreturn captured;\nendSubroutine;\nendSubroutine\nalgorithm P\ndefine callback as subroutine() as integer <- make(7);\ndefine allocation as Counter <- new Counter();\nwrite callback();\nendAlgorithm\nclass Counter\ndefine count as integer;\nendClass\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso value() Como Entero\nRetornar 1;\nFinSubProceso\nProceso P\nEscribir value = value;\nFinProceso\n",
    "en": "subroutine value() as integer\nreturn 1;\nendSubroutine\nalgorithm P\nwrite value = value;\nendAlgorithm\n"
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
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso recurse(value Como Entero) Como Entero\nSi value = 0 Entonces\nRetornar 0;\nFinSi\nDefinir callback Como SubProceso(Entero) Como Entero <- recurse;\nRetornar callback(value - 1) + 1;\nFinSubProceso\nProceso P\nEscribir recurse(3);\nFinProceso\n",
    "en": "subroutine recurse(value as integer) as integer\nif value = 0 then\nreturn 0;\nendIf\ndefine callback as subroutine(integer) as integer <- recurse;\nreturn callback(value - 1) + 1;\nendSubroutine\nalgorithm P\nwrite recurse(3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso value() Como Entero\nRetornar 13;\nFinSubProceso\nProceso P\nDefinir captured Como SubProceso() Como Entero <- value;\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar captured();\nFinSubProceso;\nEscribir callback();\nFinProceso\n",
    "en": "subroutine value() as integer\nreturn 13;\nendSubroutine\nalgorithm P\ndefine captured as subroutine() as integer <- value;\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn captured();\nendSubroutine;\nwrite callback();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "13\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Holder\nDefinir callback Como SubProceso() Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir item Como Holder <- Holder(SubProceso() Como Entero\nRetornar 1;\nFinSubProceso);\nEscribir item = item;\nFinAlgoritmo\n",
    "en": "record Holder\ndefine callback as subroutine() as integer;\nendRecord\nalgorithm P\ndefine item as Holder <- Holder(subroutine() as integer\nreturn 1;\nendSubroutine);\nwrite item = item;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "diagnosticos": [
      {
        "codigo": "incompatibleOperandTypes",
        "severidad": "error"
      }
    ],
    "arbol": "presente"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso increment(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nDefinir callback Como SubProceso(Entero) Como Entero <- increment;\nEscribir callback(9223372036854775807);\nFinAlgoritmo\n",
    "en": "subroutine increment(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\ndefine callback as subroutine(integer) as integer <- increment;\nwrite callback(9223372036854775807);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    }
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nx <- 5;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nx <- 5;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nx <- 5;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nx <- 6;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nx <- 5;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nx <- 6;\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "mutableClosureCapture",
        "severidad": "error"
      }
    ]
  },
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "mutableClosureCapture",
          "severidad": "error",
          "tramo": {
            "start": {
              "line": 5,
              "column": 10
            },
            "end": {
              "line": 5,
              "column": 11
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 7,
                "column": 1
              },
              "end": {
                "line": 7,
                "column": 7
              }
            }
          ]
        }
      ]
    },
    "en": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "mutableClosureCapture",
          "severidad": "error",
          "tramo": {
            "start": {
              "line": 5,
              "column": 8
            },
            "end": {
              "line": 5,
              "column": 9
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 7,
                "column": 1
              },
              "end": {
                "line": 7,
                "column": 7
              }
            }
          ]
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Falso;\nSi c Entonces\nx <- 1;\nSiNo\nx <- 2;\nFinSi\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine c as boolean <- false;\nif c then\nx <- 1;\nelse\nx <- 2;\nendIf\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nPara i <- 1 Hasta 2 Hacer\nx <- i;\nFinPara\nx <- 0;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nfor i <- 1 to 2 do\nx <- i;\nendFor\nx <- 0;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "mutableClosureCapture",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nread x;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
    "terminacion": "completed"
  },
  "entradas": [
    "9"
  ]
}
```

```caso
{
  "id": "C23",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Envolver(v Como Entero) Como Entero\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar v;\nFinSubProceso;\nRetornar f();\nFinSubProceso\nAlgoritmo P\nEscribir Envolver(3);\nFinAlgoritmo\n",
    "en": "subroutine Wrap(v as integer) as integer\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn v;\nendSubroutine;\nreturn f();\nendSubroutine\nalgorithm P\nwrite Wrap(3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso Envolver(v Como Entero) Como Entero\nv <- v + 1;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar v;\nFinSubProceso;\nRetornar f();\nFinSubProceso\nAlgoritmo P\nEscribir Envolver(3);\nFinAlgoritmo\n",
    "en": "subroutine Wrap(v as integer) as integer\nv <- v + 1;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn v;\nendSubroutine;\nreturn f();\nendSubroutine\nalgorithm P\nwrite Wrap(3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "mutableClosureCapture",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 2;\nDefinir externa Como SubProceso() Como Entero <- SubProceso() Como Entero\nDefinir interna Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x * 10;\nFinSubProceso;\nRetornar interna();\nFinSubProceso;\nEscribir externa();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 2;\ndefine outer as subroutine() as integer <- subroutine() as integer\ndefine inner as subroutine() as integer <- subroutine() as integer\nreturn x * 10;\nendSubroutine;\nreturn inner();\nendSubroutine;\nwrite outer();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "20\n",
    "terminacion": "completed"
  }
}
```

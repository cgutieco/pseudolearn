---
{
  "formato": "see/1",
  "id": "LANG.DECL.UNINITIALIZED",
  "titulo": "Lectura sin inicializar",
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
  "resumen": "Lectura sin inicializar.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Lectura sin inicializar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una variable local declarada sin valor inicial no recibe ningún valor por defecto. Leerla, o capturarla, en un punto al que algún camino de ejecución llega sin haberle dado valor es variableUsedUninitialized, error, antes de ejecutar. El diagnóstico lleva el nombre de la variable (lexeme) y la causa del camino sin valor (cause): noAssignment si ningún camino anterior le dio valor, o branchWithoutElse, branchWithoutAssignment, loopMayNotRun o switchWithoutDefault si la falta viene de la unión que nombran las reglas siguientes. Su primer origen relacionado es el nombre declarado y, cuando la causa no es noAssignment, el segundo es la construcción que deja el camino sin valor; si varias uniones la dejan sin valor, se nombra la última en orden de ejecución. El valor inicial no puede leer su propia variable (bindingReadsOwnInitializer). Los campos y elementos de arreglo siguen pudiendo carecer de valor y su lectura conserva la trampa uninitializedVariableRead. No hay migrador ni modo de compatibilidad. Un vínculo declarado dentro de un bloque deja de existir al terminarlo, aunque el bloque pueda no ejecutarse; usarlo fuera de él produce bindingOutsideScope, error.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C17",
    "C21"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En una secuencia, una asignación, Leer x, el valor inicial de Definir y el argumento de un parámetro de salida (LANG.SUBPROGRAM.BY-REFERENCE) dan valor a la variable desde ese punto. Un registro local se sigue por campo: dar valor a un campo no se lo da a los demás.",
  "verificacion": [
    "C5",
    "C16"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Tras Si con Sino una variable tiene valor si lo tiene al final de las dos ramas; si una rama no se lo da, la causa es branchWithoutAssignment y el origen es esa rama. Tras Si sin Sino solo tiene valor si ya lo tenía antes (branchWithoutElse, origen en el Si). Segun, también sobre variantes, y Elegir exigen el valor al final de todas sus ramas (branchWithoutAssignment, origen en la rama); un Segun sin De Otro Modo que no cubre todos los valores del selector añade el camino que no entra en ninguna rama (switchWithoutDefault, origen en el Segun).",
  "verificacion": [
    "C6",
    "C7",
    "C8",
    "C10",
    "C11"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Mientras, Para y Para Cada pueden no ejecutar su cuerpo: después del bucle una variable solo tiene valor si lo tenía antes (loopMayNotRun, origen en el bucle). Repetir ejecuta su cuerpo al menos una vez: Hasta Que se comprueba con lo asignado en el cuerpo y, tras el bucle, la variable tiene valor si lo tiene al final del cuerpo y en cada Salir de ese cuerpo (branchWithoutAssignment, origen en el Salir). Lo que asigna el cuerpo de Diferir no cuenta después de Diferir.",
  "verificacion": [
    "C12",
    "C13",
    "C14",
    "C18",
    "C19"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Retornar y Salir terminan su camino: el resto del bloque no restringe ninguna unión, y una rama que termina así no exige valor a las variables de la unión.",
  "verificacion": [
    "C9"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un literal de función que usa una variable exterior la captura al crearse: la variable debe tener valor en ese punto o es variableUsedUninitialized en el primer uso dentro del literal.",
  "verificacion": [
    "C15",
    "C20"
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nx <- 5;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nx <- 5;\nwrite x;\nendAlgorithm\n"
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
    "es": "Algoritmo P\n  Definir x Como Entero;\n  Escribir x;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Define x As Integer;\n  Write x;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error"
      }
    ]
  },
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "variableUsedUninitialized",
          "severidad": "error",
          "tramo": {
            "start": {
              "line": 3,
              "column": 12
            },
            "end": {
              "line": 3,
              "column": 13
            }
          },
          "argumentos": {
            "cause": "noAssignment",
            "lexeme": "x"
          },
          "relacionados": [
            {
              "start": {
                "line": 2,
                "column": 11
              },
              "end": {
                "line": 2,
                "column": 12
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
          "codigo": "variableUsedUninitialized",
          "severidad": "error",
          "tramo": {
            "start": {
              "line": 3,
              "column": 9
            },
            "end": {
              "line": 3,
              "column": 10
            }
          },
          "argumentos": {
            "cause": "noAssignment",
            "lexeme": "x"
          },
          "relacionados": [
            {
              "start": {
                "line": 2,
                "column": 10
              },
              "end": {
                "line": 2,
                "column": 11
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 0;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 0;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "algorithm Main\nwhile false do\ndefine x as integer <- 1;\nendWhile\nwrite x;\nendAlgorithm\n",
    "es": "Algoritmo Main\nMientras Falso Hacer\nDefinir x Como Entero <- 1;\nFinMientras\nEscribir x;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingOutsideScope",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\nDefinir n Como Entero;\nLeer n;\nEscribir n * 2;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine n as integer;\nread n;\nwrite n * 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "42\n",
    "terminacion": "completed"
  },
  "entradas": [
    "21"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Verdadero;\nSi c Entonces\nx <- 1;\nSino\nx <- 2;\nFinSi\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine c as boolean <- true;\nif c then\nx <- 1;\nelse\nx <- 2;\nendIf\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Verdadero;\nSi c Entonces\nx <- 1;\nFinSi\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine c as boolean <- true;\nif c then\nx <- 1;\nendIf\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "branchWithoutElse",
          "lexeme": "x"
        }
      }
    ]
  }
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Verdadero;\nSi c Entonces\nx <- 1;\nSino\nEscribir 0;\nFinSi\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine c as boolean <- true;\nif c then\nx <- 1;\nelse\nwrite 0;\nendIf\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "branchWithoutAssignment",
          "lexeme": "x"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso F(c Como Logico) Como Entero\nDefinir x Como Entero;\nSi c Entonces\nx <- 1;\nSino\nRetornar 0;\nFinSi\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir F(Verdadero), F(Falso);\nFinAlgoritmo\n",
    "en": "subroutine F(c as boolean) as integer\ndefine x as integer;\nif c then\nx <- 1;\nelse\nreturn 0;\nendIf\nreturn x;\nendSubroutine\nalgorithm P\nwrite F(true), F(false);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "10\n",
    "terminacion": "completed"
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
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color <- Color.Verde;\nDefinir n Como Entero;\nSegun c Hacer\nColor.Rojo: n <- 1;\nColor.Verde: n <- 2;\nFinSegun\nEscribir n;\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color <- Color.Verde;\ndefine n as integer;\nswitch c do\nColor.Rojo: n <- 1;\nColor.Verde: n <- 2;\nendSwitch\nwrite n;\nendAlgorithm\n"
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
  "id": "C11",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir n Como Entero;\nDefinir k Como Entero <- 2;\nSegun k Hacer\n1: n <- 1;\n2: n <- 2;\nFinSegun\nEscribir n;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine n as integer;\ndefine k as integer <- 2;\nswitch k do\n1: n <- 1;\n2: n <- 2;\nendSwitch\nwrite n;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "switchWithoutDefault",
          "lexeme": "n"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Falso;\nMientras c Hacer\nx <- 1;\nc <- Falso;\nFinMientras\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine c as boolean <- false;\nwhile c do\nx <- 1;\nc <- false;\nendWhile\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "loopMayNotRun",
          "lexeme": "x"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nRepetir\nx <- 3;\nHasta Que x > 0\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nrepeat\nx <- 3;\nuntil x > 0\nwrite x;\nendAlgorithm\n"
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
  "id": "C14",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir c Como Logico <- Verdadero;\nRepetir\nSi c Entonces\nSalir;\nFinSi\nx <- 1;\nHasta Que x > 0\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine c as boolean <- true;\nrepeat\nif c then\nbreak;\nendIf\nx <- 1;\nuntil x > 0\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "branchWithoutAssignment",
          "lexeme": "x"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nx <- 1;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nx <- 1;\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "x"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Registro Punto\nDefinir x, z Como Entero;\nFinRegistro\nAlgoritmo P\nDefinir p Como Punto;\np.x <- 1;\nEscribir p.z;\nFinAlgoritmo\n",
    "en": "record Punto\ndefine x, z as integer;\nendRecord\nalgorithm P\ndefine p as Punto;\np.x <- 1;\nwrite p.z;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\nDimension a[2] Como Entero;\na[0] <- 1;\nEscribir a[0];\nEscribir a[1];\nFinAlgoritmo\n",
    "en": "algorithm P\ndimension a[2] as integer;\na[0] <- 1;\nwrite a[0];\nwrite a[1];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "failed",
    "fallo": {
      "codigo": "uninitializedVariableRead"
    }
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir s Como Entero;\ns <- 0;\nPara i <- 1 Hasta 2 Hacer\nPara j <- 1 Hasta 2 Hacer\nPara k <- 1 Hasta 2 Hacer\ns <- s + 1;\nFinPara\nFinPara\nFinPara\nEscribir s;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine s as integer;\ns <- 0;\nfor i <- 1 to 2 do\nfor j <- 1 to 2 do\nfor k <- 1 to 2 do\ns <- s + 1;\nendFor\nendFor\nendFor\nwrite s;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir t Como Entero;\nPara i <- 1 Hasta 2 Hacer\nPara j <- 1 Hasta 2 Hacer\nPara k <- 1 Hasta 2 Hacer\nt <- i + j + k;\nFinPara\nFinPara\nFinPara\nEscribir t;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine t as integer;\nfor i <- 1 to 2 do\nfor j <- 1 to 2 do\nfor k <- 1 to 2 do\nt <- i + j + k;\nendFor\nendFor\nendFor\nwrite t;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "loopMayNotRun",
          "lexeme": "t"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero;\nx <- 4;\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar x;\nFinSubProceso;\nEscribir f();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nx <- 4;\ndefine f as subroutine() as integer <- subroutine() as integer\nreturn x;\nendSubroutine;\nwrite f();\nendAlgorithm\n"
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
  "id": "C21",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir a, b Como Entero;\na <- 1;\nEscribir a + b;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine a, b as integer;\na <- 1;\nwrite a + b;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error",
        "argumentos": {
          "cause": "noAssignment",
          "lexeme": "b"
        }
      }
    ]
  }
}
```

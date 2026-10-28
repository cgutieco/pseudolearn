---
{
  "formato": "see/1",
  "id": "LANG.CAPABILITY.PURITY",
  "titulo": "Pureza y efectos transitivos en subprogramas",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Prohibición de efectos directos o transitivos en funciones puras, propagación sobre el grafo de llamadas y coherencia en clausuras e interfaces.",
  "titulo_en": "Subprogram purity and transitive side effects",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROGRAM.STRUCTURE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Pureza y efectos transitivos en subprogramas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una Funcion o Function es estrictamente pura. Tiene prohibido realizar directamente operaciones de entrada o salida, modificar estado externo u operar sobre capacidades con efectos secundarios.",
  "verificacion": [
    "C1",
    "C2",
    "C16"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "Funcion F() Como Entero\nEscribir 1;\nRetornar 1;\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n",
    "en": "function F() as integer\nwrite 1;\nreturn 1;\nend function\nalgorithm P\nwrite F();\nendAlgorithm\n"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "programas": {
    "es": "Funcion Cuadrado(x Como Entero) Como Entero\nRetornar x * x;\nFinFuncion\nAlgoritmo P\nEscribir Cuadrado(2);\nFinAlgoritmo\n",
    "en": "function Cuadrado(x as integer) as integer\nreturn x * x;\nend function\nalgorithm P\nwrite Cuadrado(2);\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El análisis semántico comprueba la pureza transitiva hasta punto fijo sobre el grafo de llamadas del programa. Si una Funcion invoca a otra unidad que realiza efectos secundarios, la función llamadora es rechazada con pureFunctionTransitiveSideEffect. El diagnóstico lleva como ubicaciones relacionadas, en orden, cada unidad de la cadena de llamadas desde el primer llamado con efecto hasta la unidad que realiza el efecto directo; si hay varios llamados con efecto se sigue el de menor orden de declaración.",
  "verificacion": [
    "C3",
    "C7",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C17",
    "C18"
  ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Efecto()\nEscribir 2;\nFinSubProceso\nFuncion F() Como Entero\nEfecto();\nRetornar 0;\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine Efecto()\nwrite 2;\nendSubroutine\nfunction F() as integer\nEfecto();\nreturn 0;\nend function\nalgorithm P\nwrite F();\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "No se permite pasar ni asignar una clausura o subprograma con efectos secundarios en un contexto donde el tipo esperado es una función pura Funcion. Las discrepancias de pureza son detectadas estáticamente.",
  "verificacion": [
    "C4",
    "C8",
    "C21",
    "C22"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso ConEfecto(x Como Entero) Como Entero\nEscribir x;\nRetornar x;\nFinSubProceso\nFuncion Aplicar(fn Como Funcion(Entero) Como Entero, v Como Entero) Como Entero\nRetornar fn(v);\nFinFuncion\nAlgoritmo P\nEscribir Aplicar(ConEfecto, 5);\nFinAlgoritmo\n",
    "en": "subroutine ConEfecto(x as integer) as integer\nwrite x;\nreturn x;\nendSubroutine\nfunction Aplicar(fn as function(integer) as integer, v as integer) as integer\nreturn fn(v);\nend function\nalgorithm P\nwrite Aplicar(ConEfecto, 5);\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando una Interfaz declara un método de tipo Funcion, cualquier implementación concreta en una clase debe ser estrictamente pura. Toda implementación que realice efectos secundarios es rechazada con pureFunctionInterfaceImpurity. El diagnóstico lleva como ubicaciones relacionadas la cadena de llamadas con efecto de la implementación, con el mismo criterio que R2.",
  "verificacion": [
    "C5",
    "C20"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionInterfaceImpurity",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "Interfaz Calculable\nFuncion Calcular() Como Entero;\nFinInterfaz\nClase Demo Realiza Calculable\nMetodo Calcular() Como Entero\nEscribir 1;\nRetornar 1;\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "interface Calculable\nfunction Calcular() as integer;\nendInterface\nclass Demo implements Calculable\nmethod Calcular() as integer\nwrite 1;\nreturn 1;\nendMethod\nendClass\nalgorithm P\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "SubProceso y Algoritmo son las unidades del lenguaje autorizadas para poseer efectos secundarios y ejecutar operaciones sobre el entorno y capacidades.",
  "verificacion": [
    "C6",
    "C19"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "subproceso_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Saludar()\nEscribir \"subproceso_ok\";\nFinSubProceso\nAlgoritmo P\nSaludar();\nFinAlgoritmo\n",
    "en": "subroutine Saludar()\nwrite \"subproceso_ok\";\nendSubroutine\nalgorithm P\nSaludar();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Logico\nEscribir 1;\nRetornar Verdadero;\nFinSubProceso\nFuncion Probe() Como Entero\nSi Effect() Entonces\nRetornar 1;\nFinSi\nRetornar 0;\nFinFuncion\nAlgoritmo Main\nEscribir Probe();\nFinAlgoritmo\n",
    "en": "subroutine Effect() as boolean\nwrite 1;\nreturn true;\nendSubroutine\nfunction Probe() as integer\nif Effect() then\nreturn 1;\nendIf\nreturn 0;\nend function\nalgorithm Main\nwrite Probe();\nendAlgorithm\n"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect(value Como Entero) Como Entero\nEscribir value;\nRetornar value;\nFinSubProceso\nFuncion Probe() Como Entero\nDefinir action Como Funcion(Entero) Como Entero <- Effect;\nRetornar action(3);\nFinFuncion\nAlgoritmo Main\nEscribir Probe();\nFinAlgoritmo\n",
    "en": "subroutine Effect(value as integer) as integer\nwrite value;\nreturn value;\nendSubroutine\nfunction Probe() as integer\ndefine action as function(integer) as integer <- Effect;\nreturn action(3);\nend function\nalgorithm Main\nwrite Probe();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion Probe() Como Opcional<Entero>\nRetornar Algo(Effect());\nFinFuncion\nAlgoritmo Main\nDefinir outcome Como Opcional<Entero> <- Probe();\nSegun outcome Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction Probe() as optional<integer>\nreturn some(Effect());\nend function\nalgorithm Main\ndefine outcome as optional<integer> <- Probe();\nswitch outcome do\nsome(value): write value;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion F() Como Entero\nDefinir Mutable x Como Entero <- 0;\nx <- Effect();\nRetornar x;\nFinFuncion\nAlgoritmo Main\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction F() as integer\ndefine mutable x as integer <- 0;\nx <- Effect();\nreturn x;\nend function\nalgorithm Main\nwrite F();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion F() Como Entero\nDefinir Mutable i Como Entero <- 0;\nMientras i < Effect() Hacer\ni <- i + 1;\nFinMientras\nRetornar i;\nFinFuncion\nAlgoritmo Main\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction F() as integer\ndefine mutable i as integer <- 0;\nwhile i < Effect() do\ni <- i + 1;\nendWhile\nreturn i;\nend function\nalgorithm Main\nwrite F();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion F() Como Entero\nDefinir Mutable total Como Entero <- 0;\nPara i <- 1 Hasta Effect() Con Paso 1 Hacer\ntotal <- total + i;\nFinPara\nRetornar total;\nFinFuncion\nAlgoritmo Main\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction F() as integer\ndefine mutable total as integer <- 0;\nfor i <- 1 to Effect() with step 1 do\ntotal <- total + i;\nendFor\nreturn total;\nend function\nalgorithm Main\nwrite F();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion F() Como Entero\nRetornar 1 + Effect();\nFinFuncion\nAlgoritmo Main\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction F() as integer\nreturn 1 + Effect();\nend function\nalgorithm Main\nwrite F();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion F() Como Entero\nDefinir kept Como Entero <- Effect();\nRetornar kept;\nFinFuncion\nAlgoritmo Main\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction F() as integer\ndefine kept as integer <- Effect();\nreturn kept;\nend function\nalgorithm Main\nwrite F();\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso C() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nSubProceso B() Como Entero\nRetornar C();\nFinSubProceso\nFuncion A() Como Entero\nRetornar B();\nFinFuncion\nAlgoritmo P\nEscribir A();\nFinAlgoritmo\n",
    "en": "subroutine C() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nsubroutine B() as integer\nreturn C();\nendSubroutine\nfunction A() as integer\nreturn B();\nend function\nalgorithm P\nwrite A();\nendAlgorithm\n"
  },
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "pureFunctionTransitiveSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 8,
              "column": 1
            },
            "end": {
              "line": 10,
              "column": 11
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 5,
                "column": 1
              },
              "end": {
                "line": 7,
                "column": 14
              }
            },
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
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
          "codigo": "pureFunctionTransitiveSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 8,
              "column": 1
            },
            "end": {
              "line": 10,
              "column": 13
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 5,
                "column": 1
              },
              "end": {
                "line": 7,
                "column": 14
              }
            },
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
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
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "Funcion F() Como Entero\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nRetornar x;\nFinFuncion\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n",
    "en": "function F() as integer\ndefine mutable x as integer <- 0;\nread x;\nreturn x;\nend function\nalgorithm P\nwrite F();\nendAlgorithm\n"
  },
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "pureFunctionSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 1,
              "column": 1
            },
            "end": {
              "line": 5,
              "column": 11
            }
          }
        }
      ]
    },
    "en": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "pureFunctionSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 1,
              "column": 1
            },
            "end": {
              "line": 5,
              "column": 13
            }
          }
        }
      ]
    }
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      },
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nFuncion Even(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar Effect();\nFinSi\nRetornar Odd(n - 1);\nFinFuncion\nFuncion Odd(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 0;\nFinSi\nRetornar Even(n - 1);\nFinFuncion\nAlgoritmo P\nEscribir Odd(3);\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\nfunction Even(n as integer) as integer\nif n = 0 then\nreturn Effect();\nendIf\nreturn Odd(n - 1);\nend function\nfunction Odd(n as integer) as integer\nif n = 0 then\nreturn 0;\nendIf\nreturn Even(n - 1);\nend function\nalgorithm P\nwrite Odd(3);\nendAlgorithm\n"
  },
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "pureFunctionTransitiveSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 5,
              "column": 1
            },
            "end": {
              "line": 10,
              "column": 11
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
              }
            }
          ]
        },
        {
          "codigo": "pureFunctionTransitiveSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 11,
              "column": 1
            },
            "end": {
              "line": 16,
              "column": 11
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 5,
                "column": 1
              },
              "end": {
                "line": 10,
                "column": 11
              }
            },
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
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
          "codigo": "pureFunctionTransitiveSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 5,
              "column": 1
            },
            "end": {
              "line": 10,
              "column": 13
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
              }
            }
          ]
        },
        {
          "codigo": "pureFunctionTransitiveSideEffect",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 11,
              "column": 1
            },
            "end": {
              "line": 16,
              "column": 13
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 5,
                "column": 1
              },
              "end": {
                "line": 10,
                "column": 13
              }
            },
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
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
  "id": "C18",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "programas": {
    "es": "Funcion Even(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 1;\nFinSi\nRetornar Odd(n - 1);\nFinFuncion\nFuncion Odd(n Como Entero) Como Entero\nSi n = 0 Entonces\nRetornar 0;\nFinSi\nRetornar Even(n - 1);\nFinFuncion\nAlgoritmo P\nEscribir Odd(3);\nFinAlgoritmo\n",
    "en": "function Even(n as integer) as integer\nif n = 0 then\nreturn 1;\nendIf\nreturn Odd(n - 1);\nend function\nfunction Odd(n as integer) as integer\nif n = 0 then\nreturn 0;\nendIf\nreturn Even(n - 1);\nend function\nalgorithm P\nwrite Odd(3);\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "programas": {
    "es": "SubProceso F() Como Entero\nDefinir Mutable x Como Entero <- 0;\nLeer x;\nEscribir x;\nRetornar x;\nFinSubProceso\nAlgoritmo P\nEscribir F();\nFinAlgoritmo\n",
    "en": "subroutine F() as integer\ndefine mutable x as integer <- 0;\nread x;\nwrite x;\nreturn x;\nendSubroutine\nalgorithm P\nwrite F();\nendAlgorithm\n"
  },
  "sujetos": [
    "engine"
  ]
}
```

```caso
{
  "id": "C20",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionInterfaceImpurity",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect() Como Entero\nEscribir 1;\nRetornar 1;\nFinSubProceso\nInterfaz Calculable\nFuncion Calcular() Como Entero;\nFinInterfaz\nClase Demo Realiza Calculable\nMetodo Calcular() Como Entero\nRetornar Effect();\nFinMetodo\nFinClase\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "subroutine Effect() as integer\nwrite 1;\nreturn 1;\nendSubroutine\ninterface Calculable\nfunction Calcular() as integer;\nendInterface\nclass Demo implements Calculable\nmethod Calcular() as integer\nreturn Effect();\nendMethod\nendClass\nalgorithm P\nendAlgorithm\n"
  },
  "esperas": {
    "es": {
      "arbol": "presente",
      "diagnosticos": [
        {
          "codigo": "pureFunctionInterfaceImpurity",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 9,
              "column": 1
            },
            "end": {
              "line": 11,
              "column": 10
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
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
          "codigo": "pureFunctionInterfaceImpurity",
          "severidad": "error",
          "clase": "semantic",
          "tramo": {
            "start": {
              "line": 9,
              "column": 1
            },
            "end": {
              "line": 11,
              "column": 10
            }
          },
          "relacionados": [
            {
              "start": {
                "line": 1,
                "column": 1
              },
              "end": {
                "line": 4,
                "column": 14
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
  "id": "C21",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Effect(value Como Entero) Como Entero\nEscribir value;\nRetornar value;\nFinSubProceso\nAlgoritmo Main\nDefinir action Como Funcion(Entero) Como Entero <- Effect;\nEscribir action(3);\nFinAlgoritmo\n",
    "en": "subroutine Effect(value as integer) as integer\nwrite value;\nreturn value;\nendSubroutine\nalgorithm Main\ndefine action as function(integer) as integer <- Effect;\nwrite action(3);\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso ConEfecto(x Como Entero) Como Entero\nEscribir x;\nRetornar x;\nFinSubProceso\nSubProceso Aplicar(fn Como Funcion(Entero) Como Entero, v Como Entero) Como Entero\nRetornar fn(v);\nFinSubProceso\nAlgoritmo P\nEscribir Aplicar(ConEfecto, 5);\nFinAlgoritmo\n",
    "en": "subroutine ConEfecto(x as integer) as integer\nwrite x;\nreturn x;\nendSubroutine\nsubroutine Aplicar(fn as function(integer) as integer, v as integer) as integer\nreturn fn(v);\nendSubroutine\nalgorithm P\nwrite Aplicar(ConEfecto, 5);\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una Funcion o Function no es suspendible y no puede contener Aguardar. Aguardar dentro de una función pura produce awaitOutsideSuspendible; la comprobación de pureza preserva este diagnóstico específico.",
  "verificacion": [
    "C23"
  ]
}
```

```caso
{
  "id": "C23",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "pureFunctionTransitiveSideEffect",
        "severidad": "error"
      },
      {
        "codigo": "awaitOutsideSuspendible",
        "severidad": "error"
      }
    ]
  },
  "programas": {
    "es": "SubProceso Suspendible Worker()\nFinSubProceso\nFuncion Calculate() Como Entero\nRetornar Aguardar Worker();\nFinFuncion\nAlgoritmo P\nEscribir Calculate();\nFinAlgoritmo\n",
    "en": "subroutine suspendable Worker()\nendSubroutine\nfunction Calculate() as integer\nreturn await Worker();\nend function\nalgorithm P\nwrite Calculate();\nendAlgorithm\n"
  }
}
```

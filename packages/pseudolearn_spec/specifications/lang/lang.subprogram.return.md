---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.RETURN",
  "titulo": "Retorno",
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
  "resumen": "Retorno.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Retorno

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Retornar termina inmediatamente la llamada y abandona bloques y bucles abiertos. Exige expresión cuando hay tipo de retorno y la prohíbe cuando no lo hay, salvo salida sin expresión de constructor. Tipo incompatible es semántico. Retorno fuera de subprograma es sintáctico. Ningún retorno en función tipada es error semántico; un camino que alcanza el cierre sin retornar es fallo de ejecución con tramo de cierre y cabecera relacionada. En una función con variable de retorno r, Retornar va sin expresión (returnValueInReturnVariableFunction si la lleva) y devuelve r; el fin del cuerpo también devuelve r. En cada Retornar y en cada fin normal del cuerpo r debe tener valor según LANG.DECL.UNINITIALIZED: en otro caso es variableUsedUninitialized con la cabecera como origen relacionado.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9"
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(2);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(2);\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Retornar 1;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Return 1;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "returnOutsideSubroutine",
        "severidad": "error"
      }
    ]
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
    "es": "SubProceso f()\n  Retornar 1;\nFinSubProceso\n\nAlgoritmo P\n  f();\nFinAlgoritmo\n",
    "en": "Subroutine f()\n  Return 1;\nEndSubroutine\n\nAlgorithm P\n  f();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "returnExpressionInVoidSubroutine",
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
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso f() Como Entero\n  Si Falso Entonces\n    Retornar 1;\n  FinSi\nFinSubProceso\n\nAlgoritmo P\n  Escribir f();\nFinAlgoritmo\n",
    "en": "Subroutine f() As Integer\n  If False Then\n    Return 1;\n  EndIf\nEndSubroutine\n\nAlgorithm P\n  Write f();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "subroutineEndedWithoutReturn"
    }
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Funcion r <- Positivo(a Como Entero)\nDefinir r Como Entero;\nSi a > 0 Entonces\nr <- a;\nFinSi\nFinFuncion\nAlgoritmo P\nEscribir Positivo(2);\nFinAlgoritmo\n",
    "en": "function r <- Positive(a as integer)\ndefine r as integer;\nif a > 0 then\nr <- a;\nendIf\nendSubroutine\nalgorithm P\nwrite Positive(2);\nendAlgorithm\n"
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
          "lexeme": "r"
        }
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
    "es": "Funcion r <- Signo(a Como Entero)\nDefinir r Como Entero;\nr <- 1;\nSi a < 0 Entonces\nr <- -1;\nRetornar;\nFinSi\nFinFuncion\nAlgoritmo P\nEscribir Signo(-4), Signo(4);\nFinAlgoritmo\n",
    "en": "function r <- Sign(a as integer)\ndefine r as integer;\nr <- 1;\nif a < 0 then\nr <- -1;\nreturn;\nendIf\nendSubroutine\nalgorithm P\nwrite Sign(-4), Sign(4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-11\n",
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
    "es": "Funcion r <- Uno()\nDefinir r Como Entero;\nr <- 1;\nRetornar r;\nFinFuncion\nAlgoritmo P\nEscribir Uno();\nFinAlgoritmo\n",
    "en": "function r <- One()\ndefine r as integer;\nr <- 1;\nreturn r;\nendSubroutine\nalgorithm P\nwrite One();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "returnValueInReturnVariableFunction",
        "severidad": "error"
      }
    ]
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
    "es": "Funcion r <- Factorial(n Como Entero)\nDefinir r Como Entero;\nSi n <= 1 Entonces\nr <- 1;\nSiNo\nr <- n * Factorial(n - 1);\nFinSi\nFinFuncion\nAlgoritmo P\nEscribir Factorial(5);\nFinAlgoritmo\n",
    "en": "function r <- Factorial(n as integer)\ndefine r as integer;\nif n <= 1 then\nr <- 1;\nelse\nr <- n * Factorial(n - 1);\nendIf\nendSubroutine\nalgorithm P\nwrite Factorial(5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "120\n",
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
    "es": "SubProceso Mayor(primero Como Entero, segundo Como Entero) Como Entero\n  Si primero > segundo Entonces\n    Retornar primero;\n  FinSi\n  Retornar segundo;\nFinSubProceso\n\nAlgoritmo Comparar\n  Escribir Mayor(7, 3);\n  Escribir Mayor(2, 9);\nFinAlgoritmo\n",
    "en": "Subroutine Larger(first As Integer, second As Integer) As Integer\n  If first > second Then\n    Return first;\n  EndIf\n  Return second;\nEndSubroutine\n\nAlgorithm Compare\n  Write Larger(7, 3);\n  Write Larger(2, 9);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n9\n",
    "terminacion": "completed"
  }
}
```

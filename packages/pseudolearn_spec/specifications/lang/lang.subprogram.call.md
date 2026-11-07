---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.CALL",
  "titulo": "Llamadas",
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
  "resumen": "Llamadas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.PARAMETERS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Llamadas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Paréntesis son obligatorios y los argumentos se evalúan izquierda a derecha una vez. Cantidad y tipos coinciden con firma. Llamada a procedimiento como expresión es error; llamar como sentencia una función produce discardedReturnValue como advertencia. El retorno sirve de valor en la posición de llamada. Resolver una llamada no confunde variable y subprograma.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(4);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(4);\nendAlgorithm\n"
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
    "es": "SubProceso f(value Como Entero) Como Entero\n  Retornar value + 1;\nFinSubProceso\n\nAlgoritmo P\n  Escribir f();\nFinAlgoritmo\n",
    "en": "Subroutine f(value As Integer) As Integer\n  Return value + 1;\nEndSubroutine\n\nAlgorithm P\n  Write f();\nEndAlgorithm\n"
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
    "es": "SubProceso f()\n  Escribir 1;\nFinSubProceso\n\nAlgoritmo P\n  Escribir f();\nFinAlgoritmo\n",
    "en": "Subroutine f()\n  Write 1;\nEndSubroutine\n\nAlgorithm P\n  Write f();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "callAsExpressionWithoutReturnType",
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
    "es": "SubProceso Area(base Como Entero, altura Como Entero) Como Entero\n  Retornar base * altura;\nFinSubProceso\n\nAlgoritmo Rectangulo\n  Definir superficie Como Entero;\n  superficie <- Area(4, 5);\n  Escribir superficie;\nFinAlgoritmo\n",
    "en": "Subroutine Area(base As Integer, height As Integer) As Integer\n  Return base * height;\nEndSubroutine\n\nAlgorithm Rectangle\n  Define surface As Integer;\n  surface <- Area(4, 5);\n  Write surface;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "20\n",
    "terminacion": "completed"
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
    "es": "SubProceso DibujarLinea()\n  Escribir \"----------\";\nFinSubProceso\n\nAlgoritmo Tarjeta\n  DibujarLinea();\n  Escribir \"Ana\";\n  DibujarLinea();\nFinAlgoritmo\n",
    "en": "Subroutine DrawLine()\n  Write \"----------\";\nEndSubroutine\n\nAlgorithm Card\n  DrawLine();\n  Write \"Ana\";\n  DrawLine();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "----------\nAna\n----------\n",
    "terminacion": "completed"
  }
}
```

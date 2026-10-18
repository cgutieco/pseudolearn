---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.CALL",
  "titulo": "Llamadas",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
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
      "version": ">=0.1.0, <1.0.0",
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f(4);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f(4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
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
    "es": "SubProceso f(value Como Entero) Como Entero\nRetornar value + 1;\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nreturn value + 1;\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
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

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso f()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f()\nwrite 1;\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

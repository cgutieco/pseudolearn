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
  "texto": "Retornar termina inmediatamente la llamada y abandona bloques y bucles abiertos. Exige expresión cuando hay tipo de retorno y la prohíbe cuando no lo hay, salvo salida sin expresión de constructor. Tipo incompatible es semántico. Retorno fuera de subprograma es sintáctico. Ningún retorno en función tipada es error semántico; un camino que alcanza el cierre sin retornar es fallo de ejecución con tramo de cierre y cabecera relacionada.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
    "es": "Algoritmo P\nRetornar 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nreturn 1;\nendAlgorithm\n"
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
    "es": "SubProceso f()\nRetornar 1;\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
    "en": "subroutine f()\nreturn 1;\nendSubroutine\nalgorithm P\nf();\nendAlgorithm\n"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "SubProceso f() Como Entero\nSi Falso Entonces\nRetornar 1;\nFinSi\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f() as integer\nif false then\nreturn 1;\nendIf\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "subroutineEndedWithoutReturn"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

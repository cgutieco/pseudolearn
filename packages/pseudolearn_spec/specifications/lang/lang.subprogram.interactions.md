---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.INTERACTIONS",
  "titulo": "Interacciones procedimentales",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Interacciones procedimentales.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.RETURN",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Interacciones procedimentales

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dentro de un subprograma se admiten declaraciones, E/S y todos los bloques estructurados. Declaraciones son locales; retorno y llamada exigen terminador en estricto. Un retorno desde un bucle termina la llamada completa. La entrada suspende también llamadas profundas. Los arreglos conservan sus restricciones de valor y por referencia.",
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
    "es": "SubProceso f() Como Entero\nMientras Verdadero Hacer\nRetornar 3;\nFinMientras\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f() as integer\nwhile true do\nreturn 3;\nendWhile\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
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
    "es": "SubProceso f() Como Entero\nRetornar 3\nFinSubProceso\nAlgoritmo P\nEscribir f();\nFinAlgoritmo\n",
    "en": "subroutine f() as integer\nreturn 3\nendSubroutine\nalgorithm P\nwrite f();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "missingStatementTerminator",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto"
  ]
}
```

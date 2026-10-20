---
{
  "formato": "see/1",
  "id": "DIAG.ORDERING",
  "titulo": "Orden de diagnósticos",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Orden de diagnósticos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "DIAG.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "cambio": {
    "clase": "editorial",
    "impacto_usuarios": "Contrato existente respaldado; no cambia su comportamiento observable.",
    "impacto_implementaciones": "Se conserva la versión numérica y las exenciones explícitas de cada sujeto.",
    "justificacion": "Promoción revisada con evidencias vigentes y verificadores locales ejecutados.",
    "revisado_por": "revision-independiente-automatizada-r9"
  }
}
---

# Orden de diagnósticos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El orden de análisis es determinista: fases léxica, sintáctica y semántica; dentro de cada fase, posición original y desempate estable por código. No se elimina multiplicidad para ocultar una cascada: cada diagnóstico permitido aparece una vez por situación. La comparación puede ser por multiconjunto cuando el caso no observa orden.",
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
    "es": "Algoritmo P\nDefinir Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedIdentifierInDeclaration",
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir @;\nEscribir $;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite @;\nwrite $;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos_ordenados": [
      {
        "codigo": "unrecognizedCharacter",
        "severidad": "error",
        "clase": "lexical",
        "argumentos": {
          "lexeme": "@"
        }
      },
      {
        "codigo": "unrecognizedCharacter",
        "severidad": "error",
        "clase": "lexical",
        "argumentos": {
          "lexeme": "$"
        }
      }
    ]
  },
  "origen": "derivado"
}
```

---
{
  "formato": "see/1",
  "id": "LANG.TYPES.INFERENCE",
  "titulo": "Inferencia flexible",
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
  "resumen": "Inferencia flexible.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Inferencia flexible

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una primera asignación sin declaración en flexible fija el tipo e informa inferredVariableType. Una posterior asignación entero a real amplía el tipo e informa widenedVariableType. Un tipo incompatible produce typeConflictOnInferredVariable; no se degrada a un tipo dinámico universal. Estricto exige declaración previa.",
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
    "es": "Algoritmo P\nvalue <- 1;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\nvalue <- 1;\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "rigor": [
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
    "es": "Algoritmo P\nvalue <- 1;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\nvalue <- 1;\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredVariable",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto"
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
    "es": "Algoritmo P\nvalue <- 1;\nvalue <- \"ab\";\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\nvalue <- 1;\nvalue <- \"ab\";\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "undeclaredVariable",
        "severidad": "warning"
      },
      {
        "codigo": "inferredVariableType",
        "severidad": "info"
      },
      {
        "codigo": "typeConflictOnInferredVariable",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "flexible"
  ]
}
```

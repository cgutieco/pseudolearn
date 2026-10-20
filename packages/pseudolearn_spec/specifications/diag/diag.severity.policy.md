---
{
  "formato": "see/1",
  "id": "DIAG.SEVERITY.POLICY",
  "titulo": "Política de severidad",
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
  "resumen": "Política de severidad.",
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

# Política de severidad

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Clase A estructural y ejecución fatal es error en ambos rigores. B gobernada por exigencia es error estricto y advertencia flexible. C higiene es advertencia en ambos. D inferencia es información. E lectura inválida es advertencia y recuperable. Flexible nunca aumenta severidad; etiqueta real es A aunque etiquetas no enteras compatibles sean B. La severidad se inyecta como dato, no cambia el significado.",
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nwrite x;\nendAlgorithm\n"
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
  "rigor": [
    "estricto"
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
    "es": "Algoritmo P\nDefinir x Como Entero;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "warning"
      }
    ]
  },
  "rigor": [
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
    "es": "Algoritmo P\nEscribir 1 + Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 + true;\nendAlgorithm\n"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

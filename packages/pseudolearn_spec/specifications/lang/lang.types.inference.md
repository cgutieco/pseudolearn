---
{
  "formato": "see/1",
  "id": "LANG.TYPES.INFERENCE",
  "titulo": "Inferencia flexible",
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
  "resumen": "Inferencia flexible.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
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
  "texto": "En ambos rigores cada vínculo local se declara con tipo e inicializador. La asignación a un nombre no declarado es undeclaredVariable, error, y no declara ni infiere un vínculo; un símbolo inválido evita diagnósticos derivados. No existe declaración implícita ni migrador: la forma oficial usa Definir con tipo e inicializador y Mutable cuando el vínculo se reasigna.",
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
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "flexible"
  ]
}
```

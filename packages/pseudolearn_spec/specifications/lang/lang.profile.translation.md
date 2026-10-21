---
{
  "formato": "see/1",
  "id": "LANG.PROFILE.TRANSLATION",
  "titulo": "Traducción de vocabularios",
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
  "resumen": "Traducción de vocabularios.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Traducción de vocabularios

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La traducción reimprime identidades de tokens y funciones con lexemas canónicos del destino; preserva nombres, literales, comentarios y trivia ajena a los lexemas. Cambiar idioma conserva resultado salvo valores lógicos representados con el vocabulario activo. La ida/vuelta de fuentes canónicas conserva el texto; un alias se canoniza. Una colisión con un nombre reservado del destino requiere diagnóstico y no renombrado silencioso.",
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
    "es": "Algoritmo P\nEscribir \"for // Para\", Verdadero;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"for // Para\", true;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "for // Para{{lexema:booleanTrue}}\n",
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
    "es": "Algoritmo P\nDefinir Mientras Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine while as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "reservedLexemeUsedAsName",
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

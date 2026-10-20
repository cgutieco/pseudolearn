---
{
  "formato": "see/1",
  "id": "DIAG.MESSAGES",
  "titulo": "Presentación bilingüe de diagnósticos",
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
  "resumen": "Presentación bilingüe de diagnósticos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "DIAG.CATALOG",
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

# Presentación bilingüe de diagnósticos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La capa de presentación resuelve plantilla por idioma de interfaz y sustituye argumentos tipados. El idioma de prosa es independiente del vocabulario del programa. Nunca traduce nombres del usuario; tokens usan lexema activo. Cada plantilla usa exactamente sus argumentos requeridos; no quedan marcadores sin resolver. Los mensajes describen el problema y la acción pertinente sin texto del anfitrión.",
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

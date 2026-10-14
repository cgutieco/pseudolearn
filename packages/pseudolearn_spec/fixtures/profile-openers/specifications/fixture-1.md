---
{
  "formato": "see/1",
  "id": "TOOL.TEST.OPENERS",
  "titulo": "Fixture",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "cli"
  ],
  "resumen": "Violación deliberada.",
  "depende_de": []
}
---

# Fixture

```definicion
{
  "id": "D1",
  "termino": "cliConventions",
  "texto": "Convenciones.",
  "valor": {
    "codigos_salida": {
      "0": "éxito"
    },
    "aperturas": [
      "algorithm"
    ]
  }
}
```

```definicion
{
  "id": "D2",
  "termino": "vocabulary",
  "texto": "Vocabulario.",
  "valor": {
    "algorithm": {
      "lexemas": {
        "es": "Proceso",
        "en": "algorithm"
      },
      "alias": {
        "es": [],
        "en": []
      }
    },
    "process": {
      "lexemas": {
        "es": "Tarea",
        "en": "proceso"
      },
      "alias": {
        "es": [],
        "en": []
      }
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Regla de fixture.",
  "verificacion": [
    "revision_humana"
  ]
}
```

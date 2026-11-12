---
{
  "formato": "see/1",
  "id": "SEE.VERSIONING",
  "titulo": "Versionado de contratos",
  "dominio": "proceso",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Versionado de contratos.",
  "depende_de": [],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Versionado de contratos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una identidad nueva se crea estable en 1.0.0, sin campo cambio y sin completar revisado_por automáticamente. Todo cambio de versión de una especificación existente declara clase, impactos, justificación y revisor, y actualiza el anclaje de esa versión.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los cambios editoriales y la verificación añadida incrementan revisión; aclaración, ampliación y deprecación incrementan menor; restricción, cambio de significado y retirada incrementan mayor. Una versión nunca disminuye.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones.

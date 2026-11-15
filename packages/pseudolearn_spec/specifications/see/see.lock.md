---
{
  "formato": "see/1",
  "id": "SEE.LOCK",
  "titulo": "Anclaje de especificaciones",
  "dominio": "proceso",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Anclaje de especificaciones.",
  "depende_de": [],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Anclaje de especificaciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Lock conserva versión exacta y hash canónico por especificación e historial de identidades; --check rechaza anclajes desactualizados. El archivo se versiona con el corpus y ancla la última publicación. La validación ordinaria y --check rechazan hashes divergentes: un cambio normativo solo se acepta con la versión y la clasificación requeridas.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones.

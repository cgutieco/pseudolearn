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
    "revision-independiente-automatizada-r9"
  ]
}
---

# Anclaje de especificaciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Lock conserva versión exacta y hash canónico por especificación e historial de identidades; --check rechaza anclajes desactualizados. Durante el congelamiento, la actualización explícita --refresh recibe identificadores separados por comas y permite reanclar ediciones oficiales manteniendo identidad, estado y versión, sin campo cambio. Solo la autorización explícita reabre el versionado. No se actualizan otros identificadores ni identidades terminales. La validación ordinaria y --check rechazan hashes divergentes.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

---
{
  "formato": "see/1",
  "id": "SEE.LOCK",
  "titulo": "Anclaje de especificaciones",
  "dominio": "proceso",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Anclaje de especificaciones.",
  "depende_de": [],
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica por autorización y no se añaden construcciones.",
    "impacto_implementaciones": "Sujetos retirados, alcance de casos y verificaciones de contratos existentes explícitos.",
    "justificacion": "Migración autorizada; la evidencia histórica, AOT y de plataforma conserva sus límites.",
    "revisado_por": "revision-independiente-automatizada"
  },
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
  "texto": "Lock conserva versión exacta y hash canónico por especificación e historial de identidades; --check rechaza anclajes desactualizados. La actualización explícita --refresh recibe identificadores separados por comas y permite regenerar sus hashes manteniendo la versión durante el desarrollo. No autoriza cambios de otros identificadores ni de identidades terminales. La validación ordinaria y --check siguen rechazando hashes divergentes.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

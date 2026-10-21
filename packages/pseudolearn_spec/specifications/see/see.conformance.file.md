---
{
  "formato": "see/1",
  "id": "SEE.CONFORMANCE.FILE",
  "titulo": "Vínculos de conformidad",
  "dominio": "proceso",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Vínculos de conformidad.",
  "depende_de": [],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Vínculos de conformidad

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los vínculos viven como datos por sujeto y resuelven especificación, versión y regla. El manifiesto admite estado activo o retirado; omitirlo significa activo. Un sujeto retirado conserva identidad y vínculos históricos sin exigir que sus rutas sigan instaladas, no se lanza y no aporta evidencia de estabilidad.",
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
  "texto": "Pendiente declara fase de resolución abierta; exento declara justificación; estable exige vínculos en cada sujeto.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

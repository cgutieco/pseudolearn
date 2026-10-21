---
{
  "formato": "see/1",
  "id": "SEE.IMPACT",
  "titulo": "Impacto transitivo",
  "dominio": "proceso",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Impacto transitivo.",
  "depende_de": [],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Impacto transitivo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Impacto incluye la especificación consultada y todos sus dependientes transitivos, sin duplicados; un identificador desconocido es error.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

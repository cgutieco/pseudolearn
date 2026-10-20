---
{
  "formato": "see/1",
  "id": "SEE.VERSIONING",
  "titulo": "Versionado de contratos",
  "dominio": "proceso",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Versionado de contratos.",
  "depende_de": [],
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

# Versionado de contratos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada cambio de versión declara clase, impacto sobre usuarios, impacto sobre implementaciones, justificación y revisor; las versiones aumentan.",
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
  "texto": "Editorial y verificación añadida incrementan revisión; aclaración, ampliación y deprecación incrementan menor; restricción, significado y retirada incrementan mayor.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

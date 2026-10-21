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
    "revision-independiente-automatizada-r9"
  ]
}
---

# Versionado de contratos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Hasta que la persona autorice explícitamente iniciar la publicación de una versión del lenguaje, las especificaciones conservan estado, identidad y versión. Las ediciones oficiales se escriben en la misma especificación sin campo cambio y actualizan el anclaje de esa versión. Al reabrirse el versionado, cada cambio de versión declara clase, impactos, justificación y revisor.",
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
  "texto": "Con el versionado reabierto, los cambios editoriales y la verificación añadida incrementan revisión; aclaración, ampliación y deprecación incrementan menor; restricción, cambio de significado y retirada incrementan mayor. Durante el congelamiento no se cambia la versión.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.
